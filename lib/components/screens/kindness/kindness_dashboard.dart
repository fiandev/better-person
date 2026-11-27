import 'package:material_ui/material_ui.dart';

import '../../../controllers/kindness_act_controller.dart';
import '../../theme/habit_focus_theme.dart';
import 'kindness_ideas_card.dart';
import 'kindness_impact_card.dart';
import 'kindness_reflection_card.dart';

class KindnessDashboard extends StatefulWidget {
  const KindnessDashboard({
    super.key,
    required this.colorScheme,
    required this.kindnessActController,
    required this.reflectionController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final ColorScheme colorScheme;
  final KindnessActController kindnessActController;
  final TextEditingController reflectionController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  State<KindnessDashboard> createState() => _KindnessDashboardState();
}

class _KindnessDashboardState extends State<KindnessDashboard> {
  Future<void> _toggleAct(String id) async {
    await widget.kindnessActController.toggleSelection(id);
    if (mounted) setState(() {});
  }

  Widget _ideas() => KindnessIdeasCard(
        colorScheme: widget.colorScheme,
        kindnessActController: widget.kindnessActController,
        onToggleChip: _toggleAct,
      );

  Widget _impact() => KindnessImpactCard(colorScheme: widget.colorScheme);

  Widget _reflection() => KindnessReflectionCard(
        colorScheme: widget.colorScheme,
        controller: widget.reflectionController,
        isSubmitting: widget.isSubmitting,
        onSubmit: widget.onSubmit,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _ideas()),
                    const SizedBox(width: HabitFocusTheme.stackGap),
                    Expanded(child: _impact()),
                  ],
                ),
                const SizedBox(height: HabitFocusTheme.stackGap),
                _reflection(),
              ],
            );
          }
          return Column(
            children: [
              _ideas(),
              const SizedBox(height: HabitFocusTheme.stackGap),
              _impact(),
              const SizedBox(height: HabitFocusTheme.stackGap),
              _reflection(),
            ],
          );
        },
      );
}
