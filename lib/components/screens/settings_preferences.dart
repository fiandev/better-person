import 'package:flutter/material.dart';

import '../../controllers/setting_controller.dart';
import '../../utils/notification_service.dart';

class SettingsPreferences extends StatelessWidget {
  const SettingsPreferences({super.key});

  static const _focusOptions = [15, 20, 25, 30, 45, 50, 60];
  static const _breakOptions = [3, 5, 10];
  static const _longBreakOptions = [10, 15, 20, 30];
  static const _cycleOptions = [2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final controller = SettingController();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final setting = controller.getCurrentSetting();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: const ['light', 'dark', 'system']
                          .contains(setting.themeMode)
                      ? setting.themeMode
                      : 'light',
                  decoration: const InputDecoration(labelText: 'Appearance'),
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    DropdownMenuItem(
                      value: 'system',
                      child: Text('Use device setting'),
                    ),
                  ],
                  onChanged: (value) =>
                      _save(controller, setting.id, 'themeMode', value),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: const ['en', 'id'].contains(setting.localeCode)
                      ? setting.localeCode
                      : 'en',
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(
                      value: 'id',
                      child: Text('Bahasa Indonesia'),
                    ),
                  ],
                  onChanged: (value) =>
                      _save(controller, setting.id, 'localeCode', value),
                ),
                if (NotificationService.isSupported)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Browser timer alerts'),
                    subtitle: const Text(
                      'Play a short sound and show a browser notification when a timer ends.',
                    ),
                    value: setting.notificationsEnabled,
                    onChanged: (enabled) => _toggleNotifications(
                      context,
                      controller,
                      setting.id,
                      enabled,
                    ),
                  ),
                const SizedBox(height: 8),
                _NumberSetting(
                  label: 'Focus duration',
                  value: setting.focusMinutes,
                  values: _focusOptions,
                  suffix: 'min',
                  onChanged: (value) =>
                      _save(controller, setting.id, 'focusMinutes', value),
                ),
                _NumberSetting(
                  label: 'Short break',
                  value: setting.breakMinutes,
                  values: _breakOptions,
                  suffix: 'min',
                  onChanged: (value) =>
                      _save(controller, setting.id, 'breakMinutes', value),
                ),
                _NumberSetting(
                  label: 'Long break',
                  value: setting.longBreakMinutes,
                  values: _longBreakOptions,
                  suffix: 'min',
                  onChanged: (value) =>
                      _save(controller, setting.id, 'longBreakMinutes', value),
                ),
                _NumberSetting(
                  label: 'Sessions before long break',
                  value: setting.sessionsBeforeLongBreak,
                  values: _cycleOptions,
                  suffix: 'sessions',
                  onChanged: (value) => _save(
                    controller,
                    setting.id,
                    'sessionsBeforeLongBreak',
                    value,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Weekly kindness goal: ${setting.weeklyKindnessGoal} acts',
                ),
                Slider(
                  value: setting.weeklyKindnessGoal.toDouble().clamp(1, 50),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  onChanged: (value) => _save(
                    controller,
                    setting.id,
                    'weeklyKindnessGoal',
                    value.round(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(
    SettingController controller,
    String id,
    String key,
    Object? value,
  ) async {
    if (value == null) return;
    await controller.updateFields(id, {key: value});
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    SettingController controller,
    String id,
    bool enabled,
  ) async {
    if (enabled && !await NotificationService.requestPermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Browser notification permission was not granted.'),
          ),
        );
      }
      return;
    }
    await _save(controller, id, 'notificationsEnabled', enabled);
  }
}

class _NumberSetting extends StatelessWidget {
  const _NumberSetting({
    required this.label,
    required this.value,
    required this.values,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> values;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: values.contains(value) ? value : values.first,
    decoration: InputDecoration(labelText: label),
    items: values
        .map(
          (item) => DropdownMenuItem(value: item, child: Text('$item $suffix')),
        )
        .toList(),
    onChanged: (item) {
      if (item != null) onChanged(item);
    },
  );
}
