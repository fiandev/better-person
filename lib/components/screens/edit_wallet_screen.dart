import 'package:material_ui/material_ui.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
            child: TextField(
              controller: _nameController,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Work Sans',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                hintText: 'Contoh: Tabungan Liburan',
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

  Widget _buildCategoryTile(
    (WalletType, WalletIcon, String, IconData) category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
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
                iconData,
                size: 24,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: textTheme.bodyLarge?.copyWith(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
