import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Hey! What are you craving today?',
      isUser: false,
    ),
  ];

  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? suggestedMessage]) async {
    final message = (suggestedMessage ?? _controller.text).trim();

    if (message.isEmpty || _isThinking) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _isThinking = true;
      _controller.clear();
    });

    await Future<void>.delayed(const Duration(milliseconds: 850));

    if (!mounted) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: _mockReply(message),
          isUser: false,
          showRecommendation: true,
        ),
      );
      _isThinking = false;
    });
  }

  String _mockReply(String message) {
    final text = message.toLowerCase();

    if (text.contains('spicy')) {
      return 'I found a spicy option you might enjoy. This is a mock recommendation for now.';
    }

    if (text.contains('1000') || text.contains('budget')) {
      return 'Great budget! I can help you find food under Rs. 1,000 once our food database is connected.';
    }

    if (text.contains('urdu') || text.contains('mujhe')) {
      return 'Bilkul! Foodly AI Urdu aur Roman Urdu support karega.';
    }

    return 'Nice choice! In the next phases, Foodly AI will search real food data and recommend the best option.';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isThinking && index == _messages.length) {
                  return const _ThinkingBubble();
                }

                final message = _messages[index];

                return Column(
                  children: [
                    _MessageBubble(message: message),
                    if (message.showRecommendation)
                      const _MockFoodCard(),
                  ],
                );
              },
            ),
          ),
          _SuggestedPrompts(onSelected: _sendMessage),
          const SizedBox(height: 8),
          _ChatInput(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.showRecommendation = false,
  });

  final String text;
  final bool isUser;
  final bool showRecommendation;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: isUser ? FoodlyColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isUser ? null : Border.all(color: Colors.black12),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : FoodlyColors.dark),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Foodly AI is thinking...'),
      ),
    );
  }
}

class _MockFoodCard extends StatelessWidget {
  const _MockFoodCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE5D9),
          child: Icon(Icons.local_fire_department_rounded,
              color: FoodlyColors.primary),
        ),
        title: const Text('Spicy Zinger Burger'),
        subtitle: const Text('Burger House • Rs. 650 • ⭐ 4.5'),
        trailing: IconButton(
          tooltip: 'Mock add to cart',
          onPressed: () {},
          icon: const Icon(Icons.add_shopping_cart_rounded),
        ),
      ),
    );
  }
}

class _SuggestedPrompts extends StatelessWidget {
  const _SuggestedPrompts({required this.onSelected});

  final void Function(String message) onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SuggestionButton(
            label: 'Something spicy',
            onPressed: () => onSelected('Find me something spicy'),
          ),
          _SuggestionButton(
            label: 'Under Rs. 1000',
            onPressed: () => onSelected('I have Rs. 1000'),
          ),
          _SuggestionButton(
            label: 'Roman Urdu',
            onPressed: () => onSelected('Mujhe kuch acha suggest karo'),
          ),
        ],
      ),
    );
  }
}

class _SuggestionButton extends StatelessWidget {
  const _SuggestionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final Future<void> Function([String?]) onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => onSend(),
        decoration: InputDecoration(
          hintText: 'Ask Foodly AI...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            onPressed: () => onSend(),
            icon: const Icon(Icons.send_rounded),
          ),
        ),
      ),
    );
  }
}