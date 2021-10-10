import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/invites/phone_contacts.dart';
// import 'package:permission_handler/permission_handler.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({Key? key}) : super(key: key);

  @override
  _InviteScreenState createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
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

  // Future<void> _askPermissions() async {
  //   PermissionStatus permissionStatus = await _getContactPermission();
  //   if (permissionStatus != PermissionStatus.granted) {
  //     _handleInvalidPermissions(permissionStatus);
  //   }
  // }

  // Future<PermissionStatus> _getContactPermission() async {
  //   PermissionStatus permission = await Permission.contacts.status;
  //   if (permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied) {
  //     PermissionStatus permissionStatus = await Permission.contacts.request();
  //     return permissionStatus;
  //   } else {
  //     return permission;
  //   }
  // }

  // void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  //   if (permissionStatus == PermissionStatus.denied) {
  //     final snackBar = SnackBar(content: Text('Access to contact data denied'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
  //     final snackBar = SnackBar(content: Text('Contact data not available on device'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }
}
