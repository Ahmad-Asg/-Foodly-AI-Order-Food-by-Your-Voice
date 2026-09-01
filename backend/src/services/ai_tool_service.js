import mongoose from 'mongoose';

import { Category } from '../models/category.js';
import { FoodItem } from '../models/food_item.js';
import { AppError } from '../utils/app_error.js';
import { addCartItem, clearCart, getCartDetails, removeCartItem, updateCartItem } from './cart_service.js';
import { createOrderFromCart } from './order_service.js';
import { getPrimaryRestaurant } from './restaurant_service.js';

const confirmationPattern = /^(yes|y|haan|han|ji|confirm|place it|kar do|kardo|krdo)( please| na)?$/i;
const allowedSpiceLevels = new Set(['none', 'mild', 'medium', 'hot', 'extra_hot', 'spicy']);

function escapeRegularExpression(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function normalizeCategoryName(value) {
  const normalized = String(value ?? '').trim().toLowerCase().replace(/\s+/g, ' ');
  return normalized.endsWith('s') ? normalized.slice(0, -1) : normalized;
}

export const foodlyTools = [
  { type: 'function', function: { name: 'search_food', description: 'Search the current restaurant menu before recommending or changing an item.', parameters: { type: 'object', properties: { query: { type: 'string' }, category: { type: 'string' }, minPrice: { type: 'number' }, maxPrice: { type: 'number' }, spiceLevel: { type: 'string' }, dietaryPreference: { type: 'string' }, availableOnly: { type: 'boolean' } }, additionalProperties: false } } },
  { type: 'function', function: { name: 'get_food_details', description: 'Get trusted details for one menu item ID.', parameters: { type: 'object', properties: { foodItemId: { type: 'string' } }, required: ['foodItemId'], additionalProperties: false } } },
  { type: 'function', function: { name: 'get_cart', description: 'Get the signed-in user\'s real cart and current totals.', parameters: { type: 'object', properties: {}, additionalProperties: false } } },
  { type: 'function', function: { name: 'add_to_cart', description: 'Add a verified food item to the signed-in user\'s real cart.', parameters: { type: 'object', properties: { foodItemId: { type: 'string' }, quantity: { type: 'integer', minimum: 1 } }, required: ['foodItemId', 'quantity'], additionalProperties: false } } },
  { type: 'function', function: { name: 'update_cart_quantity', description: 'Set the quantity of an item already in the signed-in user\'s cart.', parameters: { type: 'object', properties: { foodItemId: { type: 'string' }, quantity: { type: 'integer', minimum: 1 } }, required: ['foodItemId', 'quantity'], additionalProperties: false } } },
  { type: 'function', function: { name: 'remove_from_cart', description: 'Remove one verified item from the signed-in user\'s cart.', parameters: { type: 'object', properties: { foodItemId: { type: 'string' } }, required: ['foodItemId'], additionalProperties: false } } },
  { type: 'function', function: { name: 'clear_cart', description: 'Request or, after explicit confirmation, clear the signed-in user\'s cart.', parameters: { type: 'object', properties: {}, additionalProperties: false } } },
  { type: 'function', function: { name: 'create_order', description: 'Request or, after explicit confirmation, create an order from the signed-in user\'s cart. A delivery address is required.', parameters: { type: 'object', properties: { deliveryAddress: { type: 'string' } }, additionalProperties: false } } },
];

function compactFood(food, category) {
  return { id: food._id.toString(), name: food.name, price: food.price, description: food.description, category, ingredients: food.ingredients, spiceLevel: food.spiceLevel, dietaryTags: food.dietaryTags, isAvailable: food.isAvailable };
}

function compactCart(cart) {
  return { items: cart.items.map((item) => ({ foodItemId: item.foodItemId, name: item.food.name, quantity: item.quantity, unitPrice: item.food.price, lineTotal: item.lineTotal })), subtotal: cart.subtotal, deliveryFee: cart.deliveryFee, total: cart.total };
}

function cartSignature(cart) {
  return cart.items.map((item) => `${item.foodItemId}:${item.quantity}`).sort().join('|');
}

function clearPending(conversation) {
  conversation.pendingAction = { type: null, cartSignature: null, deliveryAddress: null };
}

async function searchFood(arguments_) {
  const restaurant = await getPrimaryRestaurant();
  const categories = await Category.find({ restaurantId: restaurant._id }).lean();
  const filter = { restaurantId: restaurant._id };
  if (arguments_.availableOnly !== false) filter.isAvailable = true;
  if (arguments_.minPrice !== undefined || arguments_.maxPrice !== undefined) filter.price = {};
  if (Number.isFinite(arguments_.minPrice)) filter.price.$gte = arguments_.minPrice;
  if (Number.isFinite(arguments_.maxPrice)) filter.price.$lte = arguments_.maxPrice;
  if (arguments_.spiceLevel) {
    if (!allowedSpiceLevels.has(arguments_.spiceLevel)) throw new AppError('That spice level is not supported.', 400);
    filter.spiceLevel = arguments_.spiceLevel === 'spicy' ? 'hot' : arguments_.spiceLevel;
  }
  if (arguments_.dietaryPreference) filter.dietaryTags = String(arguments_.dietaryPreference).toLowerCase();
  if (arguments_.category) {
    const requestedCategory = normalizeCategoryName(arguments_.category);
    const category = categories.find((candidate) => normalizeCategoryName(candidate.name) === requestedCategory);
    if (!category) return [];
    filter.categoryId = category._id;
  }
  if (arguments_.query) {
    const query = String(arguments_.query).trim();
    if (query.length > 80) throw new AppError('Food search text is too long.', 400);
    // Models sometimes pass a full spoken sentence (for example, "mujhe
    // burgers suggest karo") rather than just "burger". Detect the menu
    // category inside that sentence so it still returns the correct items.
    const categoryMentionedInQuery = categories.find((candidate) => {
      const normalizedName = normalizeCategoryName(candidate.name);
      return new RegExp(`\\b${escapeRegularExpression(normalizedName)}s?\\b`, 'i').test(query);
    });
    if (!filter.categoryId && categoryMentionedInQuery) filter.categoryId = categoryMentionedInQuery._id;
    const effectiveQuery = categoryMentionedInQuery ? normalizeCategoryName(categoryMentionedInQuery.name) : query;
    const variants = [effectiveQuery];
    if (effectiveQuery.length > 3 && effectiveQuery.endsWith('s')) variants.push(effectiveQuery.slice(0, -1));
    const expressions = variants.map((value) => new RegExp(escapeRegularExpression(value), 'i'));
    filter.$or = expressions.flatMap((expression) => [
      { name: expression },
      { description: expression },
      { ingredients: expression },
    ]);
  }
  const foods = await FoodItem.find(filter).sort({ price: 1, name: 1 }).limit(12).lean();
  const categoryNames = new Map(categories.map((category) => [category._id.toString(), category.name]));
  return foods.map((food) => compactFood(food, categoryNames.get(food.categoryId.toString()) ?? 'Uncategorized'));
}

async function getFoodDetails(foodItemId) {
  if (!mongoose.isValidObjectId(foodItemId)) throw new AppError('Food item ID is invalid.', 400);
  const restaurant = await getPrimaryRestaurant();
  const food = await FoodItem.findOne({ _id: foodItemId, restaurantId: restaurant._id }).lean();
  if (!food) throw new AppError('Food item not found.', 404);
  const category = await Category.findById(food.categoryId).lean();
  return compactFood(food, category?.name ?? 'Uncategorized');
}

export async function executeAiTool({ name, arguments_, userId, conversation, latestUserMessage }) {
  try {
    let data;
    if (name === 'search_food') data = await searchFood(arguments_);
    else if (name === 'get_food_details') data = await getFoodDetails(arguments_.foodItemId);
    else if (name === 'get_cart') data = compactCart(await getCartDetails(userId));
    else if (name === 'add_to_cart') { clearPending(conversation); await conversation.save(); data = compactCart(await addCartItem(userId, arguments_.foodItemId, arguments_.quantity)); }
    else if (name === 'update_cart_quantity') { clearPending(conversation); await conversation.save(); data = compactCart(await updateCartItem(userId, arguments_.foodItemId, arguments_.quantity)); }
    else if (name === 'remove_from_cart') { clearPending(conversation); await conversation.save(); data = compactCart(await removeCartItem(userId, arguments_.foodItemId)); }
    else if (name === 'clear_cart') {
      const cart = await getCartDetails(userId);
      if (!cart.items.length) data = { alreadyEmpty: true };
      else if (conversation.pendingAction?.type === 'clear_cart' && confirmationPattern.test(latestUserMessage.trim()) && conversation.pendingAction.cartSignature === cartSignature(cart)) { data = compactCart(await clearCart(userId)); clearPending(conversation); await conversation.save(); }
      else { conversation.pendingAction = { type: 'clear_cart', cartSignature: cartSignature(cart), deliveryAddress: null }; await conversation.save(); data = { requiresConfirmation: true, cart: compactCart(cart) }; }
    } else if (name === 'create_order') {
      const cart = await getCartDetails(userId);
      const address = String(arguments_.deliveryAddress ?? conversation.pendingAction?.deliveryAddress ?? '').trim();
      if (!cart.items.length) data = { emptyCart: true };
      else if (!address) data = { requiresDeliveryAddress: true, cart: compactCart(cart) };
      else if (conversation.pendingAction?.type === 'create_order' && confirmationPattern.test(latestUserMessage.trim()) && conversation.pendingAction.cartSignature === cartSignature(cart)) { data = await createOrderFromCart(userId, { deliveryAddress: address }); clearPending(conversation); await conversation.save(); }
      else { conversation.pendingAction = { type: 'create_order', cartSignature: cartSignature(cart), deliveryAddress: address }; await conversation.save(); data = { requiresConfirmation: true, cart: compactCart(cart) }; }
    } else throw new AppError('Unsupported Foodly AI tool.', 400);
    return { ok: true, data };
  } catch (error) {
    return { ok: false, error: error instanceof AppError ? error.message : 'The requested action could not be completed.' };
  }
}
