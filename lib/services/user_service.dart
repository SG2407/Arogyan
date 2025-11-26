import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'local_db.dart';

class UserService {
  static final _uuid = Uuid();

  /// Register a new user. [isDoctor] toggles role. Returns generated user id.
  static Future<String> registerUser({
    required String name,
    required String email,
    required String password,
    required bool isDoctor,
    Map<String, dynamic>? demographics,
    Map<String, dynamic>? medical,
  }) async {
    final box = Hive.box<Map>(LocalDb.usersBox);
    // Simple uniqueness check by email
    final existing = box.values.firstWhere(
      (m) => m['email'] == email,
      orElse: () => {},
    );
    if (existing.isNotEmpty) {
      throw Exception('User with this email already exists');
    }

    final id = _uuid.v4();
    final user = {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // NOTE: in production, store hashed passwords
      'isDoctor': isDoctor,
      'demographics': demographics ?? {},
      'medical': medical ?? {},
      'profilePhoto': null, // Base64 encoded photo
      'createdAt': DateTime.now().toIso8601String(),
    };

    await box.put(id, user);
    return id;
  }

  /// Simple login by email/password. Returns user map if valid, else null.
  static Map<String, dynamic>? login({
    required String email,
    required String password,
    required bool isDoctor,
  }) {
    final box = Hive.box<Map>(LocalDb.usersBox);
    for (final entry in box.values) {
      if (entry['email'] == email &&
          entry['password'] == password &&
          entry['isDoctor'] == isDoctor) {
        return Map<String, dynamic>.from(entry);
      }
    }
    return null;
  }

  static Map<String, dynamic>? getUserById(String id) {
    final box = Hive.box<Map>(LocalDb.usersBox);
    final user = box.get(id);
    if (user == null) return null;
    return Map<String, dynamic>.from(user);
  }

  static List<Map<String, dynamic>> searchUserByEmail(String email) {
    final box = Hive.box<Map>(LocalDb.usersBox);
    return box.values
        .where((m) =>
            (m['email'] as String).toLowerCase().contains(email.toLowerCase()))
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  /// Update user profile photo (base64 encoded string)
  static Future<void> updateProfilePhoto(String userId, String? photoBase64) async {
    final box = Hive.box<Map>(LocalDb.usersBox);
    final user = box.get(userId);
    if (user != null) {
      user['profilePhoto'] = photoBase64;
      await box.put(userId, user);
    }
  }

  /// Update user medical information
  static Future<void> updateMedicalInfo(
    String userId, {
    List<String>? conditions,
    List<String>? surgeries,
    List<String>? allergies,
  }) async {
    final box = Hive.box<Map>(LocalDb.usersBox);
    final user = box.get(userId);
    if (user != null) {
      if (user['medical'] == null) {
        user['medical'] = {};
      }
      if (conditions != null) user['medical']['conditions'] = conditions;
      if (surgeries != null) user['medical']['surgeries'] = surgeries;
      if (allergies != null) user['medical']['allergies'] = allergies;
      await box.put(userId, user);
    }
  }

  /// Update user demographics
  static Future<void> updateDemographics(
    String userId, {
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) async {
    final box = Hive.box<Map>(LocalDb.usersBox);
    final user = box.get(userId);
    if (user != null) {
      if (user['demographics'] == null) {
        user['demographics'] = {};
      }
      if (age != null) user['demographics']['age'] = age;
      if (gender != null) user['demographics']['gender'] = gender;
      if (height != null) user['demographics']['height'] = height;
      if (weight != null) user['demographics']['weight'] = weight;
      await box.put(userId, user);
    }
  }

  /// Change user email (requires password verification)
  static Future<bool> changeEmail(
    String userId,
    String newEmail,
    String password,
  ) async {
    final box = Hive.box<Map>(LocalDb.usersBox);
    final user = box.get(userId);
    if (user == null) return false;

    // Verify password
    if (user['password'] != password) return false;

    // Check if email already exists
    final existing = box.values.any((u) => u['email'] == newEmail && u['id'] != userId);
    if (existing) return false;

    user['email'] = newEmail;
    await box.put(userId, user);
    return true;
  }
