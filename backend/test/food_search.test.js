import assert from 'node:assert/strict';
import test from 'node:test';

import {
  categoryMatchesFoodSearch,
  foodSearchExpressions,
  foodSearchTokens,
} from '../src/services/food_search.js';

test('food search normalizes case and singular/plural category wording', () => {
  assert.equal(categoryMatchesFoodSearch('Burgers', 'burger'), true);
  assert.equal(categoryMatchesFoodSearch('Burgers', 'BURGERS'), true);
  assert.equal(categoryMatchesFoodSearch('Desserts', 'dessert'), true);
  assert.equal(categoryMatchesFoodSearch('Fast Food', 'fast food'), true);
});

test('food search keeps meaningful words from natural-language requests', () => {
  assert.deepEqual(foodSearchTokens('Mujhe koi chicken burger suggest kro'), ['chicken', 'burger']);
  assert.deepEqual(foodSearchTokens('Show me drinks, please'), ['drink']);
  assert.deepEqual(foodSearchTokens('BBQ mein kya hai?'), ['bbq']);
  assert.deepEqual(foodSearchTokens('Pakistani food dikhao'), ['pakistani']);
  assert.deepEqual(foodSearchTokens('Suggest me a burger'), ['burger']);
  assert.deepEqual(foodSearchTokens('Mujhe menu mein burgers nahin mil rahe'), ['burger']);
});

test('food search expressions match relevant food fields without exact capitalization', () => {
  const expressions = foodSearchExpressions('Chicken burgers');
  assert.equal(expressions.some((expression) => expression.test('Chicken Cheese Burger')), true);
  assert.equal(expressions.some((expression) => expression.test('crispy chicken fillet')), true);
});
