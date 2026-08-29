import mongoose from 'mongoose';

const foodItemSchema = new mongoose.Schema(
  {
    restaurantId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: true,
      index: true,
    },
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true,
      index: true,
    },
    name: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    price: { type: Number, required: true, min: 0 },
    ingredients: { type: [String], default: [] },
    spiceLevel: {
      type: String,
      enum: ['none', 'mild', 'medium', 'hot', 'extra_hot'],
      default: 'mild',
    },
    dietaryTags: { type: [String], default: [] },
    rating: { type: Number, min: 0, max: 5, default: 0 },
    image: { type: String, default: null },
    isAvailable: { type: Boolean, default: true },
  },
  { timestamps: true },
);

foodItemSchema.index({ restaurantId: 1, name: 1 }, { unique: true });
foodItemSchema.index({ restaurantId: 1, categoryId: 1, isAvailable: 1 });

export const FoodItem = mongoose.model('FoodItem', foodItemSchema);
