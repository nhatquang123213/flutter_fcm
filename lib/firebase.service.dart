import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_fcm_auth/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String BASIC_CHANNEL = "BASIC";

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  //init
  late FirebaseMessaging firebaseMessaging;

  init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    firebaseMessaging = FirebaseMessaging.instance;

    AwesomeNotifications().initialize(
      "resource://mipmap-hdpi/ic_launcher",
      [
        NotificationChannel(
          channelKey: BASIC_CHANNEL,
          channelName: "AppName",
          channelDescription: "AppName",
          importance: NotificationImportance.Max,
        ),
      ],
    );

    //request permission
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      sound: true,
      provisional: false,
    );
    getDeviceToken();
    //init background message
    FirebaseMessaging.onBackgroundMessage(onReceiveMessage);
  }

  ///call after login
  getDeviceToken() async {
    try {
      await firebaseMessaging.getToken().then((value) {
        print(value);

        ///call API set token to server, maybe include userID/api-token
      });
    } catch (e) {}
  }

  static Future<void> onReceiveMessage(RemoteMessage message) async {
    if (GetPlatform.isAndroid) {
      try {
        if (message.data.isNotEmpty) {
          final content = NotificationContent(
            id: message.hashCode,
            channelKey: BASIC_CHANNEL,
            title: message.data["title"],
            body: message.data["body"],
          );
          AwesomeNotifications().createNotification(content: content);
        }
      } catch (e) {}
    }
  }
}
