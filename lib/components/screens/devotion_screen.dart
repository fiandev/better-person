import 'package:flutter/material.dart';

import '../widgets/habit_focus_app_bar.dart';
import '../../routes/route_shell.dart';
import 'devotion/custom_devotions_tab.dart';
import 'devotion/islamic_devotion_tab.dart';

class DevotionScreen extends StatefulWidget {
  const DevotionScreen({super.key});

  @override
  State<DevotionScreen> createState() => _DevotionScreenState();
}

class _DevotionScreenState extends State<DevotionScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HabitFocusAppBar(overrideTitle: 'Devotion'),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Islamic')),
              ButtonSegment(value: 1, label: Text('Custom')),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (value) =>
                setState(() => _selectedTab = value.first),
            showSelectedIcon: false,
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: const [IslamicDevotionTab(), CustomDevotionsTab()],
          ),
        ),
      ],
    ),
    bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 2),
  );
}
