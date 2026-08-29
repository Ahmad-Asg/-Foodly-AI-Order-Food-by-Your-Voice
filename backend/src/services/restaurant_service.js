import { Restaurant } from '../models/restaurant.js';
import { AppError } from '../utils/app_error.js';

export async function getPrimaryRestaurant() {
  const restaurant = await Restaurant.findOne({ isPrimary: true }).lean();
  if (!restaurant) {
    throw new AppError('Foodly AI Restaurant has not been set up yet.', 404);
  }
  return restaurant;
}
