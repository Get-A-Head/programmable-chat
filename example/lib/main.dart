import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:twilio_programmable_chat_example/debug.dart';
import 'package:twilio_programmable_chat_example/join/join_page.dart';
import 'package:twilio_programmable_chat_example/shared/services/backend_service.dart';

void main() {
  Debug.enabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  _configureNotifications();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(TwilioProgrammableChatExample());
}

//#region Android Notification Handling
// iOS SDK uses APNs and handles notifications internally

void _configureNotifications() {
  if (Platform.isAndroid) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Main::FirebaseMessaging.onMessage => ${message.data}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Main::FirebaseMessaging.onMessageOpenedApp => ${message.data}');
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print('Main::FirebaseMessaging.onBackgroundMessage => ${message.data}');
      var notification = message.notification;
      if (notification != null) {
        await FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              '0',
              'Chat',
              'Twilio Chat Channel 0',
              importance: Importance.high,
              priority: Priority.defaultPriority,
              showWhen: true,
            ),
          ),
          payload: jsonEncode(message),
        );
      }
    });
  }
}
//#endregion

class TwilioProgrammableChatExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<BackendService>(
      create: (_) => twilioFirebaseFunctions.instance,
      child: MaterialApp(
        title: 'Twilio Programmable Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.blue,
            textTheme: TextTheme(
              headline6: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        home: JoinPage(),
      ),
    );
  }
}
