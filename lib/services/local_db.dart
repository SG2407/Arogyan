import 'package:hive_flutter/hive_flutter.dart';

class LocalDb {
  static const String usersBox = 'users_box';
  static const String chatsBox = 'chats_box';
  static const String docsBox = 'docs_box';
  static const String notesBox = 'notes_box';
  static const String sessionBox = 'session_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Open boxes used by the app. We store simple maps/JSON so no adapters needed.
    await Hive.openBox<Map>(usersBox);
    await Hive.openBox<List>(chatsBox);
    await Hive.openBox<Map>(docsBox);
    await Hive.openBox<Map>(notesBox);
    await Hive.openBox<Map>(sessionBox);
  }
}
