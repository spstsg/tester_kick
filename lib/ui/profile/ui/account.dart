import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/ui/profile/ui/change_password.dart';
import 'package:kick_chat/ui/profile/ui/update_username.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List general = [
      {
        'name': 'Username',
        'icon': Icons.person,
        'showTrailing': true,
        'showColor': false,
        'click': () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return UpdateUsername();
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
        'showColor': false,
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
        'name': 'Delete account',
        'icon': Icons.delete,
        'showTrailing': false,
        'showColor': true,
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
          for (var item in content)
            Container(
              child: ListTile(
                contentPadding: EdgeInsets.only(top: 10, left: 20),
                onTap: item['click'],
                leading: Icon(item['icon'], color: item['showColor'] ? Colors.red : ColorPalette.primary),
                title: Row(
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        color: item['showColor'] ? Colors.red : ColorPalette.black,
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
}
