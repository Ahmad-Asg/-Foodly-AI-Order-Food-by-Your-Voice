import { Router } from 'express';
import { getFoodById, getFoods } from '../controllers/food_controller.js';

export const foodRouter = Router();
foodRouter.get('/', getFoods);
foodRouter.get('/:id', getFoodById);
