import OpenAI from 'openai';

import { Category } from '../models/category.js';
import { FoodItem } from '../models/food_item.js';
import { AppError } from '../utils/app_error.js';
import { getPrimaryRestaurant } from './restaurant_service.js';

const recentMessageLimit = 12;
const defaultModel = 'openai/gpt-5-mini';
const maxCompletionTokens = 700;

const foodlyInstructions = `You are Foodly AI, the helpful food assistant for one restaurant only: Foodly AI Restaurant in Faisalabad.

Use the live menu context below as the only source of truth for restaurant and food facts. Never invent food names, prices, ingredients, spice levels, dietary tags, availability, categories, delivery information, or restaurant information. Do not recommend an unavailable item as orderable. If a requested item or fact is absent from the menu context, clearly say it is not available or you do not know.

Help with menu questions, comparisons, budgets, preferences, and natural food recommendations. Keep answers friendly, concise, and useful. Use PKR/Rs. prices accurately. Understand English, Roman Urdu, and mixed English/Roman Urdu, and reply in a matching style where practical.

You cannot add items to a cart, edit a cart, or place an order in this phase. If asked to perform one of those actions, explain briefly that the user can use the app's Menu and Cart screens manually. Never claim an action was completed.`;

function cleanText(value) {
  return String(value ?? '').trim();
}

async function getMenuContext() {
  const restaurant = await getPrimaryRestaurant();
  const [categories, foods] = await Promise.all([
    Category.find({ restaurantId: restaurant._id }).sort({ sortOrder: 1 }).lean(),
    FoodItem.find({ restaurantId: restaurant._id }).sort({ name: 1 }).lean(),
  ]);

  const categoryNames = new Map(categories.map((category) => [category._id.toString(), category.name]));
  const compactFoods = foods.map((food) => ({
    id: food._id.toString(),
    name: food.name,
    description: food.description,
    price: food.price,
    category: categoryNames.get(food.categoryId.toString()) ?? 'Uncategorized',
    ingredients: food.ingredients,
    spiceLevel: food.spiceLevel,
    dietaryTags: food.dietaryTags,
    isAvailable: food.isAvailable,
  }));

  return JSON.stringify({
    restaurant: {
      name: restaurant.name,
      location: restaurant.location,
      cuisine: restaurant.cuisine,
      deliveryFee: restaurant.deliveryFee,
      isOpen: restaurant.isOpen,
    },
    menu: compactFoods,
  });
}

function getClient() {
  if (!process.env.OPENROUTER_API_KEY) {
    throw new AppError('Foodly AI is not configured yet. Add OPENROUTER_API_KEY to backend/.env.', 503);
  }
  return new OpenAI({
    apiKey: process.env.OPENROUTER_API_KEY,
    baseURL: 'https://openrouter.ai/api/v1',
    timeout: 30_000,
    maxRetries: 0,
  });
}

export async function getFoodlyAiReply(messages) {
  const menuContext = await getMenuContext();
  const conversationContext = messages.slice(-recentMessageLimit).map((message) => (
    `${message.role === 'assistant' ? 'Foodly AI' : 'User'}: ${cleanText(message.content)}`
  )).join('\n');

  try {
    const completion = await getClient().chat.completions.create({
      model: process.env.OPENROUTER_MODEL || defaultModel,
      messages: [
        {
          role: 'system',
          content: `${foodlyInstructions}\n\nLIVE MENU CONTEXT (authoritative JSON):\n${menuContext}`,
        },
        {
          role: 'user',
          content: `RECENT CONVERSATION:\n${conversationContext}\n\nReply to the latest user message only.`,
        },
      ],
      max_completion_tokens: maxCompletionTokens,
      reasoning: { effort: 'minimal' },
      stream: false,
    });
    const reply = cleanText(completion.choices?.[0]?.message?.content);
    if (!reply) throw new AppError('Foodly AI returned an empty reply. Please try again.', 502);
    return reply;
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('OpenRouter request failed:', {
      name: error?.name ?? 'UnknownError',
      status: error?.status ?? null,
      code: error?.code ?? null,
      type: error?.type ?? null,
    });
    if (error?.status === 429) {
      throw new AppError('Foodly AI has reached its OpenRouter rate limit. Please try again later.', 503);
    }
    if (error?.status === 402) {
      throw new AppError('Foodly AI needs OpenRouter credits before it can reply. Please check the OpenRouter account.', 503);
    }
    if (error?.status === 401 || error?.status === 403) {
      throw new AppError('Foodly AI could not verify its OpenRouter API key. Check OPENROUTER_API_KEY in backend/.env.', 503);
    }
    if (error?.status === 404) {
      throw new AppError('Foodly AI model is unavailable. Check OPENROUTER_MODEL in backend/.env.', 503);
    }
    if (error?.name === 'APIConnectionTimeoutError' || error?.name === 'APIConnectionError') {
      throw new AppError('Foodly AI could not reach OpenRouter. Please try again.', 503);
    }
    throw new AppError('Foodly AI is temporarily unavailable. Please try again.', 503);
  }
}
