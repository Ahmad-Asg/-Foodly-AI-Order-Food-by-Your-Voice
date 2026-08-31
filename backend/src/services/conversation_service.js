import mongoose from 'mongoose';

import { Conversation } from '../models/conversation.js';
import { Message } from '../models/message.js';
import { AppError } from '../utils/app_error.js';
import { getFoodlyAiReply } from './ai_service.js';

const messageMaximumLength = 1200;

function toConversationSummary(conversation) {
  return {
    id: conversation._id.toString(),
    title: conversation.title,
    createdAt: conversation.createdAt,
    updatedAt: conversation.updatedAt,
  };
}

function toMessage(message) {
  return {
    id: message._id.toString(),
    role: message.role,
    content: message.content,
    timestamp: message.timestamp,
  };
}

function validateMessage(content) {
  if (typeof content !== 'string' || !content.trim()) throw new AppError('A message is required.', 400);
  if (content.trim().length > messageMaximumLength) throw new AppError(`Messages must be ${messageMaximumLength} characters or fewer.`, 400);
  return content.trim();
}

function titleFromMessage(content) {
  return content.length <= 56 ? content : `${content.substring(0, 53).trim()}...`;
}

async function getOwnedConversation(userId, conversationId) {
  if (!mongoose.isValidObjectId(conversationId)) throw new AppError('Conversation ID is invalid.', 400);
  const conversation = await Conversation.findOne({ _id: conversationId, userId });
  if (!conversation) throw new AppError('Conversation not found.', 404);
  return conversation;
}

export async function createConversation(userId) {
  const conversation = await Conversation.create({ userId, title: 'New Conversation' });
  return toConversationSummary(conversation);
}

export async function listConversations(userId) {
  const conversations = await Conversation.find({ userId }).sort({ updatedAt: -1 }).lean();
  return conversations.map(toConversationSummary);
}

export async function getConversation(userId, conversationId) {
  const conversation = await getOwnedConversation(userId, conversationId);
  const messages = await Message.find({ conversationId: conversation._id }).sort({ timestamp: 1 }).lean();
  return { conversation: toConversationSummary(conversation), messages: messages.map(toMessage) };
}

export async function sendConversationMessage(userId, conversationId, content) {
  const conversation = await getOwnedConversation(userId, conversationId);
  const cleanContent = validateMessage(content);
  const userMessage = await Message.create({ conversationId: conversation._id, role: 'user', content: cleanContent });
  if (conversation.title === 'New Conversation') conversation.title = titleFromMessage(cleanContent);
  await conversation.save();

  const history = await Message.find({ conversationId: conversation._id }).sort({ timestamp: 1 }).lean();
  const reply = await getFoodlyAiReply(history);
  const assistantMessage = await Message.create({ conversationId: conversation._id, role: 'assistant', content: reply });
  conversation.updatedAt = assistantMessage.timestamp;
  await conversation.save();

  return { conversation: toConversationSummary(conversation), assistantMessage: toMessage(assistantMessage) };
}

export async function deleteConversation(userId, conversationId) {
  const conversation = await getOwnedConversation(userId, conversationId);
  await Message.deleteMany({ conversationId: conversation._id });
  await conversation.deleteOne();
}
