const ignoredWords = new Set([
  'a', 'an', 'and', 'any', 'are', 'can', 'do', 'for', 'food', 'hai', 'haan', 'have',
  'i', 'in', 'is', 'it', 'ka', 'ke', 'ki', 'koi', 'ko', 'kro', 'kuch', 'kya',
  'kar', 'karo', 'krdo', 'mein', 'me', 'menu', 'mil', 'mujhe', 'nahi', 'nahin', 'of',
  'option', 'options', 'please', 'restaurant', 'show', 'suggest', 'the', 'to',
  'raha', 'rahe', 'rahi', 'wala', 'wali', 'you', 'your', 'andar', 'btao', 'dikhao', 'chahiye',
]);

export function normalizeFoodSearchText(value) {
  return String(value ?? '')
    .trim()
    .toLocaleLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

export function singularizeFoodSearchWord(value) {
  const word = normalizeFoodSearchText(value);
  return word.length > 3 && word.endsWith('s') ? word.slice(0, -1) : word;
}

export function foodSearchTokens(value) {
  return [...new Set(normalizeFoodSearchText(value)
    .split(' ')
    .filter((word) => word.length > 1 && !ignoredWords.has(word))
    .map(singularizeFoodSearchWord))];
}

export function categoryMatchesFoodSearch(categoryName, query) {
  const categoryWords = foodSearchTokens(categoryName);
  const queryWords = new Set(foodSearchTokens(query));
  return categoryWords.length > 0 && categoryWords.every((word) => queryWords.has(word));
}

export function foodSearchExpressions(query) {
  return foodSearchTokens(query)
    .slice(0, 6)
    .map((word) => new RegExp(word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i'));
}
