import 'dart:js_interop';

import 'package:web/web.dart' as web;

bool get isSupported => true;

Future<bool> requestPermission() async {
  try {
    final permission = await web.Notification.requestPermission().toDart;
    return permission.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

Future<void> show(String title, String body) async {
  try {
    if (web.Notification.permission == 'granted') {
      web.Notification(title, web.NotificationOptions(body: body));
    }
  } catch (_) {}
}

Future<void> playCompletionSound() async {
  try {
    final audio = web.AudioContext();
    final tone = audio.createOscillator();
    final volume = audio.createGain();
    tone.frequency.value = 660;
    volume.gain.value = 0.08;
    tone.connect(volume);
    volume.connect(audio.destination);
    tone.start();
    tone.stop(audio.currentTime + 0.18);
  } catch (_) {}
}
