import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class SettingController extends BaseController<Setting> {
  static final SettingController _instance = SettingController._internal();

  factory SettingController() {
    return _instance;
  }

  SettingController._internal();

  @override
  String get storageKey => 'settings';

  @override
  Map<String, dynamic> toJson(Setting item) => item.toJson();

  @override
  Setting fromJson(Map<String, dynamic> json) => Setting.fromJson(json);

  @override
  Setting? getById(String id) {
    try {
      return items.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Setting> create(Setting item) async {
    items.add(item);
    await persist();
    return item;
  }

  @override
  Future<Setting?> update(String id, Setting item) async {
    final index = items.indexWhere((s) => s.id == id);
    if (index == -1) return null;

    items[index] = item;
    await persist();
    return item;
  }

  @override
  Future<Setting?> updateFields(String id, Map<String, dynamic> fields) async {
    final setting = getById(id);
    if (setting == null) return null;

    final updated = setting.copyWith(
      defaultCurrencyFormat:
          fields['defaultCurrencyFormat'] as String? ?? setting.defaultCurrencyFormat,
      updatedAt: DateTime.now(),
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Setting>> updateMany(
      Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Setting>{};

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
    items.removeWhere((s) => s.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((s) => ids.contains(s.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get the current settings, creating a default if none exist.
  Setting getCurrentSetting() {
    if (items.isEmpty) {
      return Setting.defaultSetting();
    }
    return items.first;
  }

  /// Ensure settings exist, creating default if needed.
  Future<void> ensureSettingsExist() async {
    if (items.isEmpty) {
      await create(Setting.defaultSetting());
    }
  }
}
