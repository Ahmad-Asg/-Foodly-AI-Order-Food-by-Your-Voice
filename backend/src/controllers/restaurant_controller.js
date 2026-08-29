import { getPrimaryRestaurant } from '../services/restaurant_service.js';
import { asyncHandler } from '../utils/async_handler.js';

export const getRestaurant = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await getPrimaryRestaurant() });
});
