import { Router } from 'express';

import { addItem, clear, getCart, removeItem, updateItem } from '../controllers/cart_controller.js';
import { requireAuth } from '../middleware/auth_middleware.js';

export const cartRouter = Router();
cartRouter.use(requireAuth);
cartRouter.get('/', getCart);
cartRouter.post('/items', addItem);
cartRouter.patch('/items/:foodItemId', updateItem);
cartRouter.delete('/items/:foodItemId', removeItem);
cartRouter.delete('/', clear);
