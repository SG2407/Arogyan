import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  static IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'anxious':
        return Icons.mood_bad;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  static Color _getEmotionColor(String emotion, ColorScheme colorScheme) {
    switch (emotion) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'anxious':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      default:
        return colorScheme.onSecondaryContainer;
    }
  }

  final String message;
  final bool isUser;
  final String? emotion;

  const ChatMessage({
    Key? key,
    required this.message,
    required this.isUser,
    this.emotion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emotion != null && !isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getEmotionIcon(emotion!),
                      size: 16,
                      color: _getEmotionColor(emotion!, colorScheme),
                    ),
                    SizedBox(width: 4),
                    Text(
                      emotion!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getEmotionColor(emotion!, colorScheme),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: isUser
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
