import 'package:flutter/material.dart';

class BadgeConfig {
  static List<BadgeDefinition> getAllBadges() {
    return [
      // Focus Badges
      BadgeDefinition(
        id: 'focus_master',
        title: 'Focus Master',
        detail: 'Tracked 10 hours of deep work',
        icon: Icons.psychology,
        backgroundColor: const Color(0xFF2A6485),
        checkFunction: (context) => _checkFocusMaster(context),
      ),
      BadgeDefinition(
        id: 'focus_warrior',
        title: 'Focus Warrior',
        detail: 'Tracked 25 hours of deep work',
        icon: Icons.psychology,
        backgroundColor: const Color(0xFF2A6485),
        checkFunction: (context) => _checkFocusWarrior(context),
      ),
      BadgeDefinition(
        id: 'first_focus',
        title: 'First Focus',
        detail: 'Completed your first focus session',
        icon: Icons.flag,
        backgroundColor: const Color(0xFF2A6485),
        checkFunction: (context) => _checkFirstFocus(context),
      ),
      
      // Habit Badges
      BadgeDefinition(
        id: 'streak_3',
        title: '3-Day Streak',
        detail: 'Maintained a 3-day streak',
        icon: Icons.local_fire_department,
        backgroundColor: const Color(0xFF0F5238),
        checkFunction: (context) => _checkStreak3(context),
      ),
      BadgeDefinition(
        id: 'streak_7',
        title: '7-Day Streak',
        detail: 'Maintained a 7-day streak',
        icon: Icons.local_fire_department,
        backgroundColor: const Color(0xFF0F5238),
        checkFunction: (context) => _checkStreak7(context),
      ),
      BadgeDefinition(
        id: 'streak_30',
        title: '30-Day Streak',
        detail: 'Maintained a 30-day streak',
        icon: Icons.local_fire_department,
        backgroundColor: const Color(0xFF0F5238),
        checkFunction: (context) => _checkStreak30(context),
      ),
      
      // Devotion Badges
      BadgeDefinition(
        id: 'prayer_consistent',
        title: 'Prayer Consistent',
        detail: 'Prayed 5 times a day for 7 days',
        icon: Icons.self_improvement,
        backgroundColor: const Color(0xFF634019),
        checkFunction: (context) => _checkPrayerConsistent(context),
      ),
      BadgeDefinition(
        id: 'early_bird',
        title: 'Early Bird',
        detail: 'Prayed Fajr on time for 5 days',
        icon: Icons.wb_sunny,
        backgroundColor: const Color(0xFF634019),
        checkFunction: (context) => _checkEarlyBird(context),
      ),
      
      // Kindness Badges
      BadgeDefinition(
        id: 'helper',
        title: 'Helper',
        detail: 'Completed 10 acts of kindness',
        icon: Icons.favorite,
        backgroundColor: const Color(0xFF0F5238),
        checkFunction: (context) => _checkHelper(context),
      ),
      BadgeDefinition(
        id: 'kindness_warrior',
        title: 'Kindness Warrior',
        detail: 'Completed 50 acts of kindness',
        icon: Icons.favorite,
        backgroundColor: const Color(0xFF0F5238),
        checkFunction: (context) => _checkKindnessWarrior(context),
      ),
    ];
  }
  
  // Check functions
  static Future<bool> _checkFocusMaster(BadgeCheckContext context) async {
    return context.totalFocusHours >= 10;
  }
  
  static Future<bool> _checkFocusWarrior(BadgeCheckContext context) async {
    return context.totalFocusHours >= 25;
  }
  
  static Future<bool> _checkFirstFocus(BadgeCheckContext context) async {
    return context.completedFocusSessions >= 1;
  }
  
  static Future<bool> _checkStreak3(BadgeCheckContext context) async {
    return context.currentStreak >= 3;
  }
  
  static Future<bool> _checkStreak7(BadgeCheckContext context) async {
    return context.currentStreak >= 7;
  }
  
  static Future<bool> _checkStreak30(BadgeCheckContext context) async {
    return context.currentStreak >= 30;
  }
  
  static Future<bool> _checkPrayerConsistent(BadgeCheckContext context) async {
    return context.consecutivePrayerDays >= 7;
  }
  
  static Future<bool> _checkEarlyBird(BadgeCheckContext context) async {
    return context.fajrOnTime >= 5;
  }
  
  static Future<bool> _checkHelper(BadgeCheckContext context) async {
    return context.totalKindnessActs >= 10;
  }
  
  static Future<bool> _checkKindnessWarrior(BadgeCheckContext context) async {
    return context.totalKindnessActs >= 50;
  }
}

class BadgeDefinition {
  final String id;
  final String title;
  final String detail;
  final IconData icon;
  final Color backgroundColor;
  final Future<bool> Function(BadgeCheckContext) checkFunction;
  
  BadgeDefinition({
    required this.id,
    required this.title,
    required this.detail,
    required this.icon,
    required this.backgroundColor,
    required this.checkFunction,
  });
}

class BadgeCheckContext {
  final double totalFocusHours;
  final int completedFocusSessions;
  final int currentStreak;
  final int consecutivePrayerDays;
  final int fajrOnTime;
  final int totalKindnessActs;
  
  BadgeCheckContext({
    required this.totalFocusHours,
    required this.completedFocusSessions,
    required this.currentStreak,
    required this.consecutivePrayerDays,
    required this.fajrOnTime,
    required this.totalKindnessActs,
  });
}
