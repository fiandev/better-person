import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _latKey = 'user_latitude';
  static const String _lonKey = 'user_longitude';
  
  /// Get stored location or return default (Mecca)
  static Future<LocationCoordinates> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);
    
    if (lat != null && lon != null) {
      return LocationCoordinates(latitude: lat, longitude: lon);
    }
    
    // Default to Mecca
    return LocationCoordinates(latitude: 21.4225, longitude: 39.8262);
  }
  
  /// Save user location
  static Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, latitude);
    await prefs.setDouble(_lonKey, longitude);
  }
  
  /// Check if location is set
  static Future<bool> hasLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_latKey) && prefs.containsKey(_lonKey);
  }
}

class LocationCoordinates {
  final double latitude;
  final double longitude;
  
  LocationCoordinates({required this.latitude, required this.longitude});
}
