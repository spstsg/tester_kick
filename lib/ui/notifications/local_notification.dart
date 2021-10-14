import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/models/notification_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/handle_notification_service.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LocalNotification extends StatefulWidget {
  @override
  _LocalNotificationState createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> {
  NotificationService _notificationService = NotificationService();
  HandleNotificationService _handleNotificationService = HandleNotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.getUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _notificationService.updateAllNotifications();
                    setState(() {
                      _notificationsFuture = _notificationService.getUserNotifications();
                    });
                  },
                  child: Icon(MdiIcons.emailOutline),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {
                    await _notificationService.deleteAllUserNotifications();
                    setState(() {
                      _notificationsFuture = _notificationService.getUserNotifications();
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
                String notificationBody = '';
                Map notificationMetaData = {};
                try {
                  switch (snapshot.data![index].type) {
                    case 'posts_comments':
                      notificationBody = 'commented on your post.';
                      notificationMetaData = snapshot.data![index].metadata['outBound'];
                      break;
                    case 'follow_user':
                      notificationBody = 'started followed you.';
                      notificationMetaData = snapshot.data![index].metadata['outBound'];
                      break;
                    case 'social_reaction':
                      notificationBody = 'reacted to your post.';
                      notificationMetaData = snapshot.data![index].metadata['outBound'];
                      break;
                    case 'posts_shared':
                      notificationBody = 'shared your post.';
                      notificationMetaData = snapshot.data![index].metadata['outBound'];
                      break;
                    default:
                      break;
                  }
                } catch (e) {}
                return Container(
                  color: !snapshot.data![index].seen ? Colors.lightBlueAccent.shade100.withOpacity(0.2) : null,
                  child: ListTile(
                    onTap: () {
                      snapshot.data![index].seen = true;
                      _notificationService.updateNotification(snapshot.data![index]);
                      clickNotification(snapshot.data![index]);
                      setState(() {});
                    },
                    leading: notificationMetaData.keys.toList().isNotEmpty
                        ? snapshot.data![index].type != 'chat_message'
                            ? displayCircleImage(notificationMetaData['profilePictureURL'] ?? '', 40, true)
                            : Icon(CupertinoIcons.chat_bubble_fill, size: 35, color: Colors.blue)
                        : Icon(CupertinoIcons.bell_solid, size: 35, color: Colors.blue),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: snapshot.data![index].title,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17)),
                          TextSpan(
                            text: '  $notificationBody',
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
                          await _notificationService.deleteSingleNotification(snapshot.data![index].id);
                          setState(() {
                            _notificationsFuture = _notificationService.getUserNotifications();
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

  void clickNotification(NotificationModel payload) async {
    try {
      if (payload.metadata['type'] == 'posts_comments') {
        _handleNotificationService.navigateToComments(
          payload.metadata['postId'],
          payload.metadata['commentId'],
        );
      }

      if (payload.metadata['type'] == 'posts_shared') {
        _handleNotificationService.navigateToPost(payload.metadata['postId']);
      }

      if (payload.metadata['type'] == 'follow_user') {
        _handleNotificationService.navigateToProfilePage(payload.metadata['userId']);
      }

      if (payload.metadata['type'] == 'social_reaction') {
        _handleNotificationService.navigateToPostReaction(
          payload.metadata['postId'],
          payload.metadata['username'],
          payload.metadata['imageUrl'],
          payload.metadata['reaction'],
        );
      }
    } catch (e) {
      await showCupertinoAlert(
        context,
        'Notification error',
        'Error occured. Please try again later.',
        'OK',
        '',
        '',
        false,
      );
    }
  }
}
