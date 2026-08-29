import 'dotenv/config';

import { connectDatabase, disconnectDatabase } from './config/database.js';
import { categories, menuItems } from './data/menu_data.js';
import { Category } from './models/category.js';
import { FoodItem } from './models/food_item.js';
import { Restaurant } from './models/restaurant.js';

const restaurantData = {
  name: 'Foodly AI Restaurant',
  description: 'A fictional single-restaurant menu for Foodly AI development.',
  cuisine: ['Pakistani', 'Fast Food', 'BBQ', 'Chinese', 'Pizza'],
  rating: 4.6,
  deliveryTime: '30-45 min',
  deliveryFee: 120,
  location: 'Faisalabad, Pakistan',
  image: 'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80',
  isOpen: true,
  isPrimary: true,
};

async function seed() {
  await connectDatabase();

  try {
    const restaurant = await Restaurant.findOneAndUpdate(
      { isPrimary: true },
      restaurantData,
      { new: true, upsert: true, runValidators: true },
    );

    // This makes the development seed repeatable. It resets only this temporary
    // Foodly AI Restaurant menu; it does not seed or support multiple restaurants.
    await FoodItem.deleteMany({ restaurantId: restaurant._id });
    await Category.deleteMany({ restaurantId: restaurant._id });

    const createdCategories = await Category.insertMany(
      categories.map((category) => ({ ...category, restaurantId: restaurant._id })),
    );
    const categoryIds = new Map(createdCategories.map((category) => [category.name, category._id]));

    await FoodItem.insertMany(
      menuItems.map(({ category, ...foodItem }) => ({
        ...foodItem,
        restaurantId: restaurant._id,
        categoryId: categoryIds.get(category),
        image: createdCategories.find((entry) => entry.name === category).image,
      })),
    );

    console.log('Foodly AI Restaurant seed completed successfully.');
    console.log(`Created 1 restaurant, ${createdCategories.length} categories, and ${menuItems.length} food items.`);
  } finally {
    await disconnectDatabase();
  }
}

seed().catch((error) => {
  console.error(`Seed failed: ${error.message}`);
  process.exitCode = 1;
});
