import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';

import 'package:permission_handler/permission_handler.dart';
class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }


  NotificationService._internal();

  Future<void> initNotification() async {
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
       await Permission.scheduleExactAlarm.request();
    }
  }
  Future<void> showNotification(int id, String title, String body,
      {required String soundPath,required DateTime scheduledDate}) async {

    final alarmSettings = AlarmSettings(
      id: 42,
      dateTime: scheduledDate,
      assetAudioPath: 'assets/fajr3bdelbaset.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'This is the title',
      notificationBody: 'This is the body',
      enableNotificationOnKill: true,
      androidFullScreenIntent: true,
    );
    await Alarm.setNotificationOnAppKillContent(title, body);

    await Alarm.set(alarmSettings: alarmSettings);
  }
}
