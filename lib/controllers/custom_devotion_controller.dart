import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class CustomDevotionController extends BaseController<CustomDevotion> {
  static final CustomDevotionController _instance = CustomDevotionController._internal();
  
  factory CustomDevotionController() {
    return _instance;
  }
  
  CustomDevotionController._internal();

  @override
  String get storageKey => 'custom_devotions';

  @override
  Map<String, dynamic> toJson(CustomDevotion item) => item.toJson();

  @override
  CustomDevotion fromJson(Map<String, dynamic> json) => CustomDevotion.fromJson(json);

  @override
  CustomDevotion? getById(String id) {
    try {
      return items.firstWhere((devotion) => devotion.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CustomDevotion> create(CustomDevotion devotion) async {
    items.add(devotion);
    await persist();
    return devotion;
  }

  @override
  Future<CustomDevotion?> update(String id, CustomDevotion devotion) async {
    final index = items.indexWhere((d) => d.id == id);
    if (index == -1) return null;
    
    items[index] = devotion;
    await persist();
    return devotion;
  }

  @override
  Future<CustomDevotion?> updateFields(String id, Map<String, dynamic> fields) async {
    final devotion = getById(id);
    if (devotion == null) return null;

    final updated = devotion.copyWith(
      name: fields['name'] as String? ?? devotion.name,
      scheduledTime: fields['scheduledTime'] ?? devotion.scheduledTime,
      isCompleted: fields['isCompleted'] as bool? ?? devotion.isCompleted,
      date: fields['date'] as DateTime? ?? devotion.date,
      completedAt: fields.containsKey('completedAt') ? fields['completedAt'] as DateTime? : devotion.completedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, CustomDevotion>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, CustomDevotion>{};
    
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
    items.removeWhere((devotion) => devotion.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((devotion) => ids.contains(devotion.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get devotions by date
  List<CustomDevotion> getByDate(DateTime date) {
    return findWhere((devotion) => 
      devotion.date.year == date.year &&
      devotion.date.month == date.month &&
      devotion.date.day == date.day
    );
  }

  /// Get completed devotions
  List<CustomDevotion> getCompleted() {
    return findWhere((devotion) => devotion.isCompleted);
  }

  /// Get incomplete devotions
  List<CustomDevotion> getIncomplete() {
    return findWhere((devotion) => !devotion.isCompleted);
  }

  /// Get today's devotions
  List<CustomDevotion> getTodayDevotions() {
    return getByDate(DateTime.now());
  }

  /// Mark devotion as completed
  Future<CustomDevotion?> markCompleted(String id) async {
    return updateFields(id, {
      'isCompleted': true,
      'completedAt': DateTime.now(),
    });
  }

  /// Mark devotion as incomplete
  Future<CustomDevotion?> markIncomplete(String id) async {
    return updateFields(id, {
      'isCompleted': false,
      'completedAt': null,
    });
  }
}
