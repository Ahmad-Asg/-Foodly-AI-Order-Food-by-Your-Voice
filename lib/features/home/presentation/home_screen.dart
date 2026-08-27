import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming in the next step.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            'Good evening, Ahmad!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Not sure what to eat? Let Foodly AI help.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [FoodlyColors.primary, Color(0xFFFF9A5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 18),
                const Text(
                  'What are you craving today?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask in English, Urdu, or Roman Urdu.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: FoodlyColors.primary,
                        ),
                        onPressed: () => _showComingSoon(context, 'AI Chat'),
                        icon: const Icon(Icons.chat_bubble_rounded),
                        label: const Text('Chat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () => _showComingSoon(context, 'AI Voice'),
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('Talk'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Try asking Foodly AI',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _PromptChip(label: 'Find me something spicy'),
              _PromptChip(label: 'I have Rs. 1000'),
              _PromptChip(label: 'What should I eat?'),
              _PromptChip(label: 'Recommend dinner for two'),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Explore categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _CategoryCard(
                  icon: Icons.lunch_dining_rounded,
                  label: 'Burgers',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _CategoryCard(
                  icon: Icons.local_pizza_rounded,
                  label: 'Pizza',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _CategoryCard(
                  icon: Icons.rice_bowl_rounded,
                  label: 'Pakistani',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Coming soon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFE5D9),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: FoodlyColors.primary,
                ),
              ),
              title: Text('Personalized food recommendations'),
              subtitle: Text('Based on your taste, budget, and favorites.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.auto_awesome_rounded, size: 17),
      label: Text(label),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('We will ask: "$label"')),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(icon, color: FoodlyColors.primary, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}