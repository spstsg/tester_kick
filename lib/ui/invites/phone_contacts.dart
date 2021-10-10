import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/contact_model.dart';
import 'package:kick_chat/services/dynamic_links/dynamic_link_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/invites/contact_avatar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms/flutter_sms.dart';

class PhoneContacts extends StatefulWidget {
  const PhoneContacts({Key? key}) : super(key: key);

  @override
  _PhoneContactsState createState() => _PhoneContactsState();
}

class _PhoneContactsState extends State<PhoneContacts> {
  List<AppContact> contacts = [];
  bool permissionDenied = false;

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  getPermissions() async {
    getAllContacts();
    if (await Permission.contacts.request().isGranted) {
      setState(() {
        permissionDenied = false;
      });
    } else {
      setState(() {
        permissionDenied = true;
      });
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<AppContact> _contacts = (await ContactsService.getContacts()).map((contact) {
      Color baseColor = colors[colorIndex];
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
      return new AppContact(info: contact, color: baseColor);
    }).toList();
    if (mounted) {
      setState(() {
        contacts = _contacts;
      });
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
          'Contacts',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: !permissionDenied
            ? Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      AppContact contact = contacts[index];
                      return ListTile(
                        leading: ContactAvatar(contact, 40),
                        title: Text(
                          '${truncateString(contact.info.displayName.toString(), 25)}',
                          style: TextStyle(
                            color: ColorPalette.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          contact.info.phones!.length > 0 ? '${contact.info.phones!.elementAt(0).value}' : '',
                        ),
                        trailing: inviteButton(contact),
                      );
                    },
                  ),
                ],
              )
            : Container(
                child: Center(
                  child: showEmptyState(
                    'Access to contact data denied.',
                    'You can enable contacts access from your settings.',
                  ),
                ),
              ),
      ),
    );
  }

  Widget inviteButton(AppContact contact) {
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
        onPressed: () async {
          try {
            DynamicLinkService _dynamicLinkService = DynamicLinkService();
            var uri = await _dynamicLinkService.createDynamicLink();
            // await sendSMS(message: uri.toString(), recipients: ['${contact.info.phones![0].value}']);
            await sendSMS(message: uri.toString(), recipients: ['+4915222338270']);
          } catch (e) {
            print(e);
            final snackBar = SnackBar(content: Text('Error sending invites. Try again later.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
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
