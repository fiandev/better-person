import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class UserController extends BaseController<User> {
  static final UserController _instance = UserController._internal();
  
  factory UserController() {
    return _instance;
  }
  
  UserController._internal();

  @override
  User? getById(String id) {
    try {
      return _items.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> create(User user) async {
    _items.add(user);
    return user;
  }

  @override
  Future<User?> update(String id, User user) async {
    final index = _items.indexWhere((u) => u.id == id);
    if (index == -1) return null;
    
    _items[index] = user;
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
    final initialLength = _items.length;
    _items.removeWhere((user) => user.id == id);
    return _items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = _items.length;
    _items.removeWhere((user) => ids.contains(user.id));
    return initialLength - _items.length;
  }

  /// Get user by name
  User? getByName(String name) {
    return findFirst((user) => user.name.toLowerCase() == name.toLowerCase());
  }

  /// Get users with streak above threshold
  List<User> getUsersWithStreak(int minStreak) {
    return findWhere((user) => user.streak >= minStreak);
  }
}
