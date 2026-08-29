import { Category } from '../models/category.js';
import { getPrimaryRestaurant } from '../services/restaurant_service.js';
import { asyncHandler } from '../utils/async_handler.js';

export const getCategories = asyncHandler(async (request, response) => {
  const restaurant = await getPrimaryRestaurant();
  const categories = await Category.find({ restaurantId: restaurant._id, isAvailable: true })
    .sort({ sortOrder: 1 })
    .lean();
  response.status(200).json({ success: true, data: categories });
});
