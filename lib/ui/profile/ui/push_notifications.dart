import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationType {
  final String name;
  final bool value;

  NotificationType(this.name, this.value);
}

class PushNotification extends StatefulWidget {
  const PushNotification({Key? key}) : super(key: key);

  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  UserService _userService = UserService();
  bool toggleValue = false;
  String notificationStatus = 'Off';
  bool isNotificationEnabled = true;
  List<NotificationType> notificationTypeData = [];
  User? user = User();

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    getNotificationStatus();
  }

  getCurrentUserData() async {
    user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
    notificationTypeData =
        MyAppState.currentUser!.notifications.entries.map((entry) => NotificationType(entry.key, entry.value)).toList();
  }

  getNotificationStatus() async {
    NotificationSettings settings = await NotificationService.firebaseMessaging.getNotificationSettings();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) return;
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        setState(() {
          notificationStatus = 'Off';
          isNotificationEnabled = false;
        });
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        setState(() {
          notificationStatus = 'On';
          isNotificationEnabled = true;
        });
      }
      MyAppState.reduxStore!.onChange.listen((event) {
        if (!mounted) return;
        setState(() {
          notificationStatus = event.user.settings.notifications ? 'On' : 'Off';
          isNotificationEnabled = event.user.settings.notifications ? true : false;

          notificationTypeData =
              event.user.notifications.entries.map((entry) => NotificationType(entry.key, entry.value)).toList();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0.0,
        title: Text('Push notifications'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          generalItems(context, notificationTypeData),
        ],
      ),
    );
  }

  Widget generalItems(BuildContext context, List<NotificationType> content) {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          InkWell(
            onTap: () async {
              openAppSettings();
            },
            splashColor: Colors.white,
            highlightColor: Colors.white,
            child: Container(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Push notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorPalette.black,
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Text(notificationStatus),
                        Icon(
                          MdiIcons.chevronRight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          Divider(),
          Opacity(
            opacity: isNotificationEnabled ? 1 : 0.45,
            child: Column(
              children: [
                for (var i = 0; i < content.length; i++) ...[
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 20),
                    title: Row(
                      children: [
                        Text(
                          content[i].name,
                          style: TextStyle(
                            color: ColorPalette.black,
                          ),
                        ),
                      ],
                    ),
                    trailing: CupertinoSwitch(
                      value: content[i].value,
                      onChanged: isNotificationEnabled
                          ? (bool value) async {
                              await _userService.updateNotificationType(content[i].name, value);
                            }
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
