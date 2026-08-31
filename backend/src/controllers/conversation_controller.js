import {
  createConversation,
  deleteConversation,
  getConversation,
  listConversations,
  sendConversationMessage,
} from '../services/conversation_service.js';
import { asyncHandler } from '../utils/async_handler.js';

export const create = asyncHandler(async (request, response) => {
  response.status(201).json({ success: true, data: await createConversation(request.user._id) });
});

export const list = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await listConversations(request.user._id) });
});

export const getById = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await getConversation(request.user._id, request.params.id) });
});

export const sendMessage = asyncHandler(async (request, response) => {
  response.status(200).json({ success: true, data: await sendConversationMessage(request.user._id, request.params.id, request.body.message) });
});

export const remove = asyncHandler(async (request, response) => {
  await deleteConversation(request.user._id, request.params.id);
  response.status(200).json({ success: true, data: { deleted: true } });
});
