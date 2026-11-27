import 'package:material_ui/material_ui.dart';

import '../../controllers/wallet_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/wallet.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _walletController = WalletController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  WalletIcon _selectedIcon = WalletIcon.wallet;
  WalletType _selectedType = WalletType.general;
  bool _isSaving = false;

  String _previewName = 'Dompet Baru';
  double _previewBalance = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  static const _iconOptions = [
    (
      WalletIcon.wallet,
      WalletType.general,
      'Dompet Umum',
      'account_balance_wallet',
    ),
    (WalletIcon.savings, WalletType.savings, 'Tabungan', 'savings'),
    (WalletIcon.flight, WalletType.travel, 'Perjalanan', 'flight_takeoff'),
    (WalletIcon.home, WalletType.home, 'Rumah', 'home_work'),
    (WalletIcon.car, WalletType.vehicle, 'Kendaraan', 'directions_car'),
  ];

  Future<void> _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final initialBalance = double.tryParse(_balanceController.text) ?? 0.0;
      final accountNumber =
          '**** ${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString()}';

      final wallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        type: _selectedType,
        icon: _selectedIcon,
        initialBalance: initialBalance,
        currentBalance: initialBalance,
        accountNumber: accountNumber,
        createdAt: DateTime.now(),
      );

      await _walletController.create(wallet);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save wallet: $e')));
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
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          'Tambah Dompet',
          style: textTheme.headlineMedium?.copyWith(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16), // container-padding-mobile
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              _buildPreviewCard(),
              const SizedBox(height: 32), // stack-lg
              // Form Section
              _buildFormSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0f5238),
            Color(0xFF2d6a4f),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // rounded-xl
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blur circle
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(_selectedIcon),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Text(
                    '**** 1234',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Saldo Saat Ini',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${SettingController().getCurrentSetting().defaultCurrencyFormat} ${_previewBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _previewName,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
          // Name field
          _buildLabel('Nama Dompet'),
          const SizedBox(height: 8),
          _buildNameField(),
          const SizedBox(height: 16), // stack-md
          // Balance field
          _buildLabel('Saldo Awal'),
          const SizedBox(height: 8),
          _buildBalanceField(),
          const SizedBox(height: 8),
          _buildWarningBox(),
          const SizedBox(height: 16),

          // Icon selector
          _buildLabel('Pilih Ikon'),
          const SizedBox(height: 8),
          _buildIconSelector(),
          const SizedBox(height: 32), // stack-lg
          // Save button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        fontFamily: 'JetBrains Mono',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.7,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildNameField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: colorScheme.outline,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _nameController,
              onChanged: (value) => setState(() {
                _previewName = value.isEmpty ? 'Dompet Baru' : value;
              }),
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: Tabungan Liburan',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: colorScheme.outline,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 0,
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nama dompet tidak boleh kosong'
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              SettingController().getCurrentSetting().defaultCurrencyFormat,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => setState(() {
                _previewBalance = double.tryParse(value) ?? 0.0;
              }),
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: colorScheme.outline,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        border: Border.all(color: colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saldo awal bersifat permanen dan tidak dapat diubah setelah dompet dibuat. Pastikan jumlahnya benar.',
              style: textTheme.bodySmall?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 13,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: _iconOptions.map((option) {
        final isSelected = _selectedIcon == option.$1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedIcon = option.$1;
              _selectedType = option.$2;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHigh,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconData(option.$1),
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option.$3,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveWallet,
        icon: _isSaving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Dompet',
          style: textTheme.headlineMedium?.copyWith(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  IconData _getIconData(WalletIcon icon) {
    switch (icon) {
      case WalletIcon.wallet:
        return Icons.account_balance_wallet_outlined;
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
}
