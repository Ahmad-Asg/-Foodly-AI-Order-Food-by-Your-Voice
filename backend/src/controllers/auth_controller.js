import bcrypt from 'bcryptjs';

import { User } from '../models/user.js';
import { AppError } from '../utils/app_error.js';
import { asyncHandler } from '../utils/async_handler.js';
import { generateToken } from '../utils/generate_token.js';
import { toSafeUser } from '../utils/safe_user.js';

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const passwordMinimumLength = 8;

function normaliseEmail(email) {
  return String(email ?? '').trim().toLowerCase();
}

function validateRegistration({ name, email, password }) {
  if (!String(name ?? '').trim()) throw new AppError('Name is required.', 400);
  if (!emailPattern.test(normaliseEmail(email))) throw new AppError('A valid email address is required.', 400);
  if (typeof password !== 'string' || password.length < passwordMinimumLength) {
    throw new AppError(`Password must be at least ${passwordMinimumLength} characters.`, 400);
  }
}

function validateLogin({ email, password }) {
  if (!normaliseEmail(email) || typeof password !== 'string' || !password) {
    throw new AppError('Email and password are required.', 400);
  }
}

function authResponse(user) {
  return { user: toSafeUser(user), token: generateToken(user._id) };
}

export const register = asyncHandler(async (request, response) => {
  const { name, email, password } = request.body;
  validateRegistration({ name, email, password });

  const normalizedEmail = normaliseEmail(email);
  const existingUser = await User.exists({ email: normalizedEmail });
  if (existingUser) throw new AppError('An account with this email already exists.', 409);

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await User.create({
    name: name.trim(),
    email: normalizedEmail,
    passwordHash,
  });

  response.status(201).json({ success: true, data: authResponse(user) });
});

export const login = asyncHandler(async (request, response) => {
  const { email, password } = request.body;
  validateLogin({ email, password });

  const user = await User.findOne({ email: normaliseEmail(email) }).select('+passwordHash');
  const passwordMatches = user && await bcrypt.compare(password, user.passwordHash);
  if (!passwordMatches) throw new AppError('Invalid email or password.', 401);

  response.status(200).json({ success: true, data: authResponse(user) });
});

export const getCurrentUser = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: toSafeUser(request.user) });
});

export const updateCurrentUser = asyncHandler(async (request, response) => {
  const { name } = request.body;
  if (!String(name ?? '').trim()) throw new AppError('Name is required.', 400);

  request.user.name = name.trim();
  await request.user.save();
  response.status(200).json({ success: true, data: toSafeUser(request.user) });
});
