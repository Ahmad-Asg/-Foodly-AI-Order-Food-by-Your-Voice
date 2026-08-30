import { createOrderFromCart, getUserOrderById, getUserOrders } from '../services/order_service.js';
import { asyncHandler } from '../utils/async_handler.js';

export const createOrder = asyncHandler(async (request, response) => {
  response.status(201).json({
    success: true,
    data: await createOrderFromCart(request.user._id, request.body),
  });
});

export const getOrders = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await getUserOrders(request.user._id) });
});

export const getOrderById = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await getUserOrderById(request.user._id, request.params.id) });
});
