import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';
import 'package:better_person/utils/prayer_time_calculator.dart';
import 'package:better_person/utils/location_service.dart';
import 'package:better_person/controllers/setting_controller.dart';
import 'package:adhan/adhan.dart' as adhan;

class PrayerController extends BaseController<Prayer> {
  static final PrayerController _instance = PrayerController._internal();

  factory PrayerController() {
    return _instance;
  }

  PrayerController._internal();

  @override
  String get storageKey => 'prayers';

  @override
  Map<String, dynamic> toJson(Prayer item) => item.toJson();

  @override
  Prayer fromJson(Map<String, dynamic> json) => Prayer.fromJson(json);

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
    await persist();
    return prayer;
  }

  @override
  Future<Prayer?> update(String id, Prayer prayer) async {
    final index = items.indexWhere((p) => p.id == id);
    if (index == -1) return null;

    items[index] = prayer;
    await persist();
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
      checkedAt: fields.containsKey('checkedAt')
          ? fields['checkedAt'] as DateTime?
          : prayer.checkedAt,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Prayer>> updateMany(
    Map<String, Map<String, dynamic>> updates,
  ) async {
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
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((prayer) => ids.contains(prayer.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get prayers by name
  List<Prayer> getByName(PrayerName name) {
    return findWhere((prayer) => prayer.name == name);
  }

  /// Get prayers for a specific date
  List<Prayer> getByDate(DateTime date) {
    return findWhere(
      (prayer) =>
          prayer.date.year == date.year &&
          prayer.date.month == date.month &&
          prayer.date.day == date.day,
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
    return updateFields(id, {'isChecked': true, 'checkedAt': DateTime.now()});
  }

  /// Mark prayer as unchecked
  Future<Prayer?> markUnchecked(String id) async {
    return updateFields(id, {'isChecked': false, 'checkedAt': null});
  }

  /// Get today's prayers
  List<Prayer> getTodayPrayers() {
    final prayers = getByDate(DateTime.now());
    prayers.sort(
      (a, b) => (a.scheduledTime.hour * 60 + a.scheduledTime.minute).compareTo(
        b.scheduledTime.hour * 60 + b.scheduledTime.minute,
      ),
    );
    return prayers;
  }

  Prayer? getNextPrayer([DateTime? at]) {
    final now = at ?? DateTime.now();
    final today = getTodayPrayers();
    for (final prayer in today) {
      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        prayer.scheduledTime.hour,
        prayer.scheduledTime.minute,
      );
      if (scheduled.isAfter(now)) return prayer;
    }
    return today.isEmpty ? null : today.first;
  }

  Future<Prayer?> checkPrayer(String id) => markChecked(id);

  Future<Prayer?> uncheckPrayer(String id) => markUnchecked(id);

  /// Initialize daily prayers with default times
  Future<void> initializeDailyPrayers() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final existingNames = getByDate(
      todayDate,
    ).map((prayer) => prayer.name).toSet();
    if (existingNames.length == PrayerName.values.length) return;

    // Get user location
    final location = await LocationService.getLocation();
    final settings = SettingController().getCurrentSetting();
    final method = adhan.CalculationMethod.values.firstWhere(
      (value) => value.name == settings.prayerCalculationMethod,
      orElse: () => adhan.CalculationMethod.muslim_world_league,
    );

    // Calculate prayer times
    final prayerTimes = PrayerTimeCalculator.calculatePrayerTimes(
      date: todayDate,
      latitude: location.latitude,
      longitude: location.longitude,
      method: method,
    );

    // Create prayer entries
    for (var entry in prayerTimes.entries) {
      if (existingNames.contains(entry.key)) continue;
      final prayer = Prayer(
        id: '${todayDate.millisecondsSinceEpoch}_${entry.key.toString()}',
        name: entry.key,
        scheduledTime: entry.value,
        isChecked: false,
        checkedAt: null,
        date: todayDate,
      );

      await create(prayer);
    }
  }

  Future<void> recalculateTodayPrayerTimes() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final location = await LocationService.getLocation();
    final setting = SettingController().getCurrentSetting();
    final method = adhan.CalculationMethod.values.firstWhere(
      (value) => value.name == setting.prayerCalculationMethod,
      orElse: () => adhan.CalculationMethod.muslim_world_league,
    );
    final times = PrayerTimeCalculator.calculatePrayerTimes(
      date: today,
      latitude: location.latitude,
      longitude: location.longitude,
      method: method,
    );
    final existing = getByDate(today);
    if (existing.isEmpty) {
      await initializeDailyPrayers();
      return;
    }
    for (final prayer in existing) {
      final time = times[prayer.name];
      if (time != null) {
        await updateFields(prayer.id, {'scheduledTime': time});
      }
    }
  }
}
