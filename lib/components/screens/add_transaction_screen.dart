import 'package:flutter/material.dart';

import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _walletController = WalletController();
  final _transactionController = TransactionController();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _transactionType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.foodAndDrink;
  String? _selectedWalletId;
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
      if (wallets.isNotEmpty && _selectedWalletId == null) {
        _selectedWalletId = wallets.first.id;
      }
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a wallet')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text);

      final transaction = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        walletId: _selectedWalletId!,
        amount: amount,
        type: _transactionType,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _transactionController.create(transaction);

      final balanceChange = _transactionType == TransactionType.income
          ? amount
          : -amount;
      await _walletController.updateBalance(_selectedWalletId!, balanceChange);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa), // surface
      appBar: AppBar(
        backgroundColor: const Color(0xFFf8f9fa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF0f5238), // primary
        ),
        title: const Text(
          'Finance',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0f5238), // primary
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
        child: Column(
          children: [
            // Dynamic header section with type toggle and amount
            _buildHeaderSection(),

            // Scrollable form section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildWalletSelector(),
                    const SizedBox(height: 16),
                    _buildCategorySelector(),
                    const SizedBox(height: 16),
                    _buildDateAndNote(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildHeaderSection() {
    // Dynamic background: error-container for expense, primary-fixed for income
    final bgColor = _transactionType == TransactionType.expense
        ? const Color(0xFFffdad6).withValues(alpha: 0.3) // error-container
        : const Color(0xFFb1f0ce).withValues(alpha: 0.3); // primary-fixed

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Income/Expense Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFe7e8e9), // surface-container-high
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeToggle(
                    label: 'Expense',
                    isSelected: _transactionType == TransactionType.expense,
                    color: const Color(0xFFba1a1a), // error
                    onTap: () => setState(() {
                      _transactionType = TransactionType.expense;
                      if (_selectedCategory.index >
                          TransactionCategory.other.index) {
                        _selectedCategory = TransactionCategory.foodAndDrink;
                      }
                    }),
                  ),
                ),
                Expanded(
                  child: _buildTypeToggle(
                    label: 'Income',
                    isSelected: _transactionType == TransactionType.income,
                    color: const Color(0xFF0f5238), // primary
                    onTap: () => setState(() {
                      _transactionType = TransactionType.income;
                      if (_selectedCategory.index <=
                          TransactionCategory.other.index) {
                        _selectedCategory = TransactionCategory.salary;
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Amount Input
          Column(
            children: [
              const Text(
                'How much?',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: Color(0xFF404943), // on-surface-variant
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      SettingController().getCurrentSetting().defaultCurrencyFormat,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF707973), // outline
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: IntrinsicWidth(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: Color(0xFF191c1d), // on-surface
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            color: Color.fromARGB(
                              87,
                              25,
                              28,
                              29,
                            ), // outline-variant
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFffffff) // surface-container-lowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x0A1b4332),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
            color: isSelected ? color : const Color(0xFF404943),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff), // surface-container-lowest
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
          Row(
            children: const [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Color(0xFF404943), // on-surface-variant
              ),
              SizedBox(width: 8),
              Text(
                'Source Account',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.7,
                  color: Color(0xFF404943),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_wallets.isEmpty)
            const Text(
              'No wallets available',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: Color(0xFF707973),
              ),
            )
          else
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _wallets.map((wallet) {
                  final isSelected = wallet.id == _selectedWalletId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedWalletId = wallet.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFbdeacd) // secondary-container
                              : const Color(0xFFf8f9fa), // surface
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3e6750) // secondary
                                : const Color(0xFFbfc9c1), // outline-variant
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFffffff),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getWalletIcon(wallet.icon),
                                size: 18,
                                color: isSelected
                                    ? const Color(0xFF3e6750)
                                    : const Color(0xFF404943),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF426b54)
                                        : const Color(0xFF191c1d),
                                  ),
                                ),
                                Text(
                                  wallet.accountNumber,
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 10,
                                    color: Color(0xFF707973),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = _transactionType == TransactionType.income
        ? [
            TransactionCategory.salary,
            TransactionCategory.freelance,
            TransactionCategory.investment,
            TransactionCategory.gift,
            TransactionCategory.refund,
            TransactionCategory.other,
          ]
        : [
            TransactionCategory.foodAndDrink,
            TransactionCategory.transport,
            TransactionCategory.groceries,
            TransactionCategory.shopping,
            TransactionCategory.utilities,
            TransactionCategory.entertainment,
            TransactionCategory.healthcare,
            TransactionCategory.education,
            TransactionCategory.other,
          ];

    // Ensure selected category is valid
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
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
          Row(
            children: const [
              Icon(Icons.category_outlined, size: 18, color: Color(0xFF404943)),
              SizedBox(width: 8),
              Text(
                'Category',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.7,
                  color: Color(0xFF404943),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2d6a4f) // primary-container
                        : const Color(0xFFedeeef), // surface-container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCategoryLabel(category),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFa8e7c5) // on-primary-container
                          : const Color(0xFF191c1d),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndNote() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFffffff),
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
              Row(
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Color(0xFF404943),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.7,
                      color: Color(0xFF404943),
                    ),
                  ),
                ],
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
                child: InputDecorator(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFbfc9c1)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFbfc9c1)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2d6a4f)),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF707973),
                    ),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      color: Color(0xFF191c1d),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFffffff),
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
              Row(
                children: const [
                  Icon(Icons.notes, size: 18, color: Color(0xFF404943)),
                  SizedBox(width: 8),
                  Text(
                    'Note',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.7,
                      color: Color(0xFF404943),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: Color(0xFF191c1d),
                ),
                decoration: const InputDecoration(
                  hintText: 'What was this for?',
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFf8f9fa),
            const Color(0xFFf8f9fa),
            const Color(0xFFf8f9fa).withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveTransaction,
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
            _isSaving ? 'Saving...' : 'Save Transaction',
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2d6a4f), // primary-container
            foregroundColor: const Color(0xFFa8e7c5), // on-primary-container
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ),
    );
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

  String _getCategoryLabel(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.foodAndDrink:
        return 'Food & Drink';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.healthcare:
        return 'Healthcare';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.gift:
        return 'Gift';
      case TransactionCategory.refund:
        return 'Refund';
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.other:
        return 'Other';
    }
  }
}
