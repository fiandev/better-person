import '../controllers/controllers.dart';
import '../models/models.dart';
import 'badge_config.dart';

class BadgeChecker {
  /// Check all badges and award new ones
  static Future<List<Badge>> checkAndAwardBadges() async {
    final newBadges = <Badge>[];
    
    // Build context
    final context = await _buildBadgeContext();
    
    // Get all badge definitions
    final definitions = BadgeConfig.getAllBadges();
    
    // Get already earned badges
    final badgeController = BadgeController();
    final earnedBadges = badgeController.getEarned();
    final earnedBadgeIds = earnedBadges.map((b) => b.id).toSet();
    
    // Check each badge
    for (var definition in definitions) {
      // Skip if already earned
      if (earnedBadgeIds.contains(definition.id)) continue;
      
      // Check if criteria met
      final earned = await definition.checkFunction(context);
      
      if (earned) {
        final badge = Badge(
          id: definition.id,
          title: definition.title,
          detail: definition.detail,
          icon: definition.icon,
          backgroundColor: definition.backgroundColor,
          earnedDate: DateTime.now(),
        );
        
        await badgeController.create(badge);
        newBadges.add(badge);
      }
    }
    
    return newBadges;
  }
  
  /// Build badge check context from user data
  static Future<BadgeCheckContext> _buildBadgeContext() async {
    final userController = UserController();
    final user = userController.getCurrentUser();
    
    final focusSessionController = FocusSessionController();
    final sessions = focusSessionController.getAll();
    
    final prayerController = PrayerController();
    
    return BadgeCheckContext(
      totalFocusHours: user.totalFocusHours,
      completedFocusSessions: sessions.where((s) => s.timerState != TimerState.idle).length,
      currentStreak: user.streak,
      consecutivePrayerDays: await _calculateConsecutivePrayerDays(prayerController),
      fajrOnTime: await _calculateFajrOnTime(prayerController),
      totalKindnessActs: user.totalKindActs,
    );
  }
  
  static Future<int> _calculateConsecutivePrayerDays(PrayerController controller) async {
    // Count consecutive days with all 5 prayers checked
    final now = DateTime.now();
    int consecutiveDays = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dayDate = DateTime(date.year, date.month, date.day);
      
      final dayPrayers = controller.findWhere(
        (p) => _isSameDay(p.date, dayDate)
      );
      
      if (dayPrayers.length == 5 && dayPrayers.every((p) => p.isChecked)) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }
  
  static Future<int> _calculateFajrOnTime(PrayerController controller) async {
    // Count Fajr prayers in last 7 days
    final now = DateTime.now();
    int fajrCount = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayDate = DateTime(date.year, date.month, date.day);
      
      final fajr = controller.findFirst(
        (p) => p.name == PrayerName.fajr && _isSameDay(p.date, dayDate)
      );
      
      if (fajr != null && fajr.isChecked) {
        fajrCount++;
      }
    }
    
    return fajrCount;
  }
  
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
