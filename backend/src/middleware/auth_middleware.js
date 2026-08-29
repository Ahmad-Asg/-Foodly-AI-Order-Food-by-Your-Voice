import jwt from 'jsonwebtoken';

import { User } from '../models/user.js';
import { AppError } from '../utils/app_error.js';
import { asyncHandler } from '../utils/async_handler.js';

export const requireAuth = asyncHandler(async (request, response, next) => {
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith('Bearer ')) {
    throw new AppError('Authentication required.', 401);
  }

  try {
    const token = authorization.substring('Bearer '.length);
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(payload.userId);
    if (!user) throw new Error('User no longer exists.');

    request.user = user;
    next();
  } catch (error) {
    throw new AppError('Authentication required.', 401);
  }
});
