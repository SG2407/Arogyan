import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:aarogyan/services/local_db.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _key = 'language';
  String _languageCode = 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  String get languageCode => _languageCode;

  void _loadLanguage() {
    try {
      final box = Hive.box<Map>(LocalDb.sessionBox);
      final langMap = box.get(_key);
      if (langMap != null && langMap['code'] != null) {
        _languageCode = langMap['code'] as String;
      }
    } catch (_) {
      // fallback to English
      _languageCode = 'en';
    }
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    try {
      final box = Hive.box<Map>(LocalDb.sessionBox);
      await box.put(_key, {'code': code});
    } catch (_) {}
    notifyListeners();
  }

  List<String> get availableLanguages => ['en', 'hi', 'mr'];
  Map<String, String> get languageNames => {
        'en': 'English',
        'hi': 'हिंदी',
        'mr': 'मराठी',
      };
}
