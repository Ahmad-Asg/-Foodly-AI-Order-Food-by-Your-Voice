const categoryDefinitions = [
  ['Burgers', 'Fresh burgers with crisp fries on the side.', 1, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'],
  ['Pizza', 'Hand-stretched pizzas with generous toppings.', 2, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38'],
  ['Pakistani', 'Comforting Pakistani favourites cooked to order.', 3, 'https://images.unsplash.com/photo-1631515242808-497c3fbd3972'],
  ['BBQ', 'Charcoal-grilled chicken, kebabs, and sharing platters.', 4, 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd'],
  ['Chinese', 'Desi Chinese classics with bold sauces and wok flavour.', 5, 'https://images.unsplash.com/photo-1525755662778-989d0524087e'],
  ['Fast Food', 'Quick bites, wraps, fries, and sides.', 6, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877'],
  ['Desserts', 'Sweet finishes for every meal.', 7, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587'],
  ['Drinks', 'Chilled soft drinks and refreshing coolers.', 8, 'https://images.unsplash.com/photo-1544145945-f90425340c7e'],
  ['Deals', 'Value meals made for one or to share.', 9, 'https://images.unsplash.com/photo-1526367790999-0150786686a2'],
];

export const categories = categoryDefinitions.map(([name, description, sortOrder, image]) => ({
  name,
  description,
  sortOrder,
  image: `${image}?auto=format&fit=crop&w=900&q=80`,
}));

const item = (category, name, description, price, ingredients, spiceLevel, dietaryTags, rating) => ({
  category,
  name,
  description,
  price,
  ingredients,
  spiceLevel,
  dietaryTags,
  rating,
  isAvailable: true,
});

export const menuItems = [
  item('Burgers', 'Zinger Burger', 'Crispy chicken fillet, lettuce, mayo, and house sauce.', 650, ['chicken fillet', 'bun', 'lettuce', 'mayo'], 'medium', ['halal'], 4.5),
  item('Burgers', 'Spicy Zinger Burger', 'Crunchy chicken fillet with jalapeños and spicy mayo.', 700, ['chicken fillet', 'jalapeños', 'bun', 'spicy mayo'], 'hot', ['halal'], 4.7),
  item('Burgers', 'Chicken Cheese Burger', 'Grilled chicken patty, cheddar, lettuce, and garlic sauce.', 620, ['chicken patty', 'cheddar', 'bun', 'garlic sauce'], 'mild', ['halal'], 4.3),
  item('Burgers', 'Beef Smash Burger', 'Double smashed beef patties with caramelised onions and cheese.', 850, ['beef patties', 'cheddar', 'onion', 'bun'], 'medium', ['halal'], 4.6),
  item('Burgers', 'Mighty Double Chicken Burger', 'Two crispy chicken fillets with cheese and signature sauce.', 950, ['chicken fillets', 'cheddar', 'bun', 'signature sauce'], 'medium', ['halal'], 4.6),
  item('Burgers', 'Veggie Burger', 'Crispy vegetable patty with fresh lettuce and herb mayo.', 480, ['vegetable patty', 'bun', 'lettuce', 'herb mayo'], 'mild', ['vegetarian'], 4.1),

  item('Pizza', 'Chicken Tikka Pizza', 'Tandoori chicken tikka, onions, capsicum, and mozzarella.', 1250, ['chicken tikka', 'mozzarella', 'onion', 'capsicum'], 'medium', ['halal'], 4.6),
  item('Pizza', 'Chicken Fajita Pizza', 'Fajita chicken, onions, capsicum, olives, and cheese.', 1300, ['fajita chicken', 'mozzarella', 'onion', 'capsicum', 'olives'], 'medium', ['halal'], 4.5),
  item('Pizza', 'Pepperoni Pizza', 'Beef pepperoni, tomato sauce, and stretchy mozzarella.', 1450, ['beef pepperoni', 'tomato sauce', 'mozzarella'], 'mild', ['halal'], 4.5),
  item('Pizza', 'Four Cheese Pizza', 'Mozzarella, cheddar, feta, parmesan, and herb butter.', 1200, ['mozzarella', 'cheddar', 'feta', 'parmesan'], 'none', ['vegetarian'], 4.2),
  item('Pizza', 'Creamy Garlic Chicken Pizza', 'Creamy garlic sauce, chicken chunks, mushrooms, and cheese.', 1400, ['chicken', 'garlic sauce', 'mushrooms', 'mozzarella'], 'mild', ['halal'], 4.7),
  item('Pizza', 'Vegetable Supreme Pizza', 'Mushrooms, olives, onions, sweet corn, and capsicum.', 1100, ['mushrooms', 'olives', 'sweet corn', 'capsicum'], 'mild', ['vegetarian'], 4.1),

  item('Pakistani', 'Chicken Biryani', 'Fragrant basmati rice with spiced chicken, potato, and raita.', 480, ['chicken', 'basmati rice', 'potato', 'biryani masala'], 'medium', ['halal'], 4.7),
  item('Pakistani', 'Chicken Karahi Half', 'Wok-cooked chicken karahi with tomatoes, ginger, and green chilli.', 1250, ['chicken', 'tomatoes', 'ginger', 'green chilli'], 'hot', ['halal', 'gluten-free'], 4.6),
  item('Pakistani', 'Beef Karahi Half', 'Tender beef cooked in a rich tomato and black pepper karahi masala.', 1550, ['beef', 'tomatoes', 'black pepper', 'ginger'], 'medium', ['halal', 'gluten-free'], 4.5),
  item('Pakistani', 'Chicken Pulao', 'Aromatic yakhni rice with tender chicken and salad.', 450, ['chicken', 'rice', 'yakhni stock', 'spices'], 'mild', ['halal'], 4.2),
  item('Pakistani', 'Daal Makhani', 'Slow-cooked black lentils with cream, butter, and warming spices.', 390, ['black lentils', 'cream', 'butter', 'spices'], 'mild', ['vegetarian', 'gluten-free'], 4.3),
  item('Pakistani', 'Chana Chaat', 'Chickpeas, potato, tomato, chutneys, and fresh coriander.', 320, ['chickpeas', 'potato', 'tomato', 'chutneys'], 'medium', ['vegetarian', 'vegan', 'gluten-free'], 4.0),

  item('BBQ', 'Chicken Tikka', 'Two charcoal-grilled chicken pieces marinated in tikka spices.', 550, ['chicken', 'yogurt', 'tikka spices'], 'medium', ['halal', 'gluten-free'], 4.4),
  item('BBQ', 'Chicken Malai Boti', 'Creamy, tender chicken cubes grilled over charcoal.', 700, ['chicken', 'cream', 'yogurt', 'cashew'], 'mild', ['halal', 'gluten-free'], 4.6),
  item('BBQ', 'Chicken Seekh Kebab', 'Two juicy minced-chicken kebabs with herbs and spices.', 520, ['minced chicken', 'onion', 'coriander', 'spices'], 'medium', ['halal', 'gluten-free'], 4.3),
  item('BBQ', 'Beef Seekh Kebab', 'Two smoky beef kebabs served with mint chutney.', 620, ['minced beef', 'onion', 'coriander', 'spices'], 'medium', ['halal', 'gluten-free'], 4.4),
  item('BBQ', 'BBQ Platter', 'Chicken tikka, malai boti, seekh kebab, naan, and chutneys.', 1650, ['chicken tikka', 'malai boti', 'seekh kebab', 'naan'], 'medium', ['halal'], 4.8),
  item('BBQ', 'Grilled Fish Tikka', 'Spiced boneless fish fillet grilled with lemon and herbs.', 850, ['fish', 'lemon', 'herbs', 'spices'], 'mild', ['halal', 'gluten-free'], 4.2),

  item('Chinese', 'Chicken Manchurian with Rice', 'Crispy chicken in tangy Manchurian sauce with egg fried rice.', 750, ['chicken', 'capsicum', 'Manchurian sauce', 'rice'], 'medium', ['halal'], 4.5),
  item('Chinese', 'Chicken Chow Mein', 'Wok-tossed noodles with chicken and crunchy vegetables.', 620, ['noodles', 'chicken', 'cabbage', 'carrot'], 'mild', ['halal'], 4.3),
  item('Chinese', 'Chicken Chilli Dry', 'Stir-fried chicken, peppers, onion, and hot chilli sauce.', 780, ['chicken', 'capsicum', 'onion', 'chilli sauce'], 'hot', ['halal'], 4.6),
  item('Chinese', 'Sweet and Sour Chicken', 'Crispy chicken with pineapple and a tangy sweet-and-sour sauce.', 760, ['chicken', 'pineapple', 'capsicum', 'sweet and sour sauce'], 'mild', ['halal'], 4.2),
  item('Chinese', 'Vegetable Fried Rice', 'Wok-fried rice with egg, vegetables, soy, and spring onion.', 430, ['rice', 'egg', 'carrot', 'peas', 'soy sauce'], 'mild', ['vegetarian'], 4.0),
  item('Chinese', 'Hot and Sour Soup', 'Chicken, vegetables, egg ribbons, and a peppery sour broth.', 300, ['chicken', 'egg', 'vegetables', 'vinegar'], 'hot', ['halal'], 4.1),

  item('Fast Food', 'Spicy Chicken Wrap', 'Crispy chicken strips, lettuce, jalapeños, and spicy sauce.', 550, ['chicken strips', 'tortilla', 'lettuce', 'jalapeños'], 'hot', ['halal'], 4.5),
  item('Fast Food', 'Chicken Shawarma', 'Marinated chicken, garlic sauce, pickles, and fries in pita.', 420, ['chicken', 'pita', 'garlic sauce', 'pickles'], 'medium', ['halal'], 4.4),
  item('Fast Food', 'Loaded Fries', 'Crispy fries topped with chicken, cheese sauce, and jalapeños.', 500, ['fries', 'chicken', 'cheese sauce', 'jalapeños'], 'medium', ['halal'], 4.4),
  item('Fast Food', 'Chicken Nuggets', 'Eight golden chicken nuggets served with a dip.', 450, ['chicken', 'breadcrumbs', 'seasoning'], 'mild', ['halal'], 4.1),
  item('Fast Food', 'Masala Fries', 'Crispy fries tossed in tangy desi masala.', 250, ['potatoes', 'masala', 'salt'], 'medium', ['vegetarian', 'vegan', 'gluten-free'], 4.2),
  item('Fast Food', 'Club Sandwich', 'Triple-decker chicken sandwich with egg, cheese, and fries.', 620, ['chicken', 'bread', 'egg', 'cheese', 'fries'], 'mild', ['halal'], 4.3),

  item('Desserts', 'Chocolate Brownie', 'Warm fudgy chocolate brownie with a chocolate drizzle.', 300, ['dark chocolate', 'flour', 'butter', 'egg'], 'none', ['vegetarian'], 4.5),
  item('Desserts', 'Molten Lava Cake', 'Soft chocolate cake with a gooey molten centre.', 380, ['dark chocolate', 'flour', 'butter', 'egg'], 'none', ['vegetarian'], 4.6),
  item('Desserts', 'Lotus Cheesecake', 'Creamy cheesecake layered with Lotus biscuit crumble.', 420, ['cream cheese', 'Lotus biscuit', 'cream', 'butter'], 'none', ['vegetarian'], 4.7),
  item('Desserts', 'Vanilla Ice Cream', 'Two scoops of smooth vanilla ice cream.', 220, ['milk', 'cream', 'vanilla', 'sugar'], 'none', ['vegetarian', 'gluten-free'], 4.0),
  item('Desserts', 'Kheer', 'Traditional chilled rice pudding with cardamom and almonds.', 250, ['rice', 'milk', 'sugar', 'cardamom', 'almonds'], 'none', ['vegetarian', 'gluten-free'], 4.2),
  item('Desserts', 'Gulab Jamun', 'Four soft milk dumplings soaked in cardamom syrup.', 240, ['milk solids', 'flour', 'sugar syrup', 'cardamom'], 'none', ['vegetarian'], 4.3),

  item('Drinks', 'Pepsi', 'Chilled 345 ml Pepsi can.', 120, ['carbonated water', 'cola flavour'], 'none', ['vegan', 'gluten-free'], 4.0),
  item('Drinks', 'Coke', 'Chilled 345 ml Coca-Cola can.', 120, ['carbonated water', 'cola flavour'], 'none', ['vegan', 'gluten-free'], 4.0),
  item('Drinks', 'Sprite', 'Chilled 345 ml lemon-lime soft drink.', 120, ['carbonated water', 'lemon-lime flavour'], 'none', ['vegan', 'gluten-free'], 4.0),
  item('Drinks', 'Fresh Lime', 'Fresh lime, mint, soda, and a touch of salt.', 220, ['lime', 'mint', 'soda', 'salt'], 'none', ['vegan', 'gluten-free'], 4.4),
  item('Drinks', 'Mango Shake', 'Thick chilled mango shake made with milk and mango pulp.', 280, ['mango pulp', 'milk', 'sugar'], 'none', ['vegetarian', 'gluten-free'], 4.5),
  item('Drinks', 'Mineral Water', 'Sealed 500 ml mineral water bottle.', 70, ['water'], 'none', ['vegan', 'gluten-free'], 4.0),

  item('Deals', 'Zinger Deal', 'Zinger Burger, regular fries, and a chilled drink.', 850, ['zinger burger', 'fries', 'soft drink'], 'medium', ['halal'], 4.6),
  item('Deals', 'Wrap Deal', 'Spicy chicken wrap, masala fries, and a chilled drink.', 760, ['chicken wrap', 'fries', 'soft drink'], 'hot', ['halal'], 4.5),
  item('Deals', 'Biryani Deal', 'Chicken biryani, raita, and a chilled drink.', 580, ['chicken biryani', 'raita', 'soft drink'], 'medium', ['halal'], 4.7),
  item('Deals', 'Pizza Duo Deal', 'Two regular chicken tikka pizzas and two chilled drinks.', 2300, ['chicken tikka pizza', 'soft drinks'], 'medium', ['halal'], 4.6),
  item('Deals', 'Family BBQ Deal', 'BBQ platter, chicken biryani, naan, and four drinks.', 3200, ['BBQ platter', 'biryani', 'naan', 'soft drinks'], 'medium', ['halal'], 4.8),
  item('Deals', 'Dessert Duo', 'Chocolate brownie and lotus cheesecake for two.', 650, ['brownie', 'Lotus cheesecake'], 'none', ['vegetarian'], 4.5),
];
