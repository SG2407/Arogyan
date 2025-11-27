import 'package:hive/hive.dart';
import 'local_db.dart';

class SessionService {
  static const _userIdKey = 'currentUserId';
  static const _sessionTimeKey = 'sessionTime';
  static const _isLoggedInKey = 'isLoggedIn';

  static void setCurrentUserId(String id) {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    box.put(_userIdKey, {'id': id});
    box.put(_sessionTimeKey, {'time': DateTime.now().toIso8601String()});
    box.put(_isLoggedInKey, {'isLoggedIn': true});
  }

  static String? getCurrentUserId() {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    final map = box.get(_userIdKey);
    if (map == null) return null;
    return map['id'] as String?;
  }

  static bool isSessionActive() {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    final loggedInMap = box.get(_isLoggedInKey);
    return loggedInMap?['isLoggedIn'] as bool? ?? false;
  }

  static String? getSessionTime() {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    final map = box.get(_sessionTimeKey);
    if (map == null) return null;
    return map['time'] as String?;
  }

  static Future<void> logout() async {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    box.delete(_userIdKey);
    box.delete(_sessionTimeKey);
    box.put(_isLoggedInKey, {'isLoggedIn': false});
  }

  static Future<void> completeSession() async {
    await logout();
  }

  static void clear() {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    box.delete(_userIdKey);
    box.delete(_sessionTimeKey);
    box.delete(_isLoggedInKey);
  }
}
