import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:kick_chat/ui/profile/ui/blocked_users.dart';
import 'package:kick_chat/ui/profile/ui/change_password.dart';
import 'package:kick_chat/ui/profile/ui/push_notifications.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String termsOfServiceUrl = 'https://www.kickchatapp.com/terms-of-service';
    String privacyPolicyUrl = 'https://www.kickchatapp.com/privacy-policy';

    List general = [
      {
        'name': 'Blocked users',
        'icon': MdiIcons.accountMultipleOutline,
        'showTrailing': true,
        'click': () {
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return new BlockedUsers();
              },
              fullscreenDialog: true,
            ),
          );
        }
      },
      {
        'name': 'Change password',
        'icon': Icons.settings,
        'showTrailing': true,
        'click': () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const ChangePassword();
              },
              fullscreenDialog: true,
            ),
          );
        }
      },
      {
        'name': 'Notifications',
        'icon': MdiIcons.bell,
        'showTrailing': true,
        'click': () {
          Navigator.of(context).push(
            new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return new PushNotification();
              },
              fullscreenDialog: true,
            ),
          );
        }
      },
    ];

    List others = [
      {
        'name': 'Terms of Service',
        'icon': MdiIcons.chevronRightCircleOutline,
        'showTrailing': false,
        'click': () async {
          if (await canLaunch(termsOfServiceUrl)) {
            await launch(termsOfServiceUrl);
          } else {
            await showCupertinoAlert(
              context,
              'Error',
              'Could not launch terms of service url. Try again later.',
              'OK',
              '',
              '',
              false,
            );
          }
        }
      },
      {
        'name': 'Privacy Policy',
        'icon': MdiIcons.chevronRightCircleOutline,
        'showTrailing': false,
        'click': () async {
          if (await canLaunch(privacyPolicyUrl)) {
            await launch(privacyPolicyUrl);
          } else {
            await showCupertinoAlert(
              context,
              'Error',
              'Could not launch privacy policy url. Try again later.',
              'OK',
              '',
              '',
              false,
            );
          }
        }
      },
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0.0,
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          generalItems(context, 'General', general),
          generalItems(context, 'Others', others),
          SizedBox(height: 30),
          Container(
            margin: EdgeInsets.only(left: 26),
            child: ListTile(
              contentPadding: EdgeInsets.only(top: 10, left: 20),
              onTap: () async {
                await logout(context);
              },
              leading: Icon(MdiIcons.power, color: ColorPalette.primary, size: 30),
              title: Row(
                children: [
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorPalette.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget generalItems(BuildContext context, String header, List content) {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20),
            child: Text(
              header,
              style: TextStyle(
                fontSize: 18,
                color: ColorPalette.black,
              ),
            ),
          ),
          for (var item in content)
            Container(
              margin: EdgeInsets.only(left: 20),
              child: ListTile(
                contentPadding: EdgeInsets.only(top: 10, left: 20),
                onTap: item['click'],
                leading: Icon(item['icon'], color: ColorPalette.primary),
                title: Row(
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 18,
                        color: ColorPalette.black,
                      ),
                    ),
                  ],
                ),
                trailing: Visibility(
                  visible: item['showTrailing'],
                  child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.arrow_forward, color: ColorPalette.primary, size: 25),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  logout(BuildContext context) async {
    UserService _userService = UserService();
    MyAppState.currentUser!.active = false;
    MyAppState.currentUser!.emailPasswordLogin = false;
    MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
    _userService.updateCurrentUser(MyAppState.currentUser!);
    await auth.FirebaseAuth.instance.signOut();

    MyAppState.currentUser = User();
    pushAndRemoveUntil(context, LoginScreen(), false, false);
  }
}
