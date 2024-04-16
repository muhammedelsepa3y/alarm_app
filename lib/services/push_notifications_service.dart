import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:sound_mode/sound_mode.dart';
// import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'audio_manager.dart';
// import 'package:volume_controller/volume_controller.dart';

class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    // late AndroidNotificationChannel channel = const AndroidNotificationChannel(
    //   'alarm',
    //   'alarm Notifications',
    //   showBadge: true,
    //   importance: Importance.max,
    //   playSound:  true,
    //   sound: RawResourceAndroidNotificationSound('fajr3bdelbaset'),
    //   enableVibration: true,
    //
    // );
    //
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);
    // // Android initialization
    // final AndroidInitializationSettings initializationSettingsAndroid =
    // AndroidInitializationSettings('@mipmap/ic_launcher',);
    //
    // // ios initialization
    // final DarwinInitializationSettings initializationSettingsIOS =
    // DarwinInitializationSettings(
    //   requestAlertPermission: false,
    //   requestBadgePermission: false,
    //   requestSoundPermission: false,
    //
    // );
    //
    // final InitializationSettings initializationSettings =
    // InitializationSettings(
    //     android: initializationSettingsAndroid,
    //     iOS: initializationSettingsIOS);
    // final details=await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    //
    //
    // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()!.requestExactAlarmsPermission();
    // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    //
    //
    //
    // if (details?.didNotificationLaunchApp ?? false) {
    //   print('Notification Launched App');
    // }
    //
    //
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
await checkAndroidScheduleExactAlarmPermission();

  }
  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    print('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      print('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      print('Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
    }
  }
  Future<void> showNotification(int id, String title, String body,
      {required String soundPath,required DateTime scheduledDate}) async {
    // try {
    //   await SoundMode.setSoundMode(RingerModeStatus.normal);
    // } on PlatformException {
    //   print('Please enable permissions required');
    // }
    // await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
    // double volume = await VolumeController().getVolume().then((value) {
    //   return value;
    // });
    // if (volume !=1) VolumeController().setVolume(1);
   // tz.initializeTimeZones();
   // final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print ('Notification Scheduled at ${scheduledDate.toString()}');
    // tz.setLocalLocation(tz.getLocation(currentTimeZone));
    // // Get the local timezone
    // final local = tz.getLocation(currentTimeZone);
    // // Calculate the time for the notifications
    // tz.TZDateTime now = tz.TZDateTime.now(local);
    // tz.TZDateTime scheduledTimeEvening = tz.TZDateTime(local, now.year, now.month, now.day,scheduledDate.hour, scheduledDate.minute);
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   id,
    //   title,
    //   body,
    //   scheduledTimeEvening,
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //         'Alarm', 'AlarmNotification',
    //         channelDescription: "alarm_notification_channel",
    //         importance: Importance.max,
    //         sound: RawResourceAndroidNotificationSound("fajr3bdelbaset"),
    //         playSound: true,
    //         priority: Priority.max,
    //       audioAttributesUsage: AudioAttributesUsage.media,
    //       autoCancel: false,
    //       channelShowBadge: true,
    //       fullScreenIntent: true,
    //       ongoing: true,
    //       visibility: NotificationVisibility.public,
    //
    //     ),
    //     // iOS details
    //     iOS: DarwinNotificationDetails(
    //       sound: soundPath,
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //
    //     ),
    //   ),
    //
    //   uiLocalNotificationDateInterpretation:
    //     UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   androidAllowWhileIdle: true,
    //   // Type of time interpretation
    //   // uiLocalNotificationDateInterpretation:
    //   // UILocalNotificationDateInterpretation.absoluteTime,
    // );
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


    print ('Notification Scheduled');
  }
}
