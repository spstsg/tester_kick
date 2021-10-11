import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/invites/phone_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({Key? key}) : super(key: key);

  @override
  _InviteScreenState createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  bool hasContactPermission = true;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  checkPermission() async {
    if (await Permission.contacts.request().isGranted) {
      if (mounted) {
        setState(() {
          hasContactPermission = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          hasContactPermission = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Invite friends',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Visibility(
              visible: true,
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   'Enable contact permission.',
                    //   style: TextStyle(color: Colors.red),
                    // ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.settings, color: Colors.grey),
                      onPressed: () async {
                        openAppSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/contact.png'),
                backgroundColor: Colors.white,
              ),
              title: Text(
                'Contacts',
                style: TextStyle(
                  color: ColorPalette.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Invite from contacts',
              ),
              trailing: inviteButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget inviteButton() {
    return Container(
      width: 100,
      height: 30,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: ColorPalette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: () => push(context, PhoneContacts()),
        child: Text(
          'Invite',
          style: TextStyle(
            color: ColorPalette.white,
          ),
        ),
      ),
    );
  }
}
