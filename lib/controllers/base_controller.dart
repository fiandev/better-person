/// Base CRUD controller providing standard database operations.
/// 
/// Type parameter [T] represents the model type.
/// Subclasses should implement the abstract methods for persistence logic.
abstract class BaseController<T> {
  /// Storage for all items in memory.
  final List<T> _items = [];

  /// Get all items.
  List<T> getAll() {
    return List.unmodifiable(_items);
  }

  /// Get a single item by ID.
  /// Returns null if not found.
  T? getById(String id);

  /// Create a new item.
  /// Returns the created item.
  Future<T> create(T item);

  /// Update an existing item.
  /// Returns the updated item or null if not found.
  Future<T?> update(String id, T item);

  /// Update one or many columns/fields of an item.
  /// 
  /// [id] - The ID of the item to update
  /// [fields] - Map of field names to new values
  /// 
  /// Returns the updated item or null if not found.
  Future<T?> updateFields(String id, Map<String, dynamic> fields);

  /// Update multiple items at once.
  /// 
  /// [updates] - Map of item IDs to their updated data
  /// 
  /// Returns a map of successfully updated items.
  Future<Map<String, T>> updateMany(Map<String, Map<String, dynamic>> updates);

  /// Delete an item by ID.
  /// Returns true if deleted, false if not found.
  Future<bool> delete(String id);

  /// Delete multiple items by IDs.
  /// Returns the count of successfully deleted items.
  Future<int> deleteMany(List<String> ids);

  /// Find items matching a predicate.
  List<T> findWhere(bool Function(T item) predicate) {
    return _items.where(predicate).toList();
  }

  /// Get the first item matching a predicate, or null.
  T? findFirst(bool Function(T item) predicate) {
    try {
      return _items.firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  /// Count total items.
  int count() {
    return _items.length;
  }

  /// Count items matching a predicate.
  int countWhere(bool Function(T item) predicate) {
    return _items.where(predicate).length;
  }

  /// Clear all items.
  Future<void> clear() async {
    _items.clear();
  }
}
