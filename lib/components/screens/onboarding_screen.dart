import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../utils/default_data_seeder.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  int _weeklyKindnessGoal = 14;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your name to continue.')),
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    await UserController().create(
      User(
        id: 'user_${now.microsecondsSinceEpoch}',
        name: name,
        streak: 0,
        dailyProgress: 0,
        totalHabitsDone: 0,
        totalFocusHours: 0,
        totalKindActs: 0,
        growthScore: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await SettingController().ensureSettingsExist();
    final settings = SettingController().getCurrentSetting();
    await SettingController().updateFields(settings.id, {
      'weeklyKindnessGoal': _weeklyKindnessGoal,
    });
    await DefaultDataSeeder.seedHabits();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Better Person',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set up your personal habit space.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _continue(),
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Weekly kindness goal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a target that feels manageable.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  Slider(
                    value: _weeklyKindnessGoal.toDouble(),
                    min: 1,
                    max: 28,
                    divisions: 27,
                    label: '$_weeklyKindnessGoal acts',
                    onChanged: (value) =>
                        setState(() => _weeklyKindnessGoal = value.round()),
                  ),
                  Text('$_weeklyKindnessGoal acts each week'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _continue,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create my habits'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
