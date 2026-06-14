import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class SpiritualMomentController extends BaseController<SpiritualMoment> {
  static final SpiritualMomentController _instance = SpiritualMomentController._internal();
  
  factory SpiritualMomentController() {
    return _instance;
  }
  
  SpiritualMomentController._internal();

  @override
  SpiritualMoment? getById(String id) {
    try {
      return items.firstWhere((moment) => moment.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<SpiritualMoment> create(SpiritualMoment moment) async {
    items.add(moment);
    return moment;
  }

  @override
  Future<SpiritualMoment?> update(String id, SpiritualMoment moment) async {
    final index = items.indexWhere((m) => m.id == id);
    if (index == -1) return null;
    
    items[index] = moment;
    return moment;
  }

  @override
  Future<SpiritualMoment?> updateFields(String id, Map<String, dynamic> fields) async {
    final moment = getById(id);
    if (moment == null) return null;

    final updated = moment.copyWith(
      name: fields['name'] as String? ?? moment.name,
      scheduledTime: fields['scheduledTime'] ?? moment.scheduledTime,
      isChecked: fields['isChecked'] as bool? ?? moment.isChecked,
      date: fields['date'] as DateTime? ?? moment.date,
      checkedAt: fields.containsKey('checkedAt') ? fields['checkedAt'] as DateTime? : moment.checkedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, SpiritualMoment>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, SpiritualMoment>{};
    
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
    items.removeWhere((moment) => moment.id == id);
    return items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((moment) => ids.contains(moment.id));
    return initialLength - items.length;
  }

  /// Get moments by date
  List<SpiritualMoment> getByDate(DateTime date) {
    return findWhere((moment) => 
      moment.date.year == date.year &&
      moment.date.month == date.month &&
      moment.date.day == date.day
    );
  }

  /// Get checked moments
  List<SpiritualMoment> getChecked() {
    return findWhere((moment) => moment.isChecked);
  }

  /// Get unchecked moments
  List<SpiritualMoment> getUnchecked() {
    return findWhere((moment) => !moment.isChecked);
  }

  /// Get today's moments
  List<SpiritualMoment> getTodayMoments() {
    return getByDate(DateTime.now());
  }

  /// Mark moment as checked
  Future<SpiritualMoment?> markChecked(String id) async {
    return updateFields(id, {
      'isChecked': true,
      'checkedAt': DateTime.now(),
    });
  }

  /// Mark moment as unchecked
  Future<SpiritualMoment?> markUnchecked(String id) async {
    return updateFields(id, {
      'isChecked': false,
      'checkedAt': null,
    });
  }
}
