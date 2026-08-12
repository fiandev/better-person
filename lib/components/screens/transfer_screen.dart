import 'package:flutter/material.dart';

import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _walletController = WalletController();
  final _transactionController = TransactionController();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromWalletId;
  String? _toWalletId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    final wallets = _walletController.getAll();
    setState(() {
      _wallets = wallets;
      if (wallets.length >= 2) {
        _fromWalletId = wallets[0].id;
        _toWalletId = wallets[1].id;
      } else if (wallets.length == 1) {
        _fromWalletId = wallets[0].id;
      }
    });
  }

  void _swapWallets() {
    setState(() {
      final temp = _fromWalletId;
      _fromWalletId = _toWalletId;
      _toWalletId = temp;
    });
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fromWalletId == null || _toWalletId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both wallets')),
        );
      }
      return;
    }

    if (_fromWalletId == _toWalletId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot transfer to the same wallet')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text);
      final fromWallet = _walletController.getById(_fromWalletId!);
      
      if (fromWallet != null && fromWallet.currentBalance < amount) {
        throw Exception('Insufficient balance in source wallet');
      }

      final transaction = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        walletId: _fromWalletId!,
        amount: amount,
        type: TransactionType.transfer,
        category: TransactionCategory.transfer,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: DateTime.now(),
        fromWalletId: _fromWalletId,
        toWalletId: _toWalletId,
      );

      await _transactionController.create(transaction);
      await _walletController.updateBalance(_fromWalletId!, -amount);
      await _walletController.updateBalance(_toWalletId!, amount);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to transfer: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf8f9fa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF0f5238),
        ),
        title: const Text(
          'Transfer Dana',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0f5238),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFe7e8e9),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF191c1d),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildWalletFlowSection(),
              const SizedBox(height: 32),
              _buildAmountSection(),
              const SizedBox(height: 16),
              _buildDateAndNote(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletFlowSection() {
    final fromWallet = _fromWalletId != null 
        ? _walletController.getById(_fromWalletId!) 
        : null;
    final toWallet = _toWalletId != null 
        ? _walletController.getById(_toWalletId!) 
        : null;

    if (_wallets.length < 2) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFffffff),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Color(0xFF707973),
            ),
            SizedBox(height: 16),
            Text(
              'Not enough wallets',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF707973),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You need at least 2 wallets to transfer funds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: Color(0xFF707973),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildWalletCard(
          wallet: fromWallet,
          label: 'From Account',
          onTap: () => _showWalletSelector(isFromWallet: true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF0f5238),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x141b4332),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _swapWallets,
                borderRadius: BorderRadius.circular(24),
                child: const Icon(
                  Icons.swap_vert,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        _buildWalletCard(
          wallet: toWallet,
          label: 'To Account',
          onTap: () => _showWalletSelector(isFromWallet: false),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        border: Border.all(
          color: const Color(0xFFbfc9c1).withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Transfer Amount',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 16,
              color: Color(0xFF404943),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF707973),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: IntrinsicWidth(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: Color(0xFF191c1d),
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Color(0xFFbfc9c1),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Amount required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid amount';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFe1e3e4),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndNote() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFffffff),
              border: Border.all(color: const Color(0xFFbfc9c1)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A1b4332),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATE',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: Color(0xFF404943),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0f5238),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFffffff),
              border: Border.all(color: const Color(0xFFbfc9c1)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A1b4332),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOTE (OPTIONAL)',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: Color(0xFF404943),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 16,
                    color: Color(0xFF191c1d),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'What is this for?',
                    hintStyle: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      color: Color(0xFFbfc9c1),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveTransfer,
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_outlined, size: 20),
        label: Text(
          _isSaving ? 'Processing...' : 'Confirm Transfer',
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2d6a4f),
          foregroundColor: const Color(0xFFa8e7c5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _showWalletSelector({required bool isFromWallet}) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFf8f9fa),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFbfc9c1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFromWallet ? 'Select Source Wallet' : 'Select Destination Wallet',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF191c1d),
                ),
              ),
              const SizedBox(height: 16),
              ..._wallets.map((wallet) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2d6a4f),
                      child: Icon(
                        _getWalletIcon(wallet.icon),
                        color: const Color(0xFFa8e7c5),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      wallet.name,
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '\$${wallet.currentBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                      ),
                    ),
                    trailing: wallet.id == (isFromWallet ? _fromWalletId : _toWalletId)
                        ? const Icon(Icons.check, color: Color(0xFF0f5238))
                        : null,
                    onTap: () => Navigator.pop(context, wallet.id),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isFromWallet) {
          _fromWalletId = result;
          if (_fromWalletId == _toWalletId && _wallets.length > 1) {
            _toWalletId = _wallets.firstWhere((w) => w.id != result).id;
          }
        } else {
          _toWalletId = result;
          if (_fromWalletId == _toWalletId && _wallets.length > 1) {
            _fromWalletId = _wallets.firstWhere((w) => w.id != result).id;
          }
        }
      });
    }
  }

  IconData _getWalletIcon(WalletIcon icon) {
    switch (icon) {
      case WalletIcon.wallet:
        return Icons.account_balance_wallet;
      case WalletIcon.savings:
        return Icons.savings_outlined;
      case WalletIcon.flight:
        return Icons.flight_takeoff;
      case WalletIcon.home:
        return Icons.home_work_outlined;
      case WalletIcon.car:
        return Icons.directions_car_outlined;
      case WalletIcon.bank:
        return Icons.account_balance;
    }
  }

  Widget _buildWalletCard({
    required Wallet? wallet,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFffffff),
          border: Border.all(
            color: const Color(0xFFbfc9c1).withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1b4332),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: wallet == null
            ? Column(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      color: Color(0xFF404943),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select Wallet',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0f5238),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 16,
                              color: Color(0xFF404943),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wallet.name,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0f5238),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _getWalletIcon(wallet.icon),
                        size: 32,
                        color: const Color(0xFF0f5238),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label.contains('From') ? 'Available Balance' : 'Current Balance',
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      color: Color(0xFF404943),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${wallet.currentBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.56,
                          color: Color(0xFF191c1d),
                        ),
                      ),
                      Text(
                        wallet.accountNumber,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.7,
                          color: Color(0xFF707973),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
