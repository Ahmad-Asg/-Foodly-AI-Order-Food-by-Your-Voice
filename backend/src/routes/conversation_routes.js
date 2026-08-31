import { Router } from 'express';

import { create, getById, list, remove, sendMessage } from '../controllers/conversation_controller.js';
import { requireAuth } from '../middleware/auth_middleware.js';

export const conversationRouter = Router();
conversationRouter.use(requireAuth);
conversationRouter.post('/', create);
conversationRouter.get('/', list);
conversationRouter.get('/:id', getById);
conversationRouter.post('/:id/messages', sendMessage);
conversationRouter.delete('/:id', remove);
