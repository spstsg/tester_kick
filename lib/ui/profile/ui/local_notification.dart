import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/models/notification_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LocalNotification extends StatefulWidget {
  @override
  _LocalNotificationState createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> {
  late Future<List<NotificationModel>> _notificationsFuture;
  NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.getUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'),
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
                      notificationBody = 'just followed you.';
                      notificationMetaData = snapshot.data![index].metadata['outBound'];
                      break;
                    case 'social_reaction':
                      notificationBody = 'just reacted to your post.';
                      notificationMetaData = snapshot.data![index].metadata['outBound'];
                      break;
                    default:
                      notificationBody = 'sent you a new notification';
                      break;
                  }
                } catch (e) {}
                return Container(
                  color: !snapshot.data![index].seen ? Colors.lightBlueAccent.shade100.withOpacity(0.2) : null,
                  child: ListTile(
                    enabled: !snapshot.data![index].seen,
                    onTap: snapshot.data![index].seen
                        ? () => null
                        : () {
                            snapshot.data![index].seen = true;
                            _notificationService.updateNotification(snapshot.data![index]);
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
                    subtitle: Text('${setLastSeen(snapshot.data![index].createdAt.seconds)}'),
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
}
