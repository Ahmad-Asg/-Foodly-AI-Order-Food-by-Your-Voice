import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/services/foodly_api_service.dart';
import '../../../core/theme/app_theme.dart';

String _pakistaniCurrency(String value) => value
    .replaceAll(RegExp(r'[₹₨]\s*'), 'Rs. ')
    .replaceAll(RegExp(r'\bINR\s*', caseSensitive: false), 'Rs. ')
    .replaceAll(RegExp(r'\bIndian rupees?\b', caseSensitive: false), 'Pakistani rupees');

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, required this.api, this.onCartChanged, this.startListening = false});

  final FoodlyApiService api;
  final Future<void> Function()? onCartChanged;
  final bool startListening;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();
  List<dynamic> _conversations = const [];
  List<dynamic> _messages = const [];
  String? _conversationId;
  bool _isThinking = false;
  bool _isLoadingHistory = true;
  bool _isListening = false;
  bool _isSendingVoice = false;
  String _speechLocale = 'en_US';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _tts.setSpeechRate(0.46);
    if (widget.startListening) WidgetsBinding.instance.addPostFrameCallback((_) => _toggleListening());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await widget.api.getConversations();
      if (mounted) {
        setState(() => _conversations = conversations);
      }
    } on FoodlyApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if (mounted && (status == 'done' || status == 'notListening')) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice input: ${error.errorMsg}')),
        );
      },
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition or microphone permission is unavailable. You can still type your message.')),
        );
      }
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        localeId: _speechLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
      ),
      onResult: (result) {
        if (!mounted || result.recognizedWords.trim().isEmpty) return;
        if (result.finalResult) _sendVoiceMessage(result.recognizedWords);
      },
    );
  }

  Future<void> _sendVoiceMessage(String transcript) async {
    if (_isSendingVoice || _isThinking || transcript.trim().isEmpty) return;
    setState(() {
      _isSendingVoice = true;
      _isListening = false;
    });
    await _speech.stop();
    await _sendMessage(suggestedMessage: transcript, isVoiceInput: true);
    if (mounted) setState(() => _isSendingVoice = false);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    final language = RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? 'ur_PK' : 'en_US';
    if (await _tts.isLanguageAvailable(language) == true) {
      await _tts.setLanguage(language);
    }
    await _tts.speak(_pakistaniCurrency(text).replaceAll('**', '').replaceAll('`', ''));
  }

  Future<void> _openConversation(String id) async {
    setState(() => _isLoadingHistory = true);
    try {
      final data = await widget.api.getConversation(id);
      if (!mounted) return;
      setState(() {
        _conversationId = id;
        _messages = data['messages'] as List<dynamic>? ?? const [];
      });
      _scrollToNewest();
    } on FoodlyApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _newChat() async {
    setState(() {
      _conversationId = null;
      _messages = const [];
    });
  }

  Future<void> _sendMessage({String? suggestedMessage, bool isVoiceInput = false}) async {
    final message = (suggestedMessage ?? _controller.text).trim();
    if (message.isEmpty || _isThinking) return;

    setState(() {
      _isThinking = true;
      _controller.clear();
    });
    try {
      var conversationId = _conversationId;
      if (conversationId == null) {
        final conversation = await widget.api.createConversation();
        conversationId = conversation['id'] as String;
        if (mounted) {
          setState(() => _conversationId = conversationId);
        }
      }
      if (!mounted) return;
      setState(
        () => _messages = [
          ..._messages,
          {'role': 'user', 'content': message, 'isVoiceInput': isVoiceInput},
        ],
      );
      _scrollToNewest();
      final result = await widget.api.sendConversationMessage(
        conversationId: conversationId,
        message: message,
        isVoiceInput: isVoiceInput,
      );
      await widget.onCartChanged?.call();
      if (!mounted) return;
      setState(
        () => _messages = [
          ..._messages,
          result['assistantMessage'] as Map<String, dynamic>,
        ],
      );
      _scrollToNewest();
      _loadConversations();
    } on FoodlyApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isThinking = false);
      }
    }
  }

  Future<void> _deleteConversation(String id) async {
    try {
      await widget.api.deleteConversation(id);
      if (!mounted) return;
      if (_conversationId == id) {
        await _newChat();
      }
      await _loadConversations();
    } on FoodlyApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  void _scrollToNewest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _conversationId == null ? 'New chat' : 'Current chat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isThinking ? null : _newChat,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('New'),
                ),
                IconButton(
                  tooltip: 'Chat history',
                  onPressed: _showHistory,
                  icon: const Icon(Icons.history_rounded),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Voice language',
                  icon: const Icon(Icons.language_rounded),
                  onSelected: (locale) => setState(() => _speechLocale = locale),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'en_US', child: Text('English')),
                    PopupMenuItem(value: 'ur_PK', child: Text('Urdu')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildMessages()),
          if (_messages.isEmpty && !_isLoadingHistory)
            _SuggestedPrompts(
              onSelected: (message) => _sendMessage(suggestedMessage: message),
            ),
          _ChatInput(
            controller: _controller,
            isSending: _isThinking,
            isListening: _isListening,
            onSend: () => _sendMessage(),
            onMic: _toggleListening,
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    final visibleMessages = _messages.where((message) {
      final item = message as Map<String, dynamic>;
      return item['role'] != 'user' || item['isVoiceInput'] != true;
    }).toList();
    if (visibleMessages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 54,
                color: FoodlyColors.primary,
              ),
              SizedBox(height: 14),
              Text(
                'Hey! What are you craving today?',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: visibleMessages.length + (_isThinking ? 1 : 0),
      itemBuilder: (_, index) {
        if (_isThinking && index == visibleMessages.length) {
          return const _ThinkingBubble();
        }
        final message = visibleMessages[index] as Map<String, dynamic>;
        return _MessageBubble(
          content: message['content'] as String,
          isUser: message['role'] == 'user',
          onSpeak: message['role'] == 'user'
              ? null
              : () => _speak(message['content'] as String),
        );
      },
    );
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: 420,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_comment_outlined),
                title: const Text('Start a new chat'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _newChat();
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: _conversations.isEmpty
                    ? const Center(
                        child: Text('No previous conversations yet.'),
                      )
                    : ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (_, index) {
                          final conversation =
                              _conversations[index] as Map<String, dynamic>;
                          final id = conversation['id'] as String;
                          return ListTile(
                            leading: const Icon(
                              Icons.chat_bubble_outline_rounded,
                            ),
                            title: Text(
                              conversation['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              _openConversation(id);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: 'Delete chat',
                              onPressed: () async {
                                Navigator.pop(sheetContext);
                                await _deleteConversation(id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.content, required this.isUser, this.onSpeak});
  final String content;
  final bool isUser;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) => Align(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(color: isUser ? Colors.white : FoodlyColors.dark),
              children: _displaySpans(content),
            ),
          ),
          if (onSpeak != null)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Speak reply',
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_outlined),
                iconSize: 20,
              ),
            ),
        ],
      ),
    ),
  );

  List<TextSpan> _displaySpans(String value) {
    final parts = _pakistaniCurrency(value).replaceAll('`', '').split('**');
    return List.generate(
      parts.length,
      (index) => TextSpan(
        text: parts[index],
        style: index.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text('Foodly AI is thinking...'),
    ),
  );
}

