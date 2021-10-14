import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_upcoming_room_model.dart';
import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/audio/audio_upcoming_service.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/audio/widgets/notification_upcoming_audio_card.dart';
import 'package:kick_chat/ui/chat/chat_screen.dart';
import 'package:kick_chat/ui/posts/post_comments_screen.dart';
import 'package:kick_chat/ui/posts/widgets/notification_post_screen.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';

class HandleNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  PostService _postService = PostService();
  ChatService _chatService = ChatService();
  UserService _userService = UserService();
  UpcomingAudioService _upcomingAudioService = UpcomingAudioService();

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
      onSelectNotification(payload);
    }
  }

  listenForNotifications(GlobalKey<NavigatorState> navigatorKey) async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Map<dynamic, dynamic> data = initialMessage.data;
      onSelectNotification(jsonEncode(data));
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        Map<dynamic, dynamic> data = remoteMessage.data;
        onSelectNotification(jsonEncode(data));
      }
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

      if (data['type'] == 'follow') {
        navigateToProfilePage(data['userId']);
      }

      if (data['type'] == 'chat') {
        navigateToChat(data['senderId'], data['receiverId']);
      }

      if (data['type'] == 'upcomingRoom') {
        navigateToUpcomingRoom(data['roomId']);
      }
    } catch (e) {
      await showCupertinoAlert(
        MyAppState.navigatorKey.currentContext!,
        'Notification error',
        'Error occured. Please try again later.',
        'OK',
        '',
        '',
        false,
      );
    }
  }

  Future<void> navigateToComments(String postId, String commentId) async {
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

  Future<void> navigateToPost(String postId) async {
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

  Future<void> navigateToPostReaction(String postId, String username, String imageUrl, String reaction) async {
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

  Future<void> navigateToProfilePage(String userId) async {
    User? authUser = await _userService.getCurrentUser(userId);
    Navigator.of(MyAppState.navigatorKey.currentContext!).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return ProfileScreen(user: authUser!);
        },
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> navigateToChat(String senderId, String receiverId) async {
    User? sender = await _userService.getCurrentUser(senderId);
    User? receiver = await _userService.getCurrentUser(receiverId);
    _chatService.updateUserOneUserTwoChat(
      receiver!.username,
      sender!.username,
    );
    ConversationModel? conversationModel = await _chatService.getSingleConversation(
      senderId,
      receiverId,
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

  Future<void> navigateToUpcomingRoom(String roomId) async {
    UpcomingRoom upcomingRoom = await _upcomingAudioService.getSingleUpcomingRoom(roomId);
    Navigator.of(MyAppState.navigatorKey.currentContext!).push(
      new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return NotificationUpcomingRoom(upcomingRoom: upcomingRoom);
        },
        fullscreenDialog: true,
      ),
    );
  }

  /// this fuction is called when the user receives a notification while the
  /// app is in the background or completely killed
  Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {
    await Firebase.initializeApp();
    Map<dynamic, dynamic> data = remoteMessage.data;
    onSelectNotification(jsonEncode(data));
  }
}
