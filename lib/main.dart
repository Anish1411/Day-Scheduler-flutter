// // import 'package:audioplayers/notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'dart:async';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Daily Reminder App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: ReminderScreen(),
//     );
//   }
// }

// class ReminderScreen extends StatefulWidget {
//   @override
//   _ReminderScreenState createState() => _ReminderScreenState();
// }

// class _ReminderScreenState extends State<ReminderScreen>
//     with TickerProviderStateMixin {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   TimeOfDay selectedTime = TimeOfDay.now();
//   String selectedDay = 'Monday';
//   String selectedActivity = 'Wake up';

//   List<Map<String, dynamic>> tasks = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//     );

//     if (picked != null && picked != selectedTime) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }

//   void _setReminder() {
//     // Add the task to the list
//     tasks.add({
//       'day': selectedDay,
//       'time': selectedTime.format(context),
//       'activity': selectedActivity,
//     });

//     setState(() {
//       selectedDay = 'Monday';
//       selectedTime = TimeOfDay.now();
//       selectedActivity = 'Wake up';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Daily Reminder App'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DropdownButton<String>(
//               value: selectedDay,
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   setState(() {
//                     selectedDay = newValue;
//                   });
//                 }
//               },
//               items: <String>[
//                 'Monday',
//                 'Tuesday',
//                 'Wednesday',
//                 'Thursday',
//                 'Friday',
//                 'Saturday',
//                 'Sunday'
//               ].map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _selectTime(context),
//               child: Text('Select Time: ${selectedTime.format(context)}'),
//             ),
//             SizedBox(height: 16),
//             DropdownButton<String>(
//               value: selectedActivity,
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   setState(() {
//                     selectedActivity = newValue;
//                   });
//                 }
//               },
//               items: <String>[
//                 'Wake up',
//                 'Go to gym',
//                 'Breakfast',
//                 'Meetings',
//                 'Lunch',
//                 'Quick nap',
//                 'Go to library',
//                 'Dinner',
//                 'Go to sleep',
//               ].map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _setReminder,
//               child: Text('Set Reminder'),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: tasks.length,
//                 itemBuilder: (context, index) {
//                   return Card(
//                     elevation: 4,
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: Text(
//                         '${tasks[index]['day']} - ${tasks[index]['time']}',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(tasks[index]['activity']),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:audioplayers/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with TickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();

  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedDay = 'Monday';
  String selectedActivity = 'Wake up';

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _setReminder() {
    // Add the task to the list
    tasks.add({
      'day': selectedDay,
      'time': selectedTime.format(context),
      'activity': selectedActivity,
    });

    // Schedule notification for the selected time
    scheduleNotification();

    setState(() {
      selectedDay = 'Monday';
      selectedTime = TimeOfDay.now();
      selectedActivity = 'Wake up';
    });
  }

  Future<void> scheduleNotification() async {
    final now = DateTime.now();
    final scheduledDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      tasks.length, // Unique ID for each notification
      'Reminder',
      'Time for ${selectedActivity} on ${selectedDay} at ${selectedTime.format(context)}',
      scheduledDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          'Channel Description',
          importance: Importance.high,
        ),
      ),
      // androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Play sound
    playSound();
  }

  void playSound() async {
    try {
      await audioCache.play('../Sound/sound.mp3');
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedDay = newValue;
                  });
                }
              },
              items: <String>[
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select Time: ${selectedTime.format(context)}'),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedActivity = newValue;
                  });
                }
              },
              items: <String>[
                'Wake up',
                'Go to gym',
                'Breakfast',
                'Meetings',
                'Lunch',
                'Quick nap',
                'Go to library',
                'Dinner',
                'Go to sleep',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setReminder,
              child: Text('Set Reminder'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${tasks[index]['day']} - ${tasks[index]['time']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(tasks[index]['activity']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
