import 'notification_service_stub.dart'
    if (dart.library.js_interop) 'notification_service_web.dart'
    as platform;

class NotificationService {
  static bool get isSupported => platform.isSupported;
  static Future<bool> requestPermission() => platform.requestPermission();
  static Future<void> show(String title, String body) =>
      platform.show(title, body);
  static Future<void> playCompletionSound() => platform.playCompletionSound();
}
