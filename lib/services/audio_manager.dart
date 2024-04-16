import 'package:flutter/services.dart';

class AudioManager {
  static const platform = MethodChannel('com.example.alarm_app/audio');

  static Future<void> requestFocus() async {
    try {
      final bool result = await platform.invokeMethod('requestAudioFocus');
      if (result) {
        print("Audio focus granted");
      } else {
        print("Audio focus denied");
      }
    } on PlatformException catch (e) {
      print("Failed to get audio focus: '${e.message}'.");
    }
  }
}
