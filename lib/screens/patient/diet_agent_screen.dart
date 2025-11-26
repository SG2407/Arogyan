import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/services/ai/ai_service.dart' show AiService, UserRole;
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/widgets/chat_message.dart';
import 'package:aarogyan/widgets/chat_history_dialog.dart';

class DietAgentScreen extends StatefulWidget {
  const DietAgentScreen({Key? key}) : super(key: key);

  @override
  State<DietAgentScreen> createState() => _DietAgentScreenState();
}

class _DietAgentScreenState extends State<DietAgentScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = SessionService.getCurrentUserId();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_userId == null) return;

    try {
      final chatsBox = Hive.box<dynamic>('chats');
      final userChats = chatsBox.get(_userId) ?? [];

      if (userChats is List) {
        final dietMessages = userChats
            .whereType<Map<dynamic, dynamic>>()
            .where((msg) => msg['agent'] == 'diet' || msg['agent'] == null)
            .map((msg) => {
                  'role': msg['role'] ?? '',
                  'content': msg['content'] ?? '',
                  'timestamp': msg['timestamp'],
                  'agent': 'diet',
                })
            .toList();

        if (dietMessages.isNotEmpty) {
          setState(() {
            _messages.clear();
            _messages.addAll(dietMessages);
          });
          return;
        }
      }
    } catch (e) {
      // Fallback if error
    }

    // Show greeting if no history
    if (_messages.isEmpty) {
      _messages.add({
        'role': 'assistant',
        'content':
            'Hello! I\'m your Diet Assistant. I can help you with personalized diet recommendations based on your health conditions and goals. What would you like to know about your diet?',
        'agent': 'diet',
      });
    }
  }

  Future<void> _saveMessage(Map<String, dynamic> message) async {
    if (_userId == null) return;

    try {
      final chatsBox = Hive.box<dynamic>('chats');
      final userChats = List.from(chatsBox.get(_userId) ?? []);
      userChats.add(message);
      await chatsBox.put(_userId, userChats);
    } catch (e) {
      // Silently fail if can't save
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) return;

    _messageController.clear();

    final userMsg = {
      'role': 'user',
      'content': message,
      'timestamp': DateTime.now().toIso8601String(),
      'agent': 'diet',
    };

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    await _saveMessage(userMsg);

    try {
      final response = await AiService.getAiResponse(message, UserRole.patient);
      final assistantMsg = {
        'role': 'assistant',
        'content': response,
        'timestamp': DateTime.now().toIso8601String(),
        'agent': 'diet',
      };

      setState(() {
        _messages.add(assistantMsg);
        _isLoading = false;
      });

      await _saveMessage(assistantMsg);
    } catch (e) {
      final errorMsg = {
        'role': 'assistant',
        'content':
            'I apologize, but I encountered an issue. Please try again later.',
        'timestamp': DateTime.now().toIso8601String(),
        'agent': 'diet',
      };

      setState(() {
        _messages.add(errorMsg);
        _isLoading = false;
      });

      await _saveMessage(errorMsg);
    }
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => ChatHistoryDialog(
        messages: _messages,
        title: 'Diet Assistant',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Safely get language with fallback to 'en'
    String lang = 'en';
    try {
      lang = context.read<LanguageProvider>().languageCode;
    } catch (_) {
      lang = 'en';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('dietAgent', lang)),
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: _showHistory,
          tooltip: 'View history',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Thinking...',
                                style: TextStyle(
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final msgIndex = _isLoading ? index - 1 : index;
                final msg = _messages.reversed.toList()[msgIndex];
                return ChatMessage(
                  message: msg['content'] as String,
                  isUser: msg['role'] == 'user',
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: AppStrings.get('askDiet', lang),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
