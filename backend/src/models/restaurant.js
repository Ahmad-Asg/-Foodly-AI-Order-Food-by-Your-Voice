import mongoose from 'mongoose';

const restaurantSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    cuisine: { type: [String], required: true },
    rating: { type: Number, min: 0, max: 5, default: 0 },
    deliveryTime: { type: String, required: true },
    deliveryFee: { type: Number, required: true, min: 0 },
    location: { type: String, required: true, trim: true },
    image: { type: String, default: null },
    isOpen: { type: Boolean, default: true },
    // A unique primary flag keeps this database intentionally single-restaurant.
    isPrimary: { type: Boolean, default: true, unique: true },
  },
  { timestamps: true },
);

export const Restaurant = mongoose.model('Restaurant', restaurantSchema);
