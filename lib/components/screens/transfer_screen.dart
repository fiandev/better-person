import 'package:material_ui/material_ui.dart';

import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import '../widgets/profile/user_avatar_button.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pop(context),
          color: colorScheme.primary,
        ),
        title: Text(
          'Transfer Dana',
          style: textTheme.headlineMedium?.copyWith(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: UserAvatarButton(),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough wallets',
              style: textTheme.headlineMedium?.copyWith(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need at least 2 wallets to transfer funds',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Work Sans',
                color: colorScheme.outline,
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
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _swapWallets,
                borderRadius: BorderRadius.circular(24),
                child: Icon(
                  Icons.swap_vert,
                  color: colorScheme.onPrimary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
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
        children: [
          Text(
            'Transfer Amount',
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          const SizedBox(height: 8),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(1),
            ),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            border: Border.all(color: colorScheme.outlineVariant),
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
              Text(
                'DATE',
                style: textTheme.labelSmall?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: colorScheme.onSurfaceVariant,
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
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            border: Border.all(color: colorScheme.outlineVariant),
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
              Text(
                'NOTE (OPTIONAL)',
                style: textTheme.labelSmall?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'What is this for?',
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

  Widget _buildSubmitButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveTransfer,
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
          _isSaving ? 'Processing...' : 'Confirm Transfer',
          style: textTheme.bodyLarge?.copyWith(
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
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
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFromWallet ? 'Select Source Wallet' : 'Select Destination Wallet',
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ..._wallets.map((wallet) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        _getWalletIcon(wallet.icon),
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      wallet.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${SettingController().getCurrentSetting().defaultCurrencyFormat}${wallet.currentBalance.toStringAsFixed(2)}',
                      style: textTheme.labelMedium?.copyWith(
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                    trailing: wallet.id == (isFromWallet ? _fromWalletId : _toWalletId)
                        ? Icon(Icons.check, color: colorScheme.primary)
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: wallet == null
            ? Column(
                children: [
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Work Sans',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select Wallet',
                    style: textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
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
                            style: textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Work Sans',
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wallet.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _getWalletIcon(wallet.icon),
                        size: 32,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label.contains('From') ? 'Available Balance' : 'Current Balance',
                    style: textTheme.labelMedium?.copyWith(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${SettingController().getCurrentSetting().defaultCurrencyFormat} ${wallet.currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.56,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        wallet.accountNumber,
                        style: textTheme.labelMedium?.copyWith(
                          fontFamily: 'JetBrains Mono',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.7,
                          color: colorScheme.outline,
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
