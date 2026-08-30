import { Router } from 'express';

import { createOrder, getOrderById, getOrders } from '../controllers/order_controller.js';
import { requireAuth } from '../middleware/auth_middleware.js';

export const orderRouter = Router();
orderRouter.use(requireAuth);
orderRouter.post('/', createOrder);
orderRouter.get('/', getOrders);
orderRouter.get('/:id', getOrderById);
