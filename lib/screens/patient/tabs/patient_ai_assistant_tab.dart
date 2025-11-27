import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aarogyan/services/ai/ai_service.dart';
import 'package:aarogyan/services/speech/speech_service.dart';
import 'package:aarogyan/services/emotion/emotion_analysis.dart';
import 'package:aarogyan/widgets/chat_message.dart';
import 'package:aarogyan/services/chat_service.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/widgets/chat_history_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class PatientAiAssistantTab extends StatefulWidget {
  const PatientAiAssistantTab({Key? key}) : super(key: key);

  @override
  _PatientAiAssistantTabState createState() => _PatientAiAssistantTabState();
}

class _PatientAiAssistantTabState extends State<PatientAiAssistantTab> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _isLoading = false;
  String _currentEmotion = 'neutral';
  String? _selectedImageBase64;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final userId = SessionService.getCurrentUserId();
    if (userId != null) {
      final saved = ChatService.getMessages(userId);
      if (saved.isNotEmpty) {
        _messages.addAll(saved.where((msg) => msg['agent'] == 'assistant'));
      } else {
        _addWelcomeMessage();
      }
    } else {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    _messages.add({
      'role': 'assistant',
      'content':
          'Hello! I\'m your health assistant. I can help you understand health issues and provide general guidance. How can I help you today?',
      'timestamp': DateTime.now().toIso8601String(),
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
    if (message.isEmpty && _selectedImageBase64 == null) return;

    _messageController.clear();

    if (message.isNotEmpty &&
        _selectedImageBase64 == null &&
        !AiService.isHealthRelatedQuery(message)) {
      setState(() {
        _messages.add({
          'role': 'user',
          'content': message,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _messages.add({
          'role': 'assistant',
          'content':
              'I can only help you with health-related questions. Please ask something about your health or medical care.',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      return;
    }

    setState(() {
      _messages.add({
        'role': 'user',
        'content': message,
        'photoBase64': _selectedImageBase64,
        'timestamp': DateTime.now().toIso8601String(),
        'agent': 'assistant',
      });
      _isLoading = true;
    });

    final userId = SessionService.getCurrentUserId();
    if (userId != null) {
      await ChatService.saveMessage(userId, {
        'role': 'user',
        'content': message,
        'photoBase64': _selectedImageBase64,
        'timestamp': DateTime.now().toIso8601String(),
        'agent': 'assistant',
      });
    }

    _analyzeEmotion(message);
    _selectedImageBase64 = null;

    try {
      final response = await AiService.getAiResponse(message, UserRole.patient);
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': response,
          'timestamp': DateTime.now().toIso8601String(),
          'agent': 'assistant',
        });
        _isLoading = false;
      });

      if (userId != null) {
        await ChatService.saveMessage(userId, {
          'role': 'assistant',
          'content': response,
          'timestamp': DateTime.now().toIso8601String(),
          'agent': 'assistant',
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              'I apologize, but I encountered an issue while processing your request. Please try rephrasing your question or try again later.',
          'timestamp': DateTime.now().toIso8601String(),
          'agent': 'assistant',
        });
        _isLoading = false;
      });
    }
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => ChatHistoryDialog(
        messages: _messages,
        title: 'AI Assistant',
      ),
    );
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

  Future<void> _captureImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _analyzeEmotion(String text) {
    final emotions = EmotionAnalysis.analyzeText(text);
    final predominantEmotion = EmotionAnalysis.getPredominantEmotion(emotions);

    if (_currentEmotion != predominantEmotion) {
      setState(() {
        _currentEmotion = predominantEmotion;
      });

      _messages.add({
        'role': 'assistant',
        'content': EmotionAnalysis.getEmotionalResponse(predominantEmotion),
        'emotion': predominantEmotion,
        'timestamp': DateTime.now().toIso8601String(),
        'agent': 'assistant',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text('AI Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient');
            }
          },
          tooltip: 'Go back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'View history',
          ),
        ],
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
                                'Analyzing your health query...',
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
          if (_selectedImageBase64 != null)
            Container(
              padding: const EdgeInsets.all(8),
              height: 100,
              child: Image.memory(
                base64Decode(_selectedImageBase64!),
                fit: BoxFit.cover,
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
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Capture photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _captureImage();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Choose from gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImageFromGallery();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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
                      contentPadding: const EdgeInsets.symmetric(
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
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
