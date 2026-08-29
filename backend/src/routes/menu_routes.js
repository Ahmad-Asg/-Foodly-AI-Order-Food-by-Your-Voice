import { Router } from 'express';
import { getMenu } from '../controllers/menu_controller.js';

export const menuRouter = Router();
menuRouter.get('/', getMenu);
