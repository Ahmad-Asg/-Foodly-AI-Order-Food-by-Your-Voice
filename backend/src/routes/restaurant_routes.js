import { Router } from 'express';
import { getRestaurant } from '../controllers/restaurant_controller.js';

export const restaurantRouter = Router();
restaurantRouter.get('/', getRestaurant);
