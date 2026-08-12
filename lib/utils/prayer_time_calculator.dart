import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class PrayerTimeCalculator {
  /// Calculate prayer times for a given date and location
  static Map<PrayerName, TimeOfDay> calculatePrayerTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
    CalculationMethod? method,
  }) {
    try {
      // Default to Muslim World League method
      final params = method?.getParameters() ?? 
                     CalculationMethod.muslim_world_league.getParameters();
      
      // Create coordinates
      final coordinates = Coordinates(latitude, longitude);
      
      // Calculate prayer times
      final prayerTimes = PrayerTimes.today(coordinates, params);
      
      return {
        PrayerName.fajr: _dateTimeToTimeOfDay(prayerTimes.fajr),
        PrayerName.dhuhr: _dateTimeToTimeOfDay(prayerTimes.dhuhr),
        PrayerName.asr: _dateTimeToTimeOfDay(prayerTimes.asr),
        PrayerName.maghrib: _dateTimeToTimeOfDay(prayerTimes.maghrib),
        PrayerName.isha: _dateTimeToTimeOfDay(prayerTimes.isha),
      };
    } catch (e) {
      print('Error calculating prayer times: $e');
      // Return default times as fallback
      return _getDefaultPrayerTimes();
    }
  }
  
  /// Get default prayer times (fallback)
  static Map<PrayerName, TimeOfDay> _getDefaultPrayerTimes() {
    return {
      PrayerName.fajr: const TimeOfDay(hour: 5, minute: 30),
      PrayerName.dhuhr: const TimeOfDay(hour: 12, minute: 30),
      PrayerName.asr: const TimeOfDay(hour: 15, minute: 45),
      PrayerName.maghrib: const TimeOfDay(hour: 18, minute: 15),
      PrayerName.isha: const TimeOfDay(hour: 19, minute: 45),
    };
  }
  
  /// Convert DateTime to TimeOfDay
  static TimeOfDay _dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
  
  /// Get next prayer from current time
  static PrayerName? getNextPrayer(Map<PrayerName, TimeOfDay> prayerTimes) {
    final currentTime = TimeOfDay.now();
    
    // Convert TimeOfDay to minutes for comparison
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    for (var entry in prayerTimes.entries) {
      final prayerMinutes = entry.value.hour * 60 + entry.value.minute;
      if (prayerMinutes > currentMinutes) {
        return entry.key;
      }
    }
    
    // If no prayer left today, next is Fajr tomorrow
    return PrayerName.fajr;
  }
  
  /// Calculate time until next prayer
  static Duration timeUntilPrayer(TimeOfDay prayerTime) {
    final now = DateTime.now();
    var prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      prayerTime.hour,
      prayerTime.minute,
    );
    
    // If prayer time has passed today, it's tomorrow
    if (prayerDateTime.isBefore(now)) {
      prayerDateTime = prayerDateTime.add(const Duration(days: 1));
    }
    
    return prayerDateTime.difference(now);
  }
  
  /// Format duration as "Xh Ym" or "Ym"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
