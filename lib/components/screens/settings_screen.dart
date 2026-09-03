import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../../controllers/setting_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingController = SettingController();
  late TextEditingController _currencyController;

  final _currencyOptions = ['Rp', '\$', '€', '£', '¥', '₹', '₩', 'A\$'];

  @override
  void initState() {
    super.initState();
    _settingController.ensureSettingsExist();
    final setting = _settingController.getCurrentSetting();
    _currencyController = TextEditingController(text: setting.defaultCurrencyFormat);
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrency(String value) async {
    final setting = _settingController.getCurrentSetting();
    await _settingController.updateFields(setting.id, {
      'defaultCurrencyFormat': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: colorScheme.onSurface,
        ),
        title: Text(
          'Settings',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          _CurrencySection(
            currencyController: _currencyController,
            currencyOptions: _currencyOptions,
            onCurrencyChanged: _saveCurrency,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _CurrencySection extends StatelessWidget {
  const _CurrencySection({
    required this.currencyController,
    required this.currencyOptions,
    required this.onCurrencyChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  final TextEditingController currencyController;
  final List<String> currencyOptions;
  final Function(String) onCurrencyChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on_outlined, size: 18, color: colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(
                'Default Currency',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currencyOptions.map((currency) {
              final isSelected = currencyController.text == currency;
              return GestureDetector(
                onTap: () {
                  currencyController.text = currency;
                  onCurrencyChanged(currency);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    currency,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
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
          const SizedBox(height: 16),
          TextFormField(
            controller: currencyController,
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Custom Currency Symbol',
              labelStyle: TextStyle(color: colorScheme.outline),
              hintText: 'e.g. Rp, \$, €',
              hintStyle: TextStyle(color: colorScheme.outlineVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.check, color: colorScheme.primary),
                onPressed: () {
                  onCurrencyChanged(currencyController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Currency updated')),
                  );
                },
              ),
            ),
            onFieldSubmitted: (value) => onCurrencyChanged(value),
          ),
        ],
      ),
    );
  }
}
