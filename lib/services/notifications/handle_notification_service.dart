import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/chat/chat_screen.dart';
import 'package:kick_chat/ui/posts/post_comments_screen.dart';
import 'package:kick_chat/ui/posts/widgets/notification_post_screen.dart';

class HandleNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  PostService _postService = PostService();
  ChatService _chatService = ChatService();
  UserService _userService = UserService();

  initializeFlutterNotificationPlugin() async {
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );
    var initializationSettings = new InitializationSettings(iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    String? payload = notificationAppLaunchDetails!.payload;
    if (payload != null) {
      print(payload);
      onSelectNotification(payload);
    }
  }

  listenForNotifications(GlobalKey<NavigatorState> navigatorKey) async {
    /// configure the firebase messaging , required for notifications handling
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {}

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {}
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) async {
      Map<dynamic, dynamic> data = remoteMessage!.data;
      RemoteNotification? message = remoteMessage.notification;
      if (message!.title != '' && message.body != '') {
        await flutterLocalNotificationsPlugin.show(
          0,
          message.title,
          message.body,
          const NotificationDetails(
            iOS: IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(data),
        );
      }
    });
  }

  void onSelectNotification(String? payload) async {
    try {
      Map data = jsonDecode(payload!);
      if (data['type'] == 'comment') {
        navigateToComments(data['postId'], data['commentId']);
      }

      if (data['type'] == 'shared') {
        navigateToPost(data['postId']);
      }

      if (data['type'] == 'reaction') {
        navigateToPostReaction(
          data['postId'],
          data['username'],
          data['imageUrl'],
          data['reaction'],
        );
      }

      if (data['type'] == 'chat') {
        navigateToChat(data['senderId'], data['receiverId']);
      }
    } catch (e) {
      print(e);
    }
  }

  navigateToComments(String postId, String commentId) async {
    Post post = await _postService.getSinglePost(postId);
    Navigator.of(MyAppState.navigatorKey.currentContext!).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return PostCommentsScreen(post: post, commentId: commentId);
        },
        fullscreenDialog: true,
      ),
    );
  }

  navigateToPost(String postId) async {
    Post post = await _postService.getSinglePost(postId);
    Navigator.of(MyAppState.navigatorKey.currentContext!).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return NotificationPost(post: post);
        },
        fullscreenDialog: true,
      ),
    );
  }

  navigateToPostReaction(String postId, String username, String imageUrl, String reaction) async {
    Post post = await _postService.getSinglePost(postId);
    Navigator.of(MyAppState.navigatorKey.currentContext!).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return NotificationPost(
            post: post,
            imageUrl: imageUrl,
            username: username,
            reaction: reaction,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  navigateToChat(String senderId, String receiverId) async {
    ConversationModel? conversationModel = await _chatService.getSingleConversation(
      senderId,
      receiverId,
    );
    User? sender = await _userService.getCurrentUser(senderId);
    User? receiver = await _userService.getCurrentUser(receiverId);
    _chatService.updateUserOneUserTwoChat(
      receiver!.username,
      sender!.username,
    );
    push(
      MyAppState.navigatorKey.currentContext!,
      ChatScreen(
        homeConversationModel: HomeConversationModel(
          members: [receiver],
          conversationModel: conversationModel,
        ),
        user: receiver,
      ),
    );
  }

  /// this fuction is called when the user receives a notification while the
  /// app is in the background or completely killed
  Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {
    await Firebase.initializeApp();
    // Map<dynamic, dynamic> message = remoteMessage.data;
    // if (message.containsKey('data')) {
    //   // Handle data message
    //   // final dynamic data = message['data'];

    // }

    // if (message.containsKey('notification')) {
    //   // Handle notification message
    //   // final dynamic notification = message['notification'];
    // }
    Map<dynamic, dynamic> data = remoteMessage.data;
    RemoteNotification? message = remoteMessage.notification;
    await flutterLocalNotificationsPlugin.show(
      0,
      message!.title,
      message.body,
      const NotificationDetails(
        iOS: IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
    // if (message!.title != '' && message.body != '') {
    // }
  }
}
