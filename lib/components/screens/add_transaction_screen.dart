import 'package:material_ui/material_ui.dart';

import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import '../widgets/profile/user_avatar_button.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: colorScheme.primary,
        ),
        title: Text(
          'Finance',
          style: textTheme.headlineMedium?.copyWith(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: UserAvatarButton(),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Dynamic background: errorContainer for expense, primaryContainer for income
    final bgColor = _transactionType == TransactionType.expense
        ? colorScheme.errorContainer.withValues(alpha: 0.3)
        : colorScheme.primaryContainer.withValues(alpha: 0.3);

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
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeToggle(
                    label: 'Expense',
                    isSelected: _transactionType == TransactionType.expense,
                    color: colorScheme.error,
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
                    color: colorScheme.primary,
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
              Text(
                'How much?',
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  color: colorScheme.onSurfaceVariant,
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
                      style: textTheme.headlineLarge?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: colorScheme.outline,
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
                        style: textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Manrope',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: textTheme.headlineLarge?.copyWith(
                            fontFamily: 'Manrope',
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            color: colorScheme.outlineVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.labelMedium?.copyWith(
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
            color: isSelected ? color : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Source Account',
                style: textTheme.labelMedium?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.7,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_wallets.isEmpty)
            Text(
              'No wallets available',
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Work Sans',
                color: colorScheme.outline,
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
                              ? colorScheme.primaryContainer
                              : colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getWalletIcon(wallet.icon),
                                size: 18,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  wallet.name,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontFamily: 'Work Sans',
                                    color: isSelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  wallet.accountNumber,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 10,
                                    color: isSelected
                                        ? colorScheme.onPrimaryContainer
                                            .withValues(alpha: 0.8)
                                        : colorScheme.outline,
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Category',
                style: textTheme.labelMedium?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.7,
                  color: colorScheme.onSurfaceVariant,
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
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCategoryLabel(category),
                    style: textTheme.labelMedium?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Date',
                    style: textTheme.labelMedium?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.7,
                      color: colorScheme.onSurfaceVariant,
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
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Work Sans',
                      color: colorScheme.onSurface,
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
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notes,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Note',
                    style: textTheme.labelMedium?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.7,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'What was this for?',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Work Sans',
                    color: colorScheme.outlineVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveTransaction,
          icon: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimaryContainer,
                    ),
                  ),
                )
              : const Icon(Icons.check_circle_outlined, size: 20),
          label: Text(
            _isSaving ? 'Saving...' : 'Save Transaction',
            style: textTheme.bodyLarge?.copyWith(
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
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
