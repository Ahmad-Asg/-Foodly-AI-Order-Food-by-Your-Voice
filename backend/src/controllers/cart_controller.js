import { addCartItem, clearCart, getCartDetails, removeCartItem, updateCartItem } from '../services/cart_service.js';
import { asyncHandler } from '../utils/async_handler.js';

export const getCart = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await getCartDetails(request.user._id) });
});

export const addItem = asyncHandler(async (request, response) => {
  const { foodItemId, quantity = 1 } = request.body;
  response.status(200).json({ success: true, data: await addCartItem(request.user._id, foodItemId, quantity) });
});

export const updateItem = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await updateCartItem(request.user._id, request.params.foodItemId, request.body.quantity) });
});

export const removeItem = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await removeCartItem(request.user._id, request.params.foodItemId) });
});

export const clear = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await clearCart(request.user._id) });
});
