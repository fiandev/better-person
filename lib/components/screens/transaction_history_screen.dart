import 'package:flutter/material.dart';

import '../../controllers/transaction_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _transactions = TransactionController();
  final _wallets = WalletController();
  String? _walletId;
  TransactionType? _type;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _transactions.addListener(_reload);
    _wallets.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    _transactions.removeListener(_reload);
    _wallets.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = null;
    });
  }

  List<Transaction> get _visibleTransactions {
    final items = _transactions.getRecent(limit: 1000).where((item) {
      final matchesWallet =
          _walletId == null ||
          item.walletId == _walletId ||
          item.fromWalletId == _walletId ||
          item.toWalletId == _walletId;
      return matchesWallet && (_type == null || item.type == _type);
    }).toList();
    return items;
  }

  Future<void> _edit(Transaction item) async {
    final controller = TextEditingController(
      text: item.amount.toStringAsFixed(2),
    );
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit amount'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.pop(context, value != null && value > 0 ? value : null);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null) return;
    final updated = item.copyWith(amount: amount);
    final saved = await _transactions.updateAndRebalance(item.id, updated);
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This change would make a wallet balance negative.'),
        ),
      );
    }
  }

  Future<void> _delete(Transaction item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'The wallet balance will be reversed with this transaction.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await _transactions.deleteAndReverse(item.id);
    if (!deleted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not reverse this transaction without a negative balance.',
          ),
        ),
      );
    }
  }

  Future<void> _recalculate() async {
    await _wallets.recalculateBalanceFromTransactions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet balances recalculated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = _wallets.getAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction history'),
        actions: [
          IconButton(
            tooltip: 'Recalculate balances',
            onPressed: _recalculate,
            icon: const Icon(Icons.calculate_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Could not load transactions: $_error'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _walletId,
                          decoration: const InputDecoration(
                            labelText: 'Wallet',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All wallets'),
                            ),
                            ...wallets.map(
                              (wallet) => DropdownMenuItem<String?>(
                                value: wallet.id,
                                child: Text(
                                  wallet.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _walletId = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<TransactionType?>(
                          initialValue: _type,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: const [
                            DropdownMenuItem<TransactionType?>(
                              value: null,
                              child: Text('All types'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.income,
                              child: Text('Income'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.expense,
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.transfer,
                              child: Text('Transfer'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _type = value),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _visibleTransactions.isEmpty
                      ? const Center(
                          child: Text('No transactions match these filters.'),
                        )
                      : ListView.builder(
                          itemCount: _visibleTransactions.length,
                          itemBuilder: (context, index) => _TransactionTile(
                            transaction: _visibleTransactions[index],
                            wallet: _wallets.getById(
                              _visibleTransactions[index].walletId,
                            ),
                            onEdit: () => _edit(_visibleTransactions[index]),
                            onDelete: () =>
                                _delete(_visibleTransactions[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.wallet,
    required this.onEdit,
    required this.onDelete,
  });

  final Transaction transaction;
  final Wallet? wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.type == TransactionType.income
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    final sign = transaction.type == TransactionType.income ? '+' : '-';
    return ListTile(
      title: Text(transaction.getCategoryLabel()),
      subtitle: Text(
        '${wallet?.name ?? 'Unknown wallet'} • ${transaction.date.toLocal().toString().split(' ').first}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$sign${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(color: amountColor),
          ),
          PopupMenuButton<String>(
            tooltip: 'Transaction actions',
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit amount')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
