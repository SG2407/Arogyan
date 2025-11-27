import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:aarogyan/services/ai/ai_service.dart';

enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
}

class MoodEntry {
  final String id;
  final DateTime date;
  final MoodType mood;
  final int moodScore; // 1-5 scale
  final String analysis;
  final List<String> conversationSnippets;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.moodScore,
    required this.analysis,
    required this.conversationSnippets,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.toString(),
      'moodScore': moodScore,
      'analysis': analysis,
      'conversationSnippets': conversationSnippets,
    };
  }

  static MoodEntry fromMap(Map<dynamic, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      mood: MoodType.values.firstWhere(
        (e) => e.toString() == map['mood'],
        orElse: () => MoodType.neutral,
      ),
      moodScore: map['moodScore'] as int? ?? 3,
      analysis: map['analysis'] as String? ?? '',
      conversationSnippets:
          List<String>.from(map['conversationSnippets'] as List? ?? []),
    );
  }
}

class MoodAnalysisService {
  static Future<MoodEntry> analyzeMoodFromConversation(
    String userId,
    List<Map<String, dynamic>> messages,
  ) async {
    // Extract user messages from conversation
    final userMessages = messages
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['content'] as String)
        .toList();

    if (userMessages.isEmpty) {
      return _createDefaultMoodEntry();
    }

    // Create prompt for mood analysis
    final conversationText = userMessages.join('\n');
    final prompt =
        '''Analyze the following emotional diary entries and determine the person's mood.

Diary entries:
$conversationText

Please analyze and provide:
1. Overall mood (one of: very happy, happy, neutral, sad, very sad)
2. Mood score (1-5, where 5 is very happy and 1 is very sad)
3. Brief analysis (2-3 sentences about their emotional state)

Respond in this exact format:
MOOD: [mood]
SCORE: [score]
ANALYSIS: [analysis]''';

    try {
      final response = await AiService.getAiResponse(prompt, UserRole.patient);
      return _parseMoodResponse(response, userMessages);
    } catch (e) {
      print('Error analyzing mood: $e');
      return _createDefaultMoodEntry();
    }
  }

  static MoodEntry _parseMoodResponse(
    String response,
    List<String> conversationSnippets,
  ) {
    try {
      final lines = response.split('\n');
      String mood = 'neutral';
      int score = 3;
      String analysis = '';

      for (final line in lines) {
        if (line.startsWith('MOOD:')) {
          mood = line.substring(5).trim().toLowerCase();
        } else if (line.startsWith('SCORE:')) {
          final scoreStr = line.substring(6).trim();
          score = int.tryParse(scoreStr) ?? 3;
          score = score.clamp(1, 5);
        } else if (line.startsWith('ANALYSIS:')) {
          analysis = line.substring(9).trim();
        }
      }

      final moodType = _stringToMoodType(mood);
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      return MoodEntry(
        id: id,
        date: DateTime.now(),
        mood: moodType,
        moodScore: score,
        analysis: analysis,
        conversationSnippets: conversationSnippets.take(3).toList(),
      );
    } catch (e) {
      print('Error parsing mood response: $e');
      return _createDefaultMoodEntry();
    }
  }

  static MoodType _stringToMoodType(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
      case 'veryhappy':
        return MoodType.veryHappy;
      case 'happy':
        return MoodType.happy;
      case 'neutral':
        return MoodType.neutral;
      case 'sad':
        return MoodType.sad;
      case 'very sad':
      case 'verysad':
        return MoodType.verySad;
      default:
        return MoodType.neutral;
    }
  }

  static MoodEntry _createDefaultMoodEntry() {
    return MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      mood: MoodType.neutral,
      moodScore: 3,
      analysis: 'Start sharing your feelings to get mood analysis.',
      conversationSnippets: [],
    );
  }

  static Future<void> saveMoodEntry(String userId, MoodEntry entry) async {
    try {
      // Store moods in a Hive map with userId as key and list of moods as value
      final moodsBox = Hive.box<dynamic>('moods');
      final userMoodsData = moodsBox.get(userId);

      List<dynamic> userMoods = [];
      if (userMoodsData is List) {
        userMoods = userMoodsData;
      }

      userMoods.add(entry.toMap());
      await moodsBox.put(userId, userMoods);
    } catch (e) {
      print('Error saving mood entry: $e');
    }
  }

  static Future<List<MoodEntry>> getMoodEntries(String userId) async {
    try {
      final moodsBox = Hive.box<dynamic>('moods');
      final userMoodsData = moodsBox.get(userId);

      if (userMoodsData == null || userMoodsData is! List) {
        return [];
      }

      final moods = (userMoodsData)
          .map((mood) => MoodEntry.fromMap(mood as Map<dynamic, dynamic>))
          .toList();

      // Sort by date descending
      moods.sort((a, b) => b.date.compareTo(a.date));
      return moods;
    } catch (e) {
      print('Error getting mood entries: $e');
      return [];
    }
  }

  static Future<MoodEntry?> getLatestMoodEntry(String userId) async {
    final moods = await getMoodEntries(userId);
    return moods.isNotEmpty ? moods.first : null;
  }

  static Future<Map<MoodType, int>> getMoodStatistics(String userId) async {
    final moods = await getMoodEntries(userId);

    final stats = {
      MoodType.veryHappy: 0,
      MoodType.happy: 0,
      MoodType.neutral: 0,
      MoodType.sad: 0,
      MoodType.verySad: 0,
    };

    for (final mood in moods) {
      stats[mood.mood] = (stats[mood.mood] ?? 0) + 1;
    }

    return stats;
  }

  static IconData getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return Icons.sentiment_very_satisfied;
      case MoodType.happy:
        return Icons.sentiment_satisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.verySad:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  static Color getMoodColor(MoodType mood, ColorScheme colorScheme) {
    switch (mood) {
      case MoodType.veryHappy:
        return Colors.green;
      case MoodType.happy:
        return Colors.lightGreen;
      case MoodType.neutral:
        return Colors.amber;
      case MoodType.sad:
        return Colors.orange;
      case MoodType.verySad:
        return Colors.red;
    }
  }

  static String getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return 'Very Happy';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.verySad:
        return 'Very Sad';
    }
  }
}
