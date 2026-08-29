import mongoose from 'mongoose';

import { Category } from '../models/category.js';
import { FoodItem } from '../models/food_item.js';
import { getPrimaryRestaurant } from '../services/restaurant_service.js';
import { AppError } from '../utils/app_error.js';
import { asyncHandler } from '../utils/async_handler.js';

const spiceLevelAliases = { spicy: 'hot', extra_spicy: 'extra_hot', 'extra-spicy': 'extra_hot' };
const supportedSpiceLevels = new Set(['none', 'mild', 'medium', 'hot', 'extra_hot']);

function parsePrice(value, name) {
  if (value === undefined) return undefined;
  const price = Number(value);
  if (!Number.isFinite(price) || price < 0) {
    throw new AppError(`${name} must be a non-negative number.`, 400);
  }
  return price;
}

async function buildFoodFilter(query) {
  const restaurant = await getPrimaryRestaurant();
  const filter = { restaurantId: restaurant._id, isAvailable: true };
  const minPrice = parsePrice(query.minPrice, 'minPrice');
  const maxPrice = parsePrice(query.maxPrice, 'maxPrice');

  if (minPrice !== undefined || maxPrice !== undefined) {
    filter.price = {};
    if (minPrice !== undefined) filter.price.$gte = minPrice;
    if (maxPrice !== undefined) filter.price.$lte = maxPrice;
    if (minPrice !== undefined && maxPrice !== undefined && minPrice > maxPrice) {
      throw new AppError('minPrice cannot be greater than maxPrice.', 400);
    }
  }

  if (query.spiceLevel !== undefined) {
    const requested = String(query.spiceLevel).trim().toLowerCase();
    const spiceLevel = spiceLevelAliases[requested] ?? requested;
    if (!supportedSpiceLevels.has(spiceLevel)) {
      throw new AppError('spiceLevel must be none, mild, medium, hot, extra_hot, or spicy.', 400);
    }
    filter.spiceLevel = spiceLevel;
  }

  if (query.dietaryTag !== undefined) {
    const dietaryTag = String(query.dietaryTag).trim().toLowerCase();
    if (!dietaryTag) throw new AppError('dietaryTag cannot be empty.', 400);
    filter.dietaryTags = dietaryTag;
  }

  if (query.category !== undefined) {
    const categoryName = String(query.category).trim();
    if (!categoryName) throw new AppError('category cannot be empty.', 400);
    const category = await Category.findOne({
      restaurantId: restaurant._id,
      name: categoryName,
      isAvailable: true,
    }).lean();
    if (!category) return { filter: { ...filter, categoryId: null } };
    filter.categoryId = category._id;
  }

  return { filter };
}

export const getFoods = asyncHandler(async (request, response) => {
  const { filter } = await buildFoodFilter(request.query);
  const foods = await FoodItem.find(filter).sort({ categoryId: 1, name: 1 }).lean();
  response.status(200).json({ success: true, data: foods });
});

export const getFoodById = asyncHandler(async (request, response) => {
  const { id } = request.params;
  if (!mongoose.isValidObjectId(id)) throw new AppError('Food item ID is invalid.', 400);

  const restaurant = await getPrimaryRestaurant();
  const food = await FoodItem.findOne({ _id: id, restaurantId: restaurant._id, isAvailable: true }).lean();
  if (!food) throw new AppError('Food item not found.', 404);

  response.status(200).json({ success: true, data: food });
});
