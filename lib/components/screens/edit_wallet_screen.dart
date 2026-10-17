import 'package:flutter/material.dart';

import '../../controllers/wallet_controller.dart';
import '../../models/wallet.dart';
import '../widgets/habit_focus_app_bar.dart';

/// Lets the user rename a wallet and change its category (type + icon).
class EditWalletScreen extends StatefulWidget {
  const EditWalletScreen({super.key, required this.wallet});

  final Wallet wallet;

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  static const _categories = [
    (WalletType.general, WalletIcon.wallet, 'Umum', Icons.wallet_outlined),
    (
      WalletType.checking,
      WalletIcon.bank,
      'Pemeriksaan',
      Icons.account_balance,
    ),
    (
      WalletType.savings,
      WalletIcon.savings,
      'Tabungan',
      Icons.savings_outlined,
    ),
    (WalletType.travel, WalletIcon.flight, 'Perjalanan', Icons.flight_takeoff),
    (WalletType.home, WalletIcon.home, 'Rumah', Icons.home_work_outlined),
    (
      WalletType.vehicle,
      WalletIcon.car,
      'Kendaraan',
      Icons.directions_car_outlined,
    ),
  ];

  final _walletController = WalletController();
  late final TextEditingController _nameController;
  late WalletType _selectedType;
  late WalletIcon _selectedIcon;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _selectedType = widget.wallet.type;
    _selectedIcon = widget.wallet.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dompet tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);
    await _walletController.updateFields(widget.wallet.id, {
      'name': name,
      'type': _selectedType,
      'icon': _selectedIcon,
    });
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: const HabitFocusAppBar(overrideTitle: 'Edit Dompet'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLabel('Nama Dompet'),
          const SizedBox(height: 8),
          _buildNameField(),
          const SizedBox(height: 24),
          _buildLabel('Kategori'),
          const SizedBox(height: 8),
          ..._categories.map(_buildCategoryTile),
          const SizedBox(height: 32),
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
        color: const Color(0xFFffffff),
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
              color: Color(0xFF707973),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: Color(0xFF191c1d), // on-surface
              ),
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                hintText: 'Contoh: Tabungan Liburan',
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

  Widget _buildCategoryTile(
    (WalletType, WalletIcon, String, IconData) category,
  ) {
    final (type, icon, label, iconData) = category;
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _isSaving
            ? null
            : () => setState(() {
                _selectedType = type;
                _selectedIcon = icon;
              }),
        borderRadius: BorderRadius.circular(8),
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
                iconData,
                size: 24,
                color: isSelected
                    ? const Color(0xFF426b54) // on-secondary-container
                    : const Color(0xFF404943),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: isSelected
                      ? const Color(0xFF426b54)
                      : const Color(0xFF404943),
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Color(0xFF0f5238),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0f5238), // primary
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
