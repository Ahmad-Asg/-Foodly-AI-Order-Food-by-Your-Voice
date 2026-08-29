import mongoose from 'mongoose';

const preferencesSchema = new mongoose.Schema(
  {
    favoriteCuisine: { type: [String], default: [] },
    preferredSpiceLevel: {
      type: String,
      enum: ['none', 'mild', 'medium', 'hot', 'extra_hot'],
      default: null,
    },
    budgetRange: {
      min: { type: Number, min: 0, default: null },
      max: { type: Number, min: 0, default: null },
    },
    dietaryPreferences: { type: [String], default: [] },
  },
  { _id: false },
);

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, trim: true, lowercase: true, unique: true },
    passwordHash: { type: String, required: true, select: false },
    preferences: { type: preferencesSchema, default: () => ({}) },
  },
  { timestamps: true },
);

export const User = mongoose.model('User', userSchema);
