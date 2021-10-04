import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/notification_model.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/chat_notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/chat/chat_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChatNotification extends StatefulWidget {
  @override
  _ChatNotificationState createState() => _ChatNotificationState();
}

class _ChatNotificationState extends State<ChatNotification> {
  late Future<List<NotificationModel>> _notificationsFuture;
  ChatNotificationService _chatNotificationService = ChatNotificationService();
  ChatService _chatService = ChatService();
  UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _chatNotificationService.getChatUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat notifications'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _chatNotificationService.updateAllChatNotifications();
                    setState(() {
                      _notificationsFuture = _chatNotificationService.getChatUserNotifications();
                    });
                  },
                  child: Icon(MdiIcons.emailOutline),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {
                    await _chatNotificationService.deleteAllChatUserNotifications();
                    setState(() {
                      _notificationsFuture = _chatNotificationService.getChatUserNotifications();
                    });
                  },
                  child: Icon(MdiIcons.trashCanOutline),
                ),
              ],
            ),
          )
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120.0),
                    child: showEmptyState('No notifications found', 'All your notifications will appear here.'),
                  ),
                ),
              ),
            );
          } else {
            snapshot.data!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.separated(
              itemBuilder: (context, index) {
                Map notificationMetaData = snapshot.data![index].metadata['outBound'];
                return Container(
                  color: !snapshot.data![index].seen ? Colors.lightBlueAccent.shade100.withOpacity(0.2) : null,
                  child: ListTile(
                    onTap: () async {
                      snapshot.data![index].seen = true;
                      _chatNotificationService.updateChatNotification(snapshot.data![index]);
                      List<dynamic> result = await Future.wait([
                        _chatService.getSingleConversation(
                          MyAppState.currentUser!.userID,
                          snapshot.data![index].fromUserID,
                        ),
                        _userService.getCurrentUser(snapshot.data![index].fromUserID),
                      ]);
                      if (result[0] != null && result[1] != null) {
                        push(
                          context,
                          ChatScreen(
                            homeConversationModel: HomeConversationModel(
                              members: [result[1]],
                              conversationModel: result[0],
                            ),
                            user: result[1]!,
                          ),
                        );
                      }
                    },
                    leading: displayCircleImage(notificationMetaData['profilePictureURL'] ?? '', 40, true),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: snapshot.data![index].title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                          TextSpan(
                            text: '  ${snapshot.data![index].body}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                    subtitle: Text('${dateTimeAgo(snapshot.data![index].createdAt)}'),
                    trailing: GestureDetector(
                      onTap: () async {
                        try {
                          await _chatNotificationService.deleteSingleChatNotification(snapshot.data![index].id);
                          setState(() {
                            _notificationsFuture = _chatNotificationService.getChatUserNotifications();
                          });
                        } catch (e) {
                          await showCupertinoAlert(
                            context,
                            'Error',
                            'Cannot delete notification. Please try again later.',
                            'OK',
                            '',
                            '',
                            false,
                          );
                        }
                      },
                      child: Icon(MdiIcons.trashCanOutline),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: snapshot.data!.length,
            );
          }
        },
      ),
    );
  }
}
