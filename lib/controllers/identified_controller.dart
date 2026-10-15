import 'base_controller.dart';

abstract class IdentifiedController<T> extends BaseController<T> {
  String idOf(T item);
  T applyFields(T item, Map<String, dynamic> fields);

  @override
  T? getById(String id) {
    for (final item in items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  @override
  Future<T> create(T item) async {
    items.add(item);
    await persist();
    return item;
  }

  @override
  Future<T?> update(String id, T item) async {
    final index = items.indexWhere((value) => idOf(value) == id);
    if (index < 0) return null;
    items[index] = item;
    await persist();
    return item;
  }

  @override
  Future<T?> updateFields(String id, Map<String, dynamic> fields) async {
    final item = getById(id);
    if (item == null) return null;
    return update(id, applyFields(item, fields));
  }

  @override
  Future<Map<String, T>> updateMany(
    Map<String, Map<String, dynamic>> updates,
  ) async {
    final updated = <String, T>{};
    for (final entry in updates.entries) {
      final item = getById(entry.key);
      if (item != null) {
        final replacement = applyFields(item, entry.value);
        final index = items.indexWhere((value) => idOf(value) == entry.key);
        items[index] = replacement;
        updated[entry.key] = replacement;
      }
    }
    if (updated.isNotEmpty) await persist();
    return updated;
  }

  @override
  Future<bool> delete(String id) async {
    final initialLength = items.length;
    items.removeWhere((item) => idOf(item) == id);
    if (items.length == initialLength) return false;
    await persist();
    return true;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final before = items.length;
    items.removeWhere((item) => ids.contains(idOf(item)));
    final removed = before - items.length;
    if (removed > 0) await persist();
    return removed;
  }
}