class _SuggestedPrompts extends StatelessWidget {
  const _SuggestedPrompts({required this.onSelected});
  final Future<void> Function(String) onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _SuggestionButton(
          label: 'Something spicy',
          onPressed: () => onSelected('Mujhe koi spicy food suggest karo'),
        ),
        _SuggestionButton(
          label: 'Under Rs. 1000',
          onPressed: () => onSelected('What can I get under Rs. 1000?'),
        ),
        _SuggestionButton(
          label: 'Chicken options',
          onPressed: () => onSelected('Show me chicken options'),
        ),
      ],
    ),
  );
}

class _SuggestionButton extends StatelessWidget {
  const _SuggestionButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: OutlinedButton(onPressed: onPressed, child: Text(label)),
  );
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.isSending,
    required this.isListening,
    required this.onSend,
    required this.onMic,
  });
  final TextEditingController controller;
  final bool isSending;
  final bool isListening;
  final Future<void> Function() onSend;
  final Future<void> Function() onMic;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: TextField(
      controller: controller,
      enabled: !isSending,
      maxLength: 1200,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSend(),
      decoration: InputDecoration(
        hintText: isListening ? 'Listening... speak your request' : 'Ask Foodly AI...',
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isListening ? 'Stop listening' : 'Speak',
              onPressed: isSending ? null : onMic,
              icon: Icon(isListening ? Icons.stop_circle_outlined : Icons.mic_none_rounded),
              color: isListening ? FoodlyColors.primary : null,
            ),
            IconButton(
              onPressed: isSending ? null : () => onSend(),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    ),
  );
}
