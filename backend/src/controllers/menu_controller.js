import { Category } from '../models/category.js';
import { FoodItem } from '../models/food_item.js';
import { getPrimaryRestaurant } from '../services/restaurant_service.js';
import { asyncHandler } from '../utils/async_handler.js';

export const getMenu = asyncHandler(async (request, response) => {
  const restaurant = await getPrimaryRestaurant();
  const categories = await Category.find({ restaurantId: restaurant._id, isAvailable: true })
    .sort({ sortOrder: 1 })
    .lean();
  const foods = await FoodItem.find({ restaurantId: restaurant._id, isAvailable: true }).sort({ name: 1 }).lean();

  const menu = categories.map((category) => ({
    ...category,
    items: foods.filter((food) => food.categoryId.equals(category._id)),
  }));

  response.status(200).json({ success: true, data: { restaurant, categories: menu } });
});
