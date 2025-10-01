import 'package:flutter/material.dart';
import 'package:aarogyan/services/ai/ai_service.dart';
import 'package:aarogyan/services/speech/speech_service.dart';
import 'package:aarogyan/services/emotion/emotion_analysis.dart';
import 'package:aarogyan/widgets/chat_message.dart';

class DoctorAiAssistantTab extends StatefulWidget {
  const DoctorAiAssistantTab({Key? key}) : super(key: key);

  @override
  State<DoctorAiAssistantTab> createState() => _DoctorAiAssistantTabState();
}

class _DoctorAiAssistantTabState extends State<DoctorAiAssistantTab> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'content':
          'Hello Doctor! I\'m your medical AI assistant. I can help you analyze patient data, medical research, and more. How can I help you today?',
    });
  }

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
                              'Processing...',
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
                message: message['content'] as String,
                isUser: message['role'] == 'user',
                emotion: message['emotion'] as String?,
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
              IconButton(
                onPressed: _toggleListening,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? colorScheme.primary : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
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
                onPressed: _handleSend,
                child: Icon(Icons.send),
                mini: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
