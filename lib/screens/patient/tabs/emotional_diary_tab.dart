import 'package:flutter/material.dart';

class EmotionalDiaryTab extends StatelessWidget {
  const EmotionalDiaryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Entry',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'How are you feeling?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var emotion in ['Happy', 'Sad', 'Anxious', 'Calm'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(emotion),
                          selected: false,
                          onSelected: (bool selected) {},
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save Entry'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Previous Entries',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 1; i <= 5; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('Feeling ${i % 2 == 0 ? 'Happy' : 'Calm'}'),
              subtitle: Text('Today at ${10 - i}:00 AM'),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  i % 2 == 0
                      ? Icons.sentiment_satisfied
                      : Icons.sentiment_neutral,
                  color: colorScheme.primary,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ),
          ),
      ],
    );
  }
}
