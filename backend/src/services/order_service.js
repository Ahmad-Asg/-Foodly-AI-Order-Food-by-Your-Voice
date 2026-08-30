import mongoose from 'mongoose';

import { Cart } from '../models/cart.js';
import { Order } from '../models/order.js';
import { AppError } from '../utils/app_error.js';
import { clearCart, getCartDetails } from './cart_service.js';

function toOrderResponse(order) {
  const source = order.toObject ? order.toObject() : order;
  return {
    id: source._id.toString(),
    items: source.items.map((item) => ({
      foodItemId: item.foodItemId.toString(),
      name: item.name,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      lineTotal: item.unitPrice * item.quantity,
    })),
    subtotal: source.subtotal,
    deliveryFee: source.deliveryFee,
    total: source.total,
    status: source.status,
    deliveryAddress: source.deliveryAddress,
    paymentMethod: source.paymentMethod,
    createdAt: source.createdAt,
  };
}

export async function createOrderFromCart(userId, { deliveryAddress, paymentMethod = 'cash_on_delivery' }) {
  const cart = await Cart.findOne({ userId });
  if (!cart || cart.items.length === 0) throw new AppError('Your cart is empty.', 400);

  const normalizedAddress = typeof deliveryAddress === 'string' ? deliveryAddress.trim() : '';
  if (!normalizedAddress) throw new AppError('A delivery address is required.', 400);

  const cartDetails = await getCartDetails(userId);
  const order = await Order.create({
    userId,
    items: cartDetails.items.map((item) => ({
      foodItemId: item.foodItemId,
      name: item.food.name,
      unitPrice: item.food.price,
      quantity: item.quantity,
    })),
    subtotal: cartDetails.subtotal,
    deliveryFee: cartDetails.deliveryFee,
    total: cartDetails.total,
    deliveryAddress: normalizedAddress,
    paymentMethod: paymentMethod === 'cash_on_delivery' ? paymentMethod : 'cash_on_delivery',
    status: 'placed',
  });

  await clearCart(userId);
  return toOrderResponse(order);
}

export async function getUserOrders(userId) {
  const orders = await Order.find({ userId }).sort({ createdAt: -1 }).lean();
  return orders.map(toOrderResponse);
}

export async function getUserOrderById(userId, orderId) {
  if (!mongoose.isValidObjectId(orderId)) throw new AppError('Order ID is invalid.', 400);
  const order = await Order.findOne({ _id: orderId, userId }).lean();
  if (!order) throw new AppError('Order not found.', 404);
  return toOrderResponse(order);
}
