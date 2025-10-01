import 'package:flutter/material.dart';
import 'package:aarogyan/services/ai/ai_service.dart';
import 'package:aarogyan/services/speech/speech_service.dart';
import 'package:aarogyan/widgets/chat_message.dart';

class AiAssistantTab extends StatefulWidget {
  const AiAssistantTab({Key? key}) : super(key: key);

  @override
  _AiAssistantTabState createState() => _AiAssistantTabState();
}

class _AiAssistantTabState extends State<AiAssistantTab> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isListening = false;
  bool _isLoading = false;
  final SpeechService _speechService = SpeechService();

  @override
  void dispose() {
    _messageController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      _messageController.clear();

      if (!AiService.isHealthRelatedQuery(message)) {
        setState(() {
          _messages.add({
            'role': 'user',
            'content': message,
          });
          _messages.add({
            'role': 'assistant',
            'content':
                'I can only assist with medical and health-related queries. Please ask something related to healthcare or medical practice.',
          });
        });
        return;
      }

      setState(() {
        _messages.add({
          'role': 'user',
          'content': message,
        });
        _isLoading = true;
      });

      try {
        final response =
            await AiService.getAiResponse(message, UserRole.doctor);
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': response,
          });
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          print('Error in AI response: $e');
          _messages.add({
            'role': 'assistant',
            'content':
                'I apologize, but I encountered an issue while processing your request. Please try rephrasing your question or try again later.',
          });
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      final success = await _speechService.startListening((text) {
        setState(() {
          _isListening = false;
          _messageController.text = text;
        });
        _handleSend();
      });

      setState(() {
        _isListening = success;
      });
    } else {
      _speechService.stopListening();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
                        padding: EdgeInsets.all(12),
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
                            SizedBox(width: 8),
                            Text(
                              'Analyzing medical query...',
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

              final messageIndex = _isLoading ? index - 1 : index;
              final message = _messages.reversed.toList()[messageIndex];
              return ChatMessage(
                message: message['content']!,
                isUser: message['role'] == 'user',
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your medical query...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _isListening ? null : _toggleListening,
                mini: true,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _isLoading ? null : _handleSend,
                child: Icon(_isLoading ? Icons.hourglass_empty : Icons.send),
                mini: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
