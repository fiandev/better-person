import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class PrayerController extends BaseController<Prayer> {
  static final PrayerController _instance = PrayerController._internal();
  
  factory PrayerController() {
    return _instance;
  }
  
  PrayerController._internal();

  @override
  Prayer? getById(String id) {
    try {
      return items.firstWhere((prayer) => prayer.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Prayer> create(Prayer prayer) async {
    items.add(prayer);
    return prayer;
  }

  @override
  Future<Prayer?> update(String id, Prayer prayer) async {
    final index = items.indexWhere((p) => p.id == id);
    if (index == -1) return null;
    
    items[index] = prayer;
    return prayer;
  }

  @override
  Future<Prayer?> updateFields(String id, Map<String, dynamic> fields) async {
    final prayer = getById(id);
    if (prayer == null) return null;

    final updated = prayer.copyWith(
      name: fields['name'] as PrayerName? ?? prayer.name,
      scheduledTime: fields['scheduledTime'] ?? prayer.scheduledTime,
      isChecked: fields['isChecked'] as bool? ?? prayer.isChecked,
      date: fields['date'] as DateTime? ?? prayer.date,
      checkedAt: fields.containsKey('checkedAt') ? fields['checkedAt'] as DateTime? : prayer.checkedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Prayer>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Prayer>{};
    
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
    items.removeWhere((prayer) => prayer.id == id);
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((prayer) => ids.contains(prayer.id));
    return initialLength - items.length;
  }

  /// Get prayers by name
  List<Prayer> getByName(PrayerName name) {
    return findWhere((prayer) => prayer.name == name);
  }

  /// Get prayers for a specific date
  List<Prayer> getByDate(DateTime date) {
    return findWhere((prayer) => 
      prayer.date.year == date.year &&
      prayer.date.month == date.month &&
      prayer.date.day == date.day
    );
  }

  /// Get checked prayers
  List<Prayer> getChecked() {
    return findWhere((prayer) => prayer.isChecked);
  }

  /// Get unchecked prayers
  List<Prayer> getUnchecked() {
    return findWhere((prayer) => !prayer.isChecked);
  }

  /// Mark prayer as checked
  Future<Prayer?> markChecked(String id) async {
    return updateFields(id, {
      'isChecked': true,
      'checkedAt': DateTime.now(),
    });
  }

  /// Mark prayer as unchecked
  Future<Prayer?> markUnchecked(String id) async {
    return updateFields(id, {
      'isChecked': false,
      'checkedAt': null,
    });
  }

  /// Get today's prayers
  List<Prayer> getTodayPrayers() {
    return getByDate(DateTime.now());
  }
}
