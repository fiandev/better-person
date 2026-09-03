import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa), // background
      appBar: AppBar(
        backgroundColor: const Color(0xFFf8f9fa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF404943), // on-surface-variant
        ),
        title: const Text(
          'Tambah Dompet',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0f5238), // primary
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2d6a4f),
            Color(0xFF3f6754),
          ], // primary-container to tertiary-container
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // rounded-xl
        boxShadow: const [
          BoxShadow(
            color: Color(0x141b4332), // rgba(27,67,50,0.08)
            blurRadius: 24,
            offset: Offset(0, 12),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa), // surface-bright
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
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.7,
        color: Color(0xFF404943), // on-surface-variant
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFffffff), // surface-container-lowest
        border: Border.all(color: const Color(0xFFbfc9c1)), // outline-variant
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: Color(0xFF707973), // outline
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _nameController,
              onChanged: (value) => setState(() {
                _previewName = value.isEmpty ? 'Dompet Baru' : value;
              }),
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: Color(0xFF191c1d), // on-surface
              ),
              decoration: const InputDecoration(
                hintText: 'Contoh: Tabungan Liburan',
                hintStyle: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: Color(0xFFbfc9c1),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        border: Border.all(color: const Color(0xFFbfc9c1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              SettingController().getCurrentSetting().defaultCurrencyFormat,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF707973), // outline
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
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: Color(0xFF191c1d),
              ),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: Color(0xFFbfc9c1),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(
          0xFFffdad6,
        ).withValues(alpha: 0.3), // error-container with opacity
        border: Border.all(color: const Color(0xFFffdad6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFba1a1a), size: 16), // error
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saldo awal bersifat permanen dan tidak dapat diubah setelah dompet dibuat. Pastikan jumlahnya benar.',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 13,
                color: Color(0xFF404943),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
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
                    ? const Color(0xFFbdeacd) // secondary-container
                    : const Color(0xFFe7e8e9), // surface-container-high
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0f5238) // primary
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
                        ? const Color(0xFF426b54) // on-secondary-container
                        : const Color(0xFF404943),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option.$3,
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      color: isSelected
                          ? const Color(0xFF426b54)
                          : const Color(0xFF404943),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveWallet,
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Dompet',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0f5238), // primary
          foregroundColor: Colors.white, // on-primary
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
