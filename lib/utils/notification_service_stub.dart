import 'package:flutter/services.dart';

bool get isSupported => false;

Future<bool> requestPermission() async => false;

Future<void> show(String title, String body) async {}

Future<void> playCompletionSound() => SystemSound.play(SystemSoundType.alert);
