
import 'dart:async';
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:alarm_app/services/push_notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:workmanager/workmanager.dart';

import 'services/navigation_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher,isInDebugMode: true);
  await   NotificationService().initNotification();
  await Alarm.init();
  runApp(const MyApp());
}

StreamSubscription<GyroscopeEvent>? gyroscopeSubscription;
_startListeningToSensors( StreamController<int> streamController) async{
  gyroscopeSubscription ??= gyroscopeEventStream().where((event) => event.y < -2.0)
        .listen((GyroscopeEvent event) async{
      await Alarm.stopAll();
      _stopListeningToSensors();
      streamController.close();
    });
}
void _stopListeningToSensors() {
  gyroscopeSubscription?.cancel();
  gyroscopeSubscription = null;
}
const updateTimeTask="VIBRATE";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Alarm.init();
    final Completer<void> completer = Completer();

    switch (task) {
      case updateTimeTask:
        const Duration duration = Duration(minutes: 4);
        Timer? timer;
        StreamController<int>? streamController = StreamController<int>();
        streamController.stream.listen((data) async{
          await  _startListeningToSensors(streamController);
        });
        timer = Timer(duration, () async{
          streamController.close();
          timer?.cancel();
          await Alarm.stopAll();
          completer.complete();
        });

        int counter = 0;
        Timer.periodic(const Duration(seconds: 1), (Timer t) {
          if (!streamController.isClosed) {
            streamController.add(counter++);
          }
        });

        Timer.periodic(const Duration(seconds: 1), (Timer t) async{

          if (!streamController.isClosed) {
            streamController.add(t.tick);
          }else {
            t.cancel();
            await Alarm.stopAll();
            if (!completer.isCompleted) {
              completer.complete();
            }

          }

          // After 4 minutes, close the stream and clean up
          if (t.tick >= duration.inSeconds) {
            _stopListeningToSensors();
            streamController.close();
            await Alarm.stopAll();
            t.cancel();
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });
        break;
    }
    return completer.future.then((_) {
      return true;
    }).catchError((_) {
      return false;
    });
  });

}

class MyApp extends StatelessWidget {
 const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alarm',
      navigatorKey: NavigationService.navigatorKey,
     home:const MyHomePage()

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
            child: const Text('Cancel Alarm'),
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
               Random().nextInt(10000),
              'Alarm',
              'Alarm is ringing',
              soundPath: 'alarm.mp3',
              scheduledDate: DateTime (DateTime.now().year, DateTime.now().month, DateTime.now().day, picker.hour, picker.minute),
            );
              await Workmanager().cancelByUniqueName(updateTimeTask);
              DateTime now = DateTime.now();
              DateTime scheduledDate = DateTime(now.year, now.month, now.day, picker.hour, picker.minute);
              Duration duration = scheduledDate.difference(now);
              await Workmanager().registerOneOffTask(Random().nextInt(10000).toString()
                  , updateTimeTask, initialDelay: duration);

            }
            },
          child: const Icon(Icons.add),
        )
    );
  }
}

