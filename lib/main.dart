
import 'dart:async';
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm_app/services/push_notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:workmanager/workmanager.dart';

import 'package:http/http.dart' as http;

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
        await NotificationService().showNotification(
          Random().nextInt(10000),
          'Alarm',
          'Alarm is ringing',
          soundPath: 'alarm.mp3',
          scheduledDate: DateTime (DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second+5),
        );
        const Duration duration = Duration(minutes: 5);
        Timer? timer;
        StreamController<int>? streamController = StreamController<int>();
        streamController.stream.listen((data) async{
          await  _startListeningToSensors(streamController);
        });
        await Future.delayed(const Duration(seconds: 2));
        var httpVar=await http.get(Uri.parse('https://661f753316358961cd945dac.mockapi.io/alarm'));
        print(httpVar.body);
        FlutterVolumeController.addListener(
              (volume) async {
                print ('Volume is $volume');
                if (volume!=inputData?['volume']) {
                  await Alarm.stopAll();
                  streamController.close();
                  timer?.cancel();
                  completer.complete();
                  FlutterVolumeController.removeListener();
                }
              },
        );
        timer = Timer(duration, () async{
          streamController.close();
          timer?.cancel();
          await Alarm.stopAll();
          completer.complete();
          FlutterVolumeController.removeListener();

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
            FlutterVolumeController.removeListener();

            if (!completer.isCompleted) {
              completer.complete();

            }

          }

          // After 4 minutes, close the stream and clean up
          if (t.tick >= duration.inSeconds) {
            _stopListeningToSensors();
            streamController.close();
            await Alarm.stopAll();
            FlutterVolumeController.removeListener();

            t.cancel();
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });
        break;
      case "getData":
        try {
          // Make an HTTP GET request to your API
          var response = await http.get(Uri.parse('https://661f753316358961cd945dac.mockapi.io/alarm'));

          if (response.statusCode == 200) {
            // Handle successful response
            print('API call successful');
            print(response.body);
          } else {
            // Handle error response
            print('API call failed with status code: ${response.statusCode}');
          }
        } catch (e) {
          // Handle network or other errors
          print('Error occurred: $e');
        }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Alarm.stopAll();
                },
                child: const Text('Cancel Alarm'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var httpVar=await http.get(Uri.parse('https://661f753316358961cd945dac.mockapi.io/alarm'));
                  print(httpVar.body);
                },
                child: const Text('Get Data'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Workmanager().registerOneOffTask(Random().nextInt(10000).toString()
                      , "getData", initialDelay: const Duration(seconds: 20));
                },
                child: const Text('Get Data by workmanager as a task'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var alarmSettings = AlarmSettings(
                    id: 42,
                    dateTime: DateTime.now().add(const Duration(seconds: 5)),
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
                  await Alarm.set(alarmSettings: alarmSettings);



                },
                child: const Text('start azan'),
              ),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: ()async{
            var picker=await showTimePicker(context: context,
              initialTime: TimeOfDay.now(),
              helpText: "Set Alarm Time",
            );
            if (picker != null) {
              // var httpVar=await http.post(Uri.parse('https://661f753316358961cd945dac.mockapi.io/alarm'),body: {
              //   'time': '${picker.hour}:${picker.minute}',
              // });
              // print(httpVar.body);

              await Workmanager().cancelByUniqueName(updateTimeTask);
              DateTime now = DateTime.now();
              DateTime scheduledDate = DateTime(now.year, now.month, now.day, picker.hour, picker.minute);
              Duration duration = scheduledDate.difference(now);
              await Workmanager().registerOneOffTask(Random().nextInt(10000).toString()
                  , updateTimeTask, initialDelay: duration,
                inputData: <String, dynamic>{
                "volume": 0.8,
                },
              );

            }
            },
          child: const Icon(Icons.add),
        )
    );
  }
}

