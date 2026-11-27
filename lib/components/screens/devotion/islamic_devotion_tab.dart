import 'package:material_ui/material_ui.dart';

import '../../../components/theme/habit_focus_theme.dart';
import 'dzikir_tracker_section.dart';
import 'prayer_tracker_section.dart';
import 'quran_tracker_section.dart';

class IslamicDevotionTab extends StatelessWidget {
  const IslamicDevotionTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
    children: const [
      PrayerTrackerSection(),
      SizedBox(height: HabitFocusTheme.sectionGap),
      DzikirTrackerSection(),
      SizedBox(height: HabitFocusTheme.sectionGap),
      QuranTrackerSection(),
    ],
  );
}
