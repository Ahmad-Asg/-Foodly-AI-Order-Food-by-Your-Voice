import cors from 'cors';
import express from 'express';

import { errorHandler } from './middleware/error_handler.js';
import { notFound } from './middleware/not_found.js';
import { authRouter } from './routes/auth_routes.js';
import { categoryRouter } from './routes/category_routes.js';
import { cartRouter } from './routes/cart_routes.js';
import { foodRouter } from './routes/food_routes.js';
import { healthRouter } from './routes/health_routes.js';
import { menuRouter } from './routes/menu_routes.js';
import { orderRouter } from './routes/order_routes.js';
import { restaurantRouter } from './routes/restaurant_routes.js';

export const app = express();
app.use(cors());
app.use(express.json({ limit: '100kb' }));
app.use('/api/auth', authRouter);
app.use('/api/cart', cartRouter);
app.use('/api/orders', orderRouter);
app.use('/api/health', healthRouter);
app.use('/api/restaurant', restaurantRouter);
app.use('/api/categories', categoryRouter);
app.use('/api/foods', foodRouter);
app.use('/api/menu', menuRouter);
app.use(notFound);
app.use(errorHandler);
