import OpenAI from 'openai';

import { AppError } from '../utils/app_error.js';
import { executeAiTool, findMenuMatchesForMessage, foodlyTools } from './ai_tool_service.js';

const recentMessageLimit = 12;
const maximumToolRounds = 4;
const defaultModel = 'openai/gpt-5-mini';
const maxCompletionTokens = 700;

const foodlyInstructions = `You are Foodly AI for one restaurant in Faisalabad. Use backend tools for every menu, food-detail, cart total, cart change, and order action. For every recommendation or request for a named food/category, call search_food before replying. Never say an item is unavailable unless search_food returned no matching live menu items. Tool results are the only source of truth: never invent food, prices, availability, cart state, totals, or order status.

Before adding, updating, or removing an item, resolve it with a trusted tool result and use the real food ID. If a reference is materially ambiguous, ask a concise clarification. Never claim an action succeeded unless its tool result says it succeeded. Never expose raw tool payloads.

You can ask to clear a cart or place an order through tools, but the backend requires an explicit user confirmation immediately after its confirmation request. For an order, obtain a delivery address first. If a tool says requiresConfirmation, show the current total/items concisely and ask the user to confirm. If it says requiresDeliveryAddress, ask for the delivery address. If it says emptyCart, explain that the cart is empty.

Keep answers friendly and concise. Understand English, Roman Urdu, and mixed language; match the user's style when practical. All money is Pakistani rupees: always write **Rs. 800** and never use the ₹ symbol or INR. When mentioning a menu item with its price, use Markdown bold: **Item name** — **Rs. 650**.`;

function cleanText(value) {
  return String(value ?? '').trim();
}

function addBoldFormatting(value, expression) {
  return value.replace(expression, (match, offset, source) => {
    const before = source.substring(Math.max(0, offset - 2), offset);
    const after = source.substring(offset + match.length, offset + match.length + 2);
    return before === '**' || after === '**' ? match : `**${match}**`;
  });
}

function formatPrices(reply) {
  const pakistaniCurrency = reply
    .replace(/[₹₨]\s*/g, 'Rs. ')
    .replace(/\bINR\s*/gi, 'Rs. ')
    .replace(/\bIndian rupees?\b/gi, 'Pakistani rupees');
  return addBoldFormatting(pakistaniCurrency, /\b(?:Rs\.?|PKR)\s?[\d,]+/gi);
}

function incorrectlyClaimsNoMenuMatch(reply) {
  return /\b(no|didn't find|couldn't find|cannot find|nahi|nahin)\b[\s\S]{0,100}\b(item|items|food|foods|available|mila|mil)\b|\b(item|items|food|foods|burger|burgers|pizza|pizzas|drink|drinks|dessert|desserts)\b[\s\S]{0,100}\b(no|not|nahi|nahin|mil)\b|\bkuch bhi nahi mila\b/i.test(reply);
}

function menuFallback(items) {
  const choices = items.slice(0, 5).map((item) => `**${item.name}** — **Rs. ${item.price}**`).join('\n');
  return `Here are available options from the live menu:\n${choices}`;
}

function getClient() {
  if (!process.env.OPENROUTER_API_KEY) throw new AppError('Foodly AI is not configured yet. Add OPENROUTER_API_KEY to backend/.env.', 503);
  return new OpenAI({ apiKey: process.env.OPENROUTER_API_KEY, baseURL: 'https://openrouter.ai/api/v1', timeout: 30_000, maxRetries: 0 });
}

function toModelMessages(messages) {
  return messages.slice(-recentMessageLimit).map((message) => ({
    role: message.role === 'assistant' ? 'assistant' : 'user',
    content: cleanText(message.content),
  }));
}

function providerError(error) {
  console.error('OpenRouter request failed:', { name: error?.name ?? 'UnknownError', status: error?.status ?? null, code: error?.code ?? null, type: error?.type ?? null });
  if (error?.status === 429) return new AppError('Foodly AI has reached its OpenRouter rate limit. Please try again later.', 503);
  if (error?.status === 402) return new AppError('Foodly AI needs OpenRouter credits before it can reply. Please check the OpenRouter account.', 503);
  if (error?.status === 401 || error?.status === 403) return new AppError('Foodly AI could not verify its OpenRouter API key. Check OPENROUTER_API_KEY in backend/.env.', 503);
  if (error?.status === 404) return new AppError('Foodly AI model is unavailable. Check OPENROUTER_MODEL in backend/.env.', 503);
  return new AppError('Foodly AI is temporarily unavailable. Please try again.', 503);
}

export async function getFoodlyAiReply({ messages, userId, conversation, latestUserMessage }) {
  const modelMessages = [{ role: 'system', content: foodlyInstructions }, ...toModelMessages(messages)];
  let verifiedMenuMatches = [];
  try {
    // A database read is cheap and keeps menu facts authoritative even when a
    // provider chooses not to call a tool for a natural-language request.
    verifiedMenuMatches = await findMenuMatchesForMessage(latestUserMessage);
    if (verifiedMenuMatches.length) {
      const menuPreview = verifiedMenuMatches.map(({ name, price, category }) => ({ name, price, category }));
      modelMessages[0].content += `\nVerified live menu matches for the latest user message: ${JSON.stringify(menuPreview)}. Use these matches and never say they are unavailable.`;
    }
    for (let round = 0; round < maximumToolRounds; round += 1) {
      const completion = await getClient().chat.completions.create({
        model: process.env.OPENROUTER_MODEL || defaultModel,
        messages: modelMessages,
        tools: foodlyTools,
        tool_choice: 'auto',
        max_completion_tokens: maxCompletionTokens,
        reasoning: { effort: 'minimal' },
        stream: false,
      });
      const assistant = completion.choices?.[0]?.message;
      if (!assistant) throw new AppError('Foodly AI returned an empty reply. Please try again.', 502);
      if (!assistant.tool_calls?.length) {
        const reply = formatPrices(cleanText(assistant.content));
        if (!reply) throw new AppError('Foodly AI returned an empty reply. Please try again.', 502);
        if (verifiedMenuMatches.length && incorrectlyClaimsNoMenuMatch(reply)) return menuFallback(verifiedMenuMatches);
        return reply;
      }
      modelMessages.push({ role: 'assistant', content: assistant.content ?? '', tool_calls: assistant.tool_calls });
      for (const call of assistant.tool_calls) {
        let arguments_ = {};
        try { arguments_ = JSON.parse(call.function.arguments || '{}'); } catch { arguments_ = {}; }
        const result = await executeAiTool({ name: call.function.name, arguments_, userId, conversation, latestUserMessage });
        if (call.function.name === 'search_food' && result.ok && Array.isArray(result.data)) verifiedMenuMatches = result.data;
        modelMessages.push({ role: 'tool', tool_call_id: call.id, content: JSON.stringify(result) });
      }
    }
    throw new AppError('Foodly AI could not complete that request. Please try again.', 503);
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw providerError(error);
  }
}
