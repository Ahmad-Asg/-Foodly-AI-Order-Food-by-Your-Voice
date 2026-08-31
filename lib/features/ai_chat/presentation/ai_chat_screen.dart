import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';
import '../../../core/theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, required this.api});

  final FoodlyApiService api;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<dynamic> _conversations = const [];
  List<dynamic> _messages = const [];
  String? _conversationId;
  bool _isThinking = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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

  Future<void> _sendMessage([String? suggestedMessage]) async {
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
          {'role': 'user', 'content': message},
        ],
      );
      _scrollToNewest();
      final result = await widget.api.sendConversationMessage(
        conversationId: conversationId,
        message: message,
      );
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
              ],
            ),
          ),
          Expanded(child: _buildMessages()),
          if (_messages.isEmpty && !_isLoadingHistory)
            _SuggestedPrompts(onSelected: _sendMessage),
          _ChatInput(
            controller: _controller,
            isSending: _isThinking,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_messages.isEmpty) {
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
      itemCount: _messages.length + (_isThinking ? 1 : 0),
      itemBuilder: (_, index) {
        if (_isThinking && index == _messages.length) {
          return const _ThinkingBubble();
        }
        final message = _messages[index] as Map<String, dynamic>;
        return _MessageBubble(
          content: message['content'] as String,
          isUser: message['role'] == 'user',
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
  const _MessageBubble({required this.content, required this.isUser});
  final String content;
  final bool isUser;

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
      child: Text(
        _cleanDisplayText(content),
        style: TextStyle(color: isUser ? Colors.white : FoodlyColors.dark),
      ),
    ),
  );

  String _cleanDisplayText(String value) =>
      value.replaceAll('**', '').replaceAll('`', '');
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
  final Future<void> Function([String?]) onSelected;

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
    required this.onSend,
  });
  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function([String?]) onSend;

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
        hintText: 'Ask Foodly AI...',
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: isSending ? null : () => onSend(),
          icon: const Icon(Icons.send_rounded),
        ),
      ),
    ),
  );
}
