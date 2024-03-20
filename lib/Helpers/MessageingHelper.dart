import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;


enum NotificationType {
  newOrder,
  orderStateUpdated,
  reminder,
}

class MessageingHelper {
  String? title = 'Default title';
  String? body = 'Default Body';

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isFlutterLocalNotificationsInitialized = false;
  MessageingHelper({this.title, this.body});

  
   static Future<String?> getFCMToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print('FCM Token: $token');
        return token;
      } else {
        print('Unable to get FCM token');
        return null;
      }
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }



  Future sendMessageToDevices(List tokens, NotificationType notificationType, {dynamic payload}) async {
    tokens.forEach((token) {
      sendMessage(token, notificationType, payload: payload);
    });
  }

  Future sendMessageToTopic(String topic, NotificationType notificationType, {dynamic payload}) async {
    sendMessage('/topics/$topic', notificationType, payload: payload);
  }

  Future sendMessage(String to, NotificationType notificationType, {dynamic payload}) async {
    final data = {
      'to': to,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'payload': payload,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'notification-type': notificationType.name, // Convert enum to string
      },
    };
    String url = 'https://fcm.googleapis.com/fcm/send';
    
    final result = await http.post(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: {
        'Content-type': 'application/json',
        'Authorization':
            'key=AAAAUtvee7k:APA91bFD7x6nURyRWFA-63QC28FzXdN3IWPWioeYDPgPzD-dKTyVzLNciaLFcyLKNwirIeYo1QQqSfyZl6u1tiagKLT_FPC45FtSspVpQBZTvzBrPndmaLMwgbMkijn0Ew0zn1WSRP_K'
      },
    );
    return jsonEncode(result.body);

  }



  

  Future<void> initLocalNotification() async {
    final InitializationSettings initializationSettings = const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/launcher_icon_transparent'),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
      print('notificationResponse ${notificationResponse.payload}');
    });
  }


  initNotification() async {
    await _firebaseMessaging.requestPermission();
    await setupFlutterNotifications();
    initLocalNotification();
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        payload: jsonEncode(message.toMap()),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/launcher_icon_transparent',
          ),
        ),
      );
    }
  }
}
