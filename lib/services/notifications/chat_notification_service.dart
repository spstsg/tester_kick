import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/notification_model.dart';
import 'package:kick_chat/models/user_model.dart';

class ChatNotificationService {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamController<int> userNotificationCount; // = StreamController();
  late StreamSubscription<QuerySnapshot> _userNotificationCountStreamSubscription;

  Stream<int> getUserChatNotificationsCount() async* {
    userNotificationCount = StreamController();
    Stream<QuerySnapshot> result = await firestore
        .collection(CHAT_NOTIFICATIONS)
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

  Future<List<NotificationModel>> getChatUserNotifications() async {
    List<NotificationModel> _userNotifications = [];
    QuerySnapshot result = await firestore
        .collection(CHAT_NOTIFICATIONS)
        .where('toUserID', isEqualTo: MyAppState.currentUser!.userID)
        .get();

    Future.forEach(result.docs, (DocumentSnapshot document) {
      try {
        _userNotifications.add(NotificationModel.fromJson(document.data() as Map<String, dynamic>));
      } catch (e) {
        throw e;
      }
    });
    return _userNotifications;
  }

  Future saveChatNotification(
    String type,
    String body,
    User toUser,
    String title,
    Map<String, dynamic> metaData,
  ) async {
    DocumentReference notificationDocument = firestore.collection(CHAT_NOTIFICATIONS).doc();
    NotificationModel notificationModel = NotificationModel(
      type: type,
      body: body,
      toUser: toUser,
      title: title,
      metadata: metaData,
      seen: false,
      createdAt: Timestamp.now(),
      id: notificationDocument.id,
      toUserID: toUser.userID,
      fromUserID: MyAppState.currentUser!.userID,
    );
    QuerySnapshot result = await firestore
        .collection(CHAT_NOTIFICATIONS)
        .where('toUserID', isEqualTo: toUser.userID)
        .where('fromUserID', isEqualTo: MyAppState.currentUser!.userID)
        .get();

    if (result.docs.isEmpty) {
      await notificationDocument.set(notificationModel.toJson());
    } else {
      await Future.forEach(result.docs, (DocumentSnapshot notification) {
        notification.reference.update({
          'seen': false,
          'metadata.chat': metaData['chat'],
          'createdAt': Timestamp.now(),
        });
      });
    }
  }

  Future updateChatNotification(NotificationModel notification) async {
    notification.seen = true;
    await firestore.collection(CHAT_NOTIFICATIONS).doc(notification.id).update(notification.toJson());
  }

  Future updateAllChatNotifications() async {
    try {
      QuerySnapshot result = await firestore
          .collection(CHAT_NOTIFICATIONS)
          .where('toUserID', isEqualTo: MyAppState.currentUser!.userID)
          .get();
      await Future.forEach(result.docs, (DocumentSnapshot notification) {
        notification.reference.update({'seen': true});
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future deleteSingleChatNotification(String id) async {
    try {
      QuerySnapshot result = await firestore.collection(CHAT_NOTIFICATIONS).where('id', isEqualTo: id).get();
      await Future.forEach(result.docs, (DocumentSnapshot notification) {
        notification.reference.delete();
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future deleteAllChatUserNotifications() async {
    try {
      QuerySnapshot result = await firestore
          .collection(CHAT_NOTIFICATIONS)
          .where('toUserID', isEqualTo: MyAppState.currentUser!.userID)
          .get();
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
