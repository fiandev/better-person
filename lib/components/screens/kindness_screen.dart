import 'package:material_ui/material_ui.dart';

import '../../controllers/controllers.dart';
import '../../routes/route_shell.dart';
import '../../utils/habit_auto_checker.dart';
import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import 'kindness/kindness_dashboard.dart';
import 'kindness/kindness_header.dart';

class KindnessScreen extends StatefulWidget {
  const KindnessScreen({super.key});

  @override
  State<KindnessScreen> createState() => _KindnessScreenState();
}

class _KindnessScreenState extends State<KindnessScreen> {
  final _reflectionController = TextEditingController();
  final _kindnessActController = KindnessActController();
  final _kindnessLogController = KindnessLogController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _handleLogKindness() async {
    final selectedActs = _kindnessActController.getSelected();
    final reflection = _reflectionController.text.trim();
    if (selectedActs.isEmpty && reflection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an act or write a reflection.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final actIds = selectedActs.map((act) => act.id).toList();
      await _kindnessLogController.logKindness(actIds, reflection);
      await UserController().incrementKindActs(actIds.length);
      final log = _kindnessLogController.getTodayLog();
      if (log != null) {
        await HabitAutoChecker().onKindnessLogComplete(log);
      }
      _reflectionController.clear();
      await _kindnessActController.clearSelection();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kindness logged.')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save kindness log: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const HabitFocusAppBar(overrideTitle: 'Kindness'),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          KindnessHeader(colorScheme: colors),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          KindnessDashboard(
            colorScheme: colors,
            kindnessActController: _kindnessActController,
            reflectionController: _reflectionController,
            isSubmitting: _isSubmitting,
            onSubmit: _handleLogKindness,
          ),
        ],
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: -1),
    );
  }
}
