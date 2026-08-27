import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AiVoiceScreen extends StatefulWidget {
  const AiVoiceScreen({super.key});

  @override
  State<AiVoiceScreen> createState() => _AiVoiceScreenState();
}

class _AiVoiceScreenState extends State<AiVoiceScreen> {
  bool _isListening = false;
  String _status = 'Tap the microphone to start';
  String _transcript = 'Your voice transcript will appear here.';
  String _response = '';

  Future<void> _toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _status = 'Voice session stopped';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _status = 'Listening...';
      _transcript = 'Listening to you...';
      _response = '';
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted || !_isListening) {
      return;
    }

    setState(() {
      _isListening = false;
      _status = 'Foodly AI is thinking...';
      _transcript = '“Mujhe 1000 rupay ke andar kuch spicy khana hai.”';
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    setState(() {
      _status = 'Foodly AI is ready';
      _response =
          'Bilkul! Database connect hone ke baad Foodly AI aapko real spicy options dikhayega.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Talk to Foodly AI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _isListening ? 184 : 148,
                height: _isListening ? 184 : 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? FoodlyColors.primary.withValues(alpha: 0.22)
                      : FoodlyColors.primary,
                ),
                child: IconButton(
                  onPressed: _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 62,
                    color: _isListening ? FoodlyColors.primary : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _status,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mock voice mode for Phase 3',
                style: TextStyle(color: Colors.black54),
              ),
              const Spacer(),
              _InfoCard(
                title: 'You said',
                text: _transcript,
                icon: Icons.record_voice_over_rounded,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Foodly AI',
                text: _response.isEmpty
                    ? 'Foodly AI will reply here.'
                    : _response,
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.text,
    required this.icon,
  });

  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: FoodlyColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}