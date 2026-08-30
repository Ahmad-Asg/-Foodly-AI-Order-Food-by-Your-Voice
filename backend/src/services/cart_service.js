import mongoose from 'mongoose';

import { Cart } from '../models/cart.js';
import { FoodItem } from '../models/food_item.js';
import { AppError } from '../utils/app_error.js';
import { getPrimaryRestaurant } from './restaurant_service.js';

function validateFoodId(foodItemId) {
  if (!mongoose.isValidObjectId(foodItemId)) {
    throw new AppError('Food item ID is invalid.', 400);
  }
}

function validateQuantity(quantity) {
  if (!Number.isInteger(quantity) || quantity < 1) {
    throw new AppError('Quantity must be a whole number of at least 1.', 400);
  }
}

function toCartItem(food, quantity) {
  return {
    foodItemId: food._id.toString(),
    quantity,
    food: {
      id: food._id.toString(),
      name: food.name,
      description: food.description,
      price: food.price,
      image: food.image,
      isAvailable: food.isAvailable,
    },
    lineTotal: food.price * quantity,
  };
}

export async function getCartDetails(userId) {
  const cart = await Cart.findOne({ userId });
  if (!cart || cart.items.length === 0) {
    return { items: [], subtotal: 0, deliveryFee: 0, total: 0 };
  }

  const restaurant = await getPrimaryRestaurant();
  const foodIds = cart.items.map((item) => item.foodItemId);
  const foods = await FoodItem.find({ _id: { $in: foodIds }, restaurantId: restaurant._id }).lean();
  const foodsById = new Map(foods.map((food) => [food._id.toString(), food]));

  const items = cart.items.map((item) => {
    const food = foodsById.get(item.foodItemId.toString());
    if (!food) throw new AppError('A food item in your cart no longer exists.', 409);
    if (!food.isAvailable) throw new AppError(`${food.name} is currently unavailable.`, 409);
    return toCartItem(food, item.quantity);
  });
  const subtotal = items.reduce((sum, item) => sum + item.lineTotal, 0);
  const deliveryFee = restaurant.deliveryFee;

  return { items, subtotal, deliveryFee, total: subtotal + deliveryFee };
}

async function saveCalculatedTotals(cart) {
  const details = await getCartDetails(cart.userId);
  cart.subtotal = details.subtotal;
  cart.deliveryFee = details.deliveryFee;
  cart.total = details.total;
  await cart.save();
  return details;
}

export async function getOrCreateCart(userId) {
  let cart = await Cart.findOne({ userId });
  if (!cart) cart = await Cart.create({ userId });
  return cart;
}

export async function addCartItem(userId, foodItemId, quantity) {
  validateFoodId(foodItemId);
  validateQuantity(quantity);

  const restaurant = await getPrimaryRestaurant();
  const food = await FoodItem.findOne({ _id: foodItemId, restaurantId: restaurant._id });
  if (!food) throw new AppError('Food item not found.', 404);
  if (!food.isAvailable) throw new AppError('Food item is currently unavailable.', 409);

  const cart = await getOrCreateCart(userId);
  const item = cart.items.find((entry) => entry.foodItemId.toString() === foodItemId);
  if (item) {
    item.quantity += quantity;
  } else {
    cart.items.push({ foodItemId, quantity });
  }
  return saveCalculatedTotals(cart);
}

export async function updateCartItem(userId, foodItemId, quantity) {
  validateFoodId(foodItemId);
  validateQuantity(quantity);

  const cart = await Cart.findOne({ userId });
  const item = cart?.items.find((entry) => entry.foodItemId.toString() === foodItemId);
  if (!item) throw new AppError('Food item is not in your cart.', 404);
  item.quantity = quantity;
  return saveCalculatedTotals(cart);
}

export async function removeCartItem(userId, foodItemId) {
  validateFoodId(foodItemId);
  const cart = await Cart.findOne({ userId });
  if (!cart) throw new AppError('Food item is not in your cart.', 404);

  const originalLength = cart.items.length;
  cart.items = cart.items.filter((item) => item.foodItemId.toString() !== foodItemId);
  if (cart.items.length === originalLength) throw new AppError('Food item is not in your cart.', 404);

  if (cart.items.length === 0) {
    cart.subtotal = 0;
    cart.deliveryFee = 0;
    cart.total = 0;
    await cart.save();
    return { items: [], subtotal: 0, deliveryFee: 0, total: 0 };
  }
  return saveCalculatedTotals(cart);
}

export async function clearCart(userId) {
  const cart = await Cart.findOne({ userId });
  if (cart) {
    cart.items = [];
    cart.subtotal = 0;
    cart.deliveryFee = 0;
    cart.total = 0;
    await cart.save();
  }
  return { items: [], subtotal: 0, deliveryFee: 0, total: 0 };
}
