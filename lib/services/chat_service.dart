import 'package:hive/hive.dart';
import 'local_db.dart';

class ChatService {
  /// Save a single message for a user. Messages are stored per-user as a list
  /// under the user's id key in the chats box.
  static Future<void> saveMessage(
      String userId, Map<String, dynamic> message) async {
    final box = Hive.box<List>(LocalDb.chatsBox);
    final existing = box.get(userId) ?? <Map<String, dynamic>>[];
    final list = List<Map<String, dynamic>>.from(
        existing.map((e) => Map<String, dynamic>.from(e as Map)));
    list.add(message);
    await box.put(userId, list);
  }

  static List<Map<String, dynamic>> getMessages(String userId) {
    final box = Hive.box<List>(LocalDb.chatsBox);
    final existing = box.get(userId) ?? <Map<String, dynamic>>[];
    return List<Map<String, dynamic>>.from(
        existing.map((e) => Map<String, dynamic>.from(e as Map)));
  }

  static Future<void> clearMessages(String userId) async {
    final box = Hive.box<List>(LocalDb.chatsBox);
    await box.delete(userId);
  }
}
