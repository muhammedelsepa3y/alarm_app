
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:alarm_app/services/push_notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/navigation_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Alarm.init();

  await   NotificationService().initNotification();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Falah',
      navigatorKey: NavigationService.navigatorKey,
     home:MyHomePage()

    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await Alarm.stopAll();
            },
            child: Text('Cancel Alarm'),
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: ()async{
            var picker=await showTimePicker(context: context,
              initialTime: TimeOfDay.now(),
              helpText: "Set Alarm Time",
            );
            if (picker != null) {
              await NotificationService().showNotification(
               Random().nextInt(1000),
              'Alarm',
              'Alarm is ringing',
              soundPath: 'alarm.mp3',
              scheduledDate: DateTime (DateTime.now().year, DateTime.now().month, DateTime.now().day, picker.hour, picker.minute),
            );
            }
          },
          child: Icon(Icons.add),
        )
    );
  }
}

