import jwt from 'jsonwebtoken';

export function generateToken(userId) {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT_SECRET is missing. Add it to backend/.env before starting the API.');
  }

  return jwt.sign({ userId: userId.toString() }, secret, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
}
