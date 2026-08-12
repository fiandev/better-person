import '../models/wallet.dart';
import 'base_controller.dart';

class WalletController extends BaseController<Wallet> {
  static final WalletController _instance = WalletController._internal();
  
  factory WalletController() {
    return _instance;
  }
  
  WalletController._internal();

  @override
  String get storageKey => 'wallets';

  @override
  Map<String, dynamic> toJson(Wallet item) => item.toJson();

  @override
  Wallet fromJson(Map<String, dynamic> json) => Wallet.fromJson(json);

  @override
  Wallet? getById(String id) {
    try {
      return items.firstWhere((wallet) => wallet.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Wallet> create(Wallet wallet) async {
    items.add(wallet);
    await persist();
    return wallet;
  }

  @override
  Future<Wallet?> update(String id, Wallet wallet) async {
    final index = items.indexWhere((w) => w.id == id);
    if (index == -1) return null;
    
    items[index] = wallet;
    await persist();
    return wallet;
  }

  @override
  Future<Wallet?> updateFields(String id, Map<String, dynamic> fields) async {
    final wallet = getById(id);
    if (wallet == null) return null;

    final updated = wallet.copyWith(
      name: fields['name'] as String? ?? wallet.name,
      type: fields['type'] as WalletType? ?? wallet.type,
      icon: fields['icon'] as WalletIcon? ?? wallet.icon,
      currentBalance: fields['currentBalance'] as double? ?? wallet.currentBalance,
      accountNumber: fields['accountNumber'] as String? ?? wallet.accountNumber,
    );

    return update(id, updated);
  }

  @override
  Future<Map<String, Wallet>> updateMany(Map<String, Map<String, dynamic>> updates) async {
    final result = <String, Wallet>{};
    
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
    items.removeWhere((wallet) => wallet.id == id);
    final deleted = items.length < initialLength;
    if (deleted) await persist();
    return deleted;
  }

  @override
  Future<int> deleteMany(List<String> ids) async {
    final initialLength = items.length;
    items.removeWhere((wallet) => ids.contains(wallet.id));
    final deletedCount = initialLength - items.length;
    if (deletedCount > 0) await persist();
    return deletedCount;
  }

  /// Get total balance across all wallets
  double getTotalBalance() {
    return items.fold(0.0, (sum, wallet) => sum + wallet.currentBalance);
  }

  /// Get wallets by type
  List<Wallet> getByType(WalletType type) {
    return findWhere((wallet) => wallet.type == type);
  }

  /// Update wallet balance (add or subtract amount)
  Future<Wallet?> updateBalance(String id, double amount) async {
    final wallet = getById(id);
    if (wallet == null) return null;

    final newBalance = wallet.currentBalance + amount;
    return updateFields(id, {'currentBalance': newBalance});
  }

  /// Set wallet balance to a specific value
  Future<Wallet?> setBalance(String id, double balance) async {
    return updateFields(id, {'currentBalance': balance});
  }
}
