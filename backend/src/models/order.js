import mongoose from 'mongoose';

const orderItemSchema = new mongoose.Schema(
  {
    foodItemId: { type: mongoose.Schema.Types.ObjectId, ref: 'FoodItem', required: true },
    name: { type: String, required: true },
    unitPrice: { type: Number, required: true, min: 0 },
    quantity: { type: Number, required: true, min: 1 },
  },
  { _id: false },
);

const orderSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    items: { type: [orderItemSchema], required: true, validate: (items) => items.length > 0 },
    subtotal: { type: Number, required: true, min: 0 },
    deliveryFee: { type: Number, required: true, min: 0 },
    total: { type: Number, required: true, min: 0 },
    deliveryAddress: { type: String, trim: true, required: true },
    paymentMethod: { type: String, default: 'cash_on_delivery' },
    status: {
      type: String,
      enum: ['placed', 'accepted', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled'],
      default: 'placed',
    },
  },
  { timestamps: true },
);

export const Order = mongoose.model('Order', orderSchema);
