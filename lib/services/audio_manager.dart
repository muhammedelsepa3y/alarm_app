import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static const platform = MethodChannel('com.example.alarm_app/audio');

  static Future<void> requestFocus() async {
    try {
      final bool result = await platform.invokeMethod('requestAudioFocus');
      if (result) {
        debugPrint("Audio focus granted");
      } else {
        debugPrint("Audio focus denied");
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get audio focus: '${e.message}'.");
    }
  }
}
