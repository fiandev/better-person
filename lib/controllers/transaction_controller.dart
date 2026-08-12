import '../models/transaction.dart';
import 'base_controller.dart';

class TransactionController extends BaseController<Transaction> {
  static final TransactionController _instance = TransactionController._internal();
  
  factory TransactionController() {
    return _instance;
  }
  
  TransactionController._internal();

  @override
  String get storageKey => 'transactions';

  @override
  Map<String, dynamic> toJson(Transaction item) => item.toJson();

  @override
  Transaction fromJson(Map<String, dynamic> json) => Transaction.fromJson(json);

  @override
  Transaction? getById(String id) {
    try {
      return items.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Transaction> create(Transaction transaction) async {
    items.add(transaction);
    await persist();
    return transaction;
  }

  @override
  Future<Transaction?> update(String id, Transaction transaction) async {
    final index = items.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    
    items[index] = transaction;
    await persist();
    return transaction;
  }

  @override
  Future<Transaction?> updateFields(String id, Map<String, dynamic> fields) async {
    final transaction = getById(id);
    if (transaction == null) return null;

    final updated = transaction.copyWith(
      walletId: fields['walletId'] as String? ?? transaction.walletId,
      amount: fields['amount'] as double? ?? transaction.amount,
      type: fields['type'] as TransactionType? ?? transaction.type,
      category: fields['category'] as TransactionCategory? ?? transaction.category,
      date: fields['date'] as DateTime? ?? transaction.date,
      note: fields.containsKey('note') ? fields['note'] as String? : transaction.note,
      toWalletId: fields.containsKey('toWalletId') ? fields['toWalletId'] as String? : transaction.toWalletId,
      fromWalletId: fields.containsKey('fromWalletId') ? fields['fromWalletId'] as String? : transaction.fromWalletId,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Transaction>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Transaction>{};
    
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
    items.removeWhere((transaction) => transaction.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((transaction) => ids.contains(transaction.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get transactions by wallet ID
  List<Transaction> getByWallet(String walletId) {
    return findWhere((transaction) => transaction.walletId == walletId);
  }

  /// Get transactions by type (income, expense, transfer)
  List<Transaction> getByType(TransactionType type) {
    return findWhere((transaction) => transaction.type == type);
  }

  /// Get transactions by category
  List<Transaction> getByCategory(TransactionCategory category) {
    return findWhere((transaction) => transaction.category == category);
  }

  /// Get transactions within a date range
  List<Transaction> getByDateRange(DateTime start, DateTime end) {
    return findWhere((transaction) {
      return transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(end.add(const Duration(days: 1)));
    });
  }

  /// Get recent transactions (sorted by date, descending)
  List<Transaction> getRecent({int limit = 10}) {
    final sorted = List<Transaction>.from(items);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  /// Get total income for a wallet
  double getTotalIncome(String walletId) {
    return items
        .where((t) => t.walletId == walletId && t.type == TransactionType.income)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get total expenses for a wallet
  double getTotalExpenses(String walletId) {
    return items
        .where((t) => t.walletId == walletId && t.type == TransactionType.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get total income across all wallets
  double getTotalIncomeAll() {
    return items
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get total expenses across all wallets
  double getTotalExpensesAll() {
    return items
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Get transactions for today
  List<Transaction> getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Get transactions for this week
  List<Transaction> getThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfDay.add(const Duration(days: 7));
    return getByDateRange(startOfDay, endOfWeek);
  }

  /// Get transactions for this month
  List<Transaction> getThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getByDateRange(startOfMonth, endOfMonth);
  }
}
