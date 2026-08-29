import { Router } from 'express';
import { getCategories } from '../controllers/category_controller.js';

export const categoryRouter = Router();
categoryRouter.get('/', getCategories);
