import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/notification_model.dart';
import 'package:kick_chat/models/user_model.dart';

class NotificationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// this server key is used to send notifications, use your own server key,
  /// you can find this in your firebase project settings
  String serverKey = dotenv.get('CLOUD_MESSAGING_SERVER_TOKEN');

  /// send back/fore ground notification to the user related to this token
  /// @param token: the firebase token associated to the user
  /// @param title: the notification title
  /// @param body: the notification body
  /// @param payload: this is a map of data required if you want to handle click
  /// events on the notification from system tray when the app is in the
  /// background or killed
  sendNotification(String token, String title, String body, Map<String, dynamic>? payload) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload ?? <String, dynamic>{},
          'to': token
        },
      ),
    );
  }

  /// save notification to the firestore database
  /// @param type: string of the notification type
  /// @param body: string of the notification body
  /// @param toUser: the target user that should recieve this notification
  /// @param title: string of the notification title
  saveNotification(
    String type,
    String body,
    User toUser,
    String title,
    Map<String, dynamic> metaData,
  ) async {
    DocumentReference notificationDocument = firestore.collection(NOTIFICATIONS).doc();
    NotificationModel notificationModel = NotificationModel(
        type: type,
        body: body,
        toUser: toUser,
        title: title,
        metadata: metaData,
        seen: false,
        createdAt: Timestamp.now(),
        id: notificationDocument.id,
        toUserID: toUser.userID);
    await notificationDocument.set(notificationModel.toJson());
  }
}
