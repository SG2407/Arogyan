import 'package:flutter/material.dart';

class ChatHistoryDialog extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final String title;

  const ChatHistoryDialog({
    Key? key,
    required this.messages,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filter out system messages and group by conversations
    final conversations = _groupConversations(messages);

    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: Text('$title History'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: conversations.isEmpty
            ? Center(
                child: Text(
                  'No conversation history',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ExpansionTile(
                      title: Text(
                        conv['summary'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        conv['date'],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(conv['messages'].length, (i) {
                                final msg = conv['messages'][i];
                                final isUser = msg['role'] == 'user';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? colorScheme.primary
                                                : colorScheme
                                                    .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            msg['content'],
                                            style: TextStyle(
                                              color: isUser
                                                  ? colorScheme.onPrimary
                                                  : colorScheme
                                                      .onSecondaryContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupConversations(
      List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return [];

    final conversations = <Map<String, dynamic>>[];
    List<Map<String, dynamic>> currentConversation = [];

    for (final msg in messages) {
      if (msg['role'] == 'user') {
        currentConversation.add(msg);
      } else {
        currentConversation.add(msg);
        // End conversation on assistant response if more than one exchange
        if (currentConversation.length >= 2) {
          conversations.add({
            'messages': List.from(currentConversation),
            'summary': _getSummary(currentConversation),
            'date': _formatDate(currentConversation.first['timestamp']),
          });
          currentConversation = [];
        }
      }
    }

    // Add remaining conversation if any
    if (currentConversation.isNotEmpty) {
      conversations.add({
        'messages': currentConversation,
        'summary': _getSummary(currentConversation),
        'date': _formatDate(currentConversation.first['timestamp']),
      });
    }

    return conversations.reversed.toList();
  }

  String _getSummary(List<Map<String, dynamic>> messages) {
    final userMsg = messages.firstWhere(
      (m) => m['role'] == 'user',
      orElse: () => {'content': 'Conversation'},
    );
    final content = userMsg['content'] as String;
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      final date = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
