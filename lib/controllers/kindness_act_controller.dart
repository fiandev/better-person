import 'package:better_person/controllers/base_controller.dart';
import 'package:better_person/models/models.dart';

class KindnessActController extends BaseController<KindnessAct> {
  static final KindnessActController _instance = KindnessActController._internal();
  
  factory KindnessActController() {
    return _instance;
  }
  
  KindnessActController._internal();

  @override
  KindnessAct? getById(String id) {
    try {
      return _items.firstWhere((act) => act.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<KindnessAct> create(KindnessAct act) async {
    _items.add(act);
    return act;
  }

  @override
  Future<KindnessAct?> update(String id, KindnessAct act) async {
    final index = _items.indexWhere((a) => a.id == id);
    if (index == -1) return null;
    
    _items[index] = act;
    return act;
  }

  @override
  Future<KindnessAct?> updateFields(String id, Map<String, dynamic> fields) async {
    final act = getById(id);
    if (act == null) return null;

    final updated = act.copyWith(
      label: fields['label'] as String? ?? act.label,
      isSelected: fields['isSelected'] as bool? ?? act.isSelected,
      sortOrder: fields['sortOrder'] as int? ?? act.sortOrder,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, KindnessAct>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, KindnessAct>{};
    
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
    _items.removeWhere((act) => act.id == id);
    return _items.length < initialLength;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = _items.length;
    _items.removeWhere((act) => ids.contains(act.id));
    return initialLength - _items.length;
  }

  /// Get selected acts
  List<KindnessAct> getSelected() {
    return findWhere((act) => act.isSelected);
  }

  /// Get unselected acts
  List<KindnessAct> getUnselected() {
    return findWhere((act) => !act.isSelected);
  }

  /// Get acts sorted by sortOrder
  List<KindnessAct> getSorted() {
    final sorted = List<KindnessAct>.from(_items);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Toggle selection
  Future<KindnessAct?> toggleSelection(String id) async {
    final act = getById(id);
    if (act == null) return null;

    return updateFields(id, {'isSelected': !act.isSelected});
  }

  /// Select an act
  Future<KindnessAct?> select(String id) async {
    return updateFields(id, {'isSelected': true});
  }

  /// Deselect an act
  Future<KindnessAct?> deselect(String id) async {
    return updateFields(id, {'isSelected': false});
  }

  /// Deselect all acts
  Future<void> deselectAll() async {
    for (final act in _items) {
      await updateFields(act.id, {'isSelected': false});
    }
  }

  /// Reorder acts
  Future<void> reorderActs(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      await updateFields(orderedIds[i], {'sortOrder': i});
    }
  }
}
