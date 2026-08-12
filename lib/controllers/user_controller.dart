import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class UserController extends BaseController<User> {
  static final UserController _instance = UserController._internal();
  
  factory UserController() {
    return _instance;
  }
  
  UserController._internal();

  @override
  String get storageKey => 'users';

  @override
  Map<String, dynamic> toJson(User item) => item.toJson();

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  User? getById(String id) {
    try {
      return items.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> create(User user) async {
    items.add(user);
    await persist();
    return user;
  }

  @override
  Future<User?> update(String id, User user) async {
    final index = items.indexWhere((u) => u.id == id);
    if (index == -1) return null;
    
    items[index] = user;
    await persist();
    return user;
  }

  @override
  Future<User?> updateFields(String id, Map<String, dynamic> fields) async {
    final user = getById(id);
    if (user == null) return null;

    final updated = user.copyWith(
      name: fields['name'] as String? ?? user.name,
      avatarUrl: fields.containsKey('avatarUrl') ? fields['avatarUrl'] as String? : user.avatarUrl,
      streak: fields['streak'] as int? ?? user.streak,
      dailyProgress: fields['dailyProgress'] as double? ?? user.dailyProgress,
      totalHabitsDone: fields['totalHabitsDone'] as int? ?? user.totalHabitsDone,
      totalFocusHours: fields['totalFocusHours'] as double? ?? user.totalFocusHours,
      totalKindActs: fields['totalKindActs'] as int? ?? user.totalKindActs,
      growthScore: fields['growthScore'] as double? ?? user.growthScore,
      updatedAt: DateTime.now(),
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, User>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, User>{};
    
    for (final entry in updates.entries) {
      final updated = await updateFields(entry.key, entry.value);
      if (updated != null) {
        result[entry.key] = updated;
      }
    }
    
    return result;
  }

  @override
  Future<bool> delete(String id) async {
    final initialLength = items.length;
    items.removeWhere((user) => user.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((user) => ids.contains(user.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get user by name
  User? getByName(String name) {
    return findFirst((user) => user.name.toLowerCase() == name.toLowerCase());
  }

  /// Get users with streak above threshold
  List<User> getUsersWithStreak(int minStreak) {
    return findWhere((user) => user.streak >= minStreak);
  }

  /// Get current user (assumes single user for now)
  User getCurrentUser() {
    final users = getAll();
    if (users.isEmpty) {
      throw Exception('No user found. Please initialize user data.');
    }
    return users.first;
  }

  /// Increment kind acts count
  Future<User?> incrementKindActs() async {
    final user = getCurrentUser();
    return updateFields(user.id, {
      'totalKindActs': user.totalKindActs + 1,
    });
  }
}
