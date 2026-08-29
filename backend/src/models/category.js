import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema(
  {
    restaurantId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: true,
      index: true,
    },
    name: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    image: { type: String, default: null },
    sortOrder: { type: Number, required: true, min: 0 },
    isAvailable: { type: Boolean, default: true },
  },
  { timestamps: true },
);

categorySchema.index({ restaurantId: 1, name: 1 }, { unique: true });

export const Category = mongoose.model('Category', categorySchema);
