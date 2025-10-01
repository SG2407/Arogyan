class EmotionAnalysis {
  static Map<String, double> analyzeText(String text) {
    final emotions = {
      'happy': 0.0,
      'sad': 0.0,
      'anxious': 0.0,
      'angry': 0.0,
      'neutral': 0.0,
    };

    // List of emotion-related keywords
    final emotionKeywords = {
      'happy': [
        'happy',
        'joy',
        'excited',
        'great',
        'wonderful',
        'blessed',
        'pleased',
        'delighted',
        'better',
        'good',
        'positive',
        'optimistic',
        'confident'
      ],
      'sad': [
        'sad',
        'depressed',
        'unhappy',
        'miserable',
        'down',
        'blue',
        'upset',
        'hopeless',
        'lonely',
        'disappointed',
        'hurt',
        'painful',
        'crying'
      ],
      'anxious': [
        'anxious',
        'worried',
        'nervous',
        'scared',
        'afraid',
        'panic',
        'stress',
        'tense',
        'uneasy',
        'restless',
        'concerned',
        'overwhelmed',
        'fear'
      ],
      'angry': [
        'angry',
        'mad',
        'frustrated',
        'annoyed',
        'irritated',
        'furious',
        'rage',
        'hate',
        'upset',
        'hostile',
        'bitter',
        'outraged',
        'offensive'
      ],
    };

    final words = text.toLowerCase().split(' ');
    var totalEmotionWords = 0;

    // Count emotion words
    for (final word in words) {
      for (final emotion in emotionKeywords.keys) {
        if (emotionKeywords[emotion]!.contains(word)) {
          emotions[emotion] = (emotions[emotion] ?? 0) + 1;
          totalEmotionWords++;
        }
      }
    }

    // Calculate percentages
    if (totalEmotionWords > 0) {
      for (final emotion in emotions.keys) {
        emotions[emotion] = (emotions[emotion] ?? 0) / totalEmotionWords;
      }
    } else {
      emotions['neutral'] = 1.0;
    }

    return emotions;
  }

  static String getPredominantEmotion(Map<String, double> emotions) {
    var maxEmotion = 'neutral';
    var maxValue = 0.0;

    emotions.forEach((emotion, value) {
      if (value > maxValue) {
        maxValue = value;
        maxEmotion = emotion;
      }
    });

    return maxEmotion;
  }

  static String getEmotionalResponse(String emotion) {
    switch (emotion) {
      case 'happy':
        return "I'm glad you're feeling positive! That's wonderful to hear.";
      case 'sad':
        return "I understand you're feeling down. Remember that it's okay to feel this way, and consider talking to someone you trust or a mental health professional.";
      case 'anxious':
        return "I notice you're feeling anxious. Try taking some deep breaths and remember that you don't have to face your concerns alone.";
      case 'angry':
        return "I can sense your frustration. It might help to take a moment to calm down and then address what's bothering you.";
      default:
        return "Thank you for sharing how you're feeling.";
    }
  }
}
