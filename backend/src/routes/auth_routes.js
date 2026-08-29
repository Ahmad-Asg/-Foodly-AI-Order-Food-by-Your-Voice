import { Router } from 'express';

import { getCurrentUser, login, register, updateCurrentUser } from '../controllers/auth_controller.js';
import { requireAuth } from '../middleware/auth_middleware.js';

export const authRouter = Router();
authRouter.post('/register', register);
authRouter.post('/login', login);
authRouter.get('/me', requireAuth, getCurrentUser);
authRouter.patch('/me', requireAuth, updateCurrentUser);
