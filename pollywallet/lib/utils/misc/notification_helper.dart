import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pollywallet/constants.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationHelper {
  static void timedNotification(int id, String title, String subtitle, int min,
      BuildContext context) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final bool result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: false,
          sound: false,
        );
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) =>
              _onDidReceiveLocalNotification(id, title, body, payload, context),
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    tz.initializeTimeZones();
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) =>
            _selectNotification(payload, context));
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('1', title, subtitle);
    IOSNotificationDetails iOSPlatformSpecifics =
        IOSNotificationDetails(subtitle: subtitle);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        subtitle,
        tz.TZDateTime.now(tz.local).add(Duration(minutes: min)),
        NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformSpecifics),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  static void cancelNotification(int id) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {}
  }

  static Future _selectNotification(
      String payload, BuildContext context) async {
    if (payload != null) {
      print('notification payload: $payload');
    }
    await Navigator.pushNamed(context, notificationsScreenRoute);
  }

  static Future _onDidReceiveLocalNotification(int id, String title,
      String body, String payload, BuildContext context) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.pushNamed(
                context,
                notificationsScreenRoute,
              );
            },
          )
        ],
      ),
    );
  }
}

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}
