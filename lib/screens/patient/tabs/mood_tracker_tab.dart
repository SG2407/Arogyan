import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aarogyan/services/mood_analysis_service.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:intl/intl.dart';

class MoodTrackerTab extends StatefulWidget {
  const MoodTrackerTab({Key? key}) : super(key: key);

  @override
  State<MoodTrackerTab> createState() => _MoodTrackerTabState();
}

class _MoodTrackerTabState extends State<MoodTrackerTab> {
  late String _userId;
  late Future<List<MoodEntry>> _moodEntriesFuture;

  @override
  void initState() {
    super.initState();
    _userId = SessionService.getCurrentUserId() ?? '';
    _moodEntriesFuture = MoodAnalysisService.getMoodEntries(_userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _moodEntriesFuture = MoodAnalysisService.getMoodEntries(_userId);
          });
        },
        child: FutureBuilder<List<MoodEntry>>(
          future: _moodEntriesFuture,
          builder: (context, snapshot) {
            print(
                'DEBUG: Mood tracker - snapshot state: ${snapshot.connectionState}');
            if (snapshot.hasError) {
              print('DEBUG: Mood tracker error: ${snapshot.error}');
            }
            if (snapshot.hasData) {
              print('DEBUG: Mood tracker data count: ${snapshot.data?.length}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final moods = snapshot.data ?? [];

            if (moods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mood,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No mood data yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your feelings in the Emotional Diary\nto get mood analysis here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Latest Mood Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Mood',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMoodCard(moods.first, theme, colorScheme),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mood Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood Statistics',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<Map<MoodType, int>>(
                          future:
                              MoodAnalysisService.getMoodStatistics(_userId),
                          builder: (context, statsSnapshot) {
                            if (!statsSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final stats = statsSnapshot.data!;
                            final total = stats.values.fold<int>(
                              0,
                              (sum, count) => sum + count,
                            );

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMoodStat(
                                  context,
                                  'Very Happy',
                                  stats[MoodType.veryHappy] ?? 0,
                                  total,
                                  Icons.sentiment_very_satisfied,
                                  Colors.green,
                                ),
                                _buildMoodStat(
                                  context,
                                  'Happy',
                                  stats[MoodType.happy] ?? 0,
                                  total,
                                  Icons.sentiment_satisfied,
                                  Colors.lightGreen,
                                ),
                                _buildMoodStat(
                                  context,
                                  'Neutral',
                                  stats[MoodType.neutral] ?? 0,
                                  total,
                                  Icons.sentiment_neutral,
                                  Colors.amber,
                                ),
                                _buildMoodStat(
                                  context,
                                  'Sad',
                                  stats[MoodType.sad] ?? 0,
                                  total,
                                  Icons.sentiment_dissatisfied,
                                  Colors.orange,
                                ),
                                _buildMoodStat(
                                  context,
                                  'Very Sad',
                                  stats[MoodType.verySad] ?? 0,
                                  total,
                                  Icons.sentiment_very_dissatisfied,
                                  Colors.red,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mood History
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood History',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: moods.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMoodHistoryItem(
                                moods[index],
                                theme,
                                colorScheme,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoodCard(
    MoodEntry mood,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final moodColor = MoodAnalysisService.getMoodColor(mood.mood, colorScheme);
    final moodLabel = MoodAnalysisService.getMoodLabel(mood.mood);
    final moodIcon = MoodAnalysisService.getMoodIcon(mood.mood);

    return Column(
      children: [
        Row(
          children: [
            Icon(
              moodIcon,
              size: 48,
              color: moodColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moodLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: moodColor,
                    ),
                  ),
                  Text(
                    'Score: ${mood.moodScore}/5',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy - HH:mm').format(mood.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: moodColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analysis:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mood.analysis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodHistoryItem(
    MoodEntry mood,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final moodColor = MoodAnalysisService.getMoodColor(mood.mood, colorScheme);
    final moodLabel = MoodAnalysisService.getMoodLabel(mood.mood);
    final moodIcon = MoodAnalysisService.getMoodIcon(mood.mood);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            moodIcon,
            size: 32,
            color: moodColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moodLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(mood.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${mood.moodScore}/5',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: moodColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStat(
    BuildContext context,
    String label,
    int count,
    int total,
    IconData icon,
    Color color,
  ) {
    final percentage =
        total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';

    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
