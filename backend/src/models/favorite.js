import mongoose from 'mongoose';

const favoriteSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    foodItemId: { type: mongoose.Schema.Types.ObjectId, ref: 'FoodItem', required: true },
  },
  { timestamps: true },
);

favoriteSchema.index({ userId: 1, foodItemId: 1 }, { unique: true });

export const Favorite = mongoose.model('Favorite', favoriteSchema);
