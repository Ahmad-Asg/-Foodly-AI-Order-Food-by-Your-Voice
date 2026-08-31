import mongoose from 'mongoose';

const conversationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true, maxlength: 120 },
    pendingAction: {
      type: { type: String, enum: ['clear_cart', 'create_order'], default: null },
      cartSignature: { type: String, default: null },
      deliveryAddress: { type: String, default: null },
    },
  },
  { timestamps: true },
);

export const Conversation = mongoose.model('Conversation', conversationSchema);
