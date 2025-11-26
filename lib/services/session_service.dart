import 'package:hive/hive.dart';
import 'local_db.dart';

class SessionService {
  static const _key = 'currentUserId';

  static void setCurrentUserId(String id) {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    box.put(_key, {'id': id});
  }

  static String? getCurrentUserId() {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    final map = box.get(_key);
    if (map == null) return null;
    return map['id'] as String?;
  }

  static void clear() {
    final box = Hive.box<Map>(LocalDb.sessionBox);
    box.delete(_key);
  }
}
