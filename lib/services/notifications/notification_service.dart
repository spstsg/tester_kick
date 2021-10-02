import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/notification_model.dart';
import 'package:kick_chat/models/user_model.dart';

class NotificationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamController<int> userNotificationCount; // = StreamController();
  late StreamSubscription<QuerySnapshot> _userNotificationCountStreamSubscription;

  String serverKey = dotenv.get('CLOUD_MESSAGING_SERVER_TOKEN');

  Stream<int> getUserNotificationsCount() async* {
    userNotificationCount = StreamController();
    Stream<QuerySnapshot> result = await firestore
        .collection(NOTIFICATIONS)
        .where('toUserID', isEqualTo: MyAppState.currentUser!.userID)
        .where('seen', isEqualTo: false)
        .snapshots();

    _userNotificationCountStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      if (!userNotificationCount.isClosed) {
        userNotificationCount.sink.add(querySnapshot.size);
      }
    });
    yield* userNotificationCount.stream;
  }

  Future<List<NotificationModel>> getUserNotifications() async {
    List<NotificationModel> _userNotifications = [];
    QuerySnapshot result =
        await firestore.collection(NOTIFICATIONS).where('toUserID', isEqualTo: MyAppState.currentUser!.userID).get();

    Future.forEach(result.docs, (DocumentSnapshot document) {
      try {
        _userNotifications.add(NotificationModel.fromJson(document.data() as Map<String, dynamic>));
      } catch (e) {
        throw e;
      }
    });
    return _userNotifications;
  }

  Future sendNotification(String token, String title, String body, Map<String, dynamic>? payload) async {
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

  Future saveNotification(
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

  Future updateNotification(NotificationModel notification) async {
    notification.seen = true;
    await firestore.collection(NOTIFICATIONS).doc(notification.id).update(notification.toJson());
  }

  Future updateAllNotifications() async {
    try {
      QuerySnapshot result =
          await firestore.collection(NOTIFICATIONS).where('toUserID', isEqualTo: MyAppState.currentUser!.userID).get();
      await Future.forEach(result.docs, (DocumentSnapshot notification) {
        notification.reference.update({'seen': true});
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future deleteSingleNotification(String id) async {
    try {
      QuerySnapshot result = await firestore.collection(NOTIFICATIONS).where('id', isEqualTo: id).get();
      await Future.forEach(result.docs, (DocumentSnapshot notification) {
        notification.reference.delete();
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future deleteAllUserNotifications() async {
    try {
      QuerySnapshot result =
          await firestore.collection(NOTIFICATIONS).where('toUserID', isEqualTo: MyAppState.currentUser!.userID).get();
      await Future.forEach(result.docs, (DocumentSnapshot notification) {
        notification.reference.delete();
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  void disposeUserNotificationCountStream() {
    userNotificationCount.close();
    _userNotificationCountStreamSubscription.cancel();
  }
}
