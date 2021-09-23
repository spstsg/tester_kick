import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                children: [
                  Icon(MdiIcons.emailOutline),
                  SizedBox(width: 20),
                  Icon(MdiIcons.trashCanOutline),
                ],
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List>(
        future: null,
        initialData: [],
        builder: (context, snapshot) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: 0,
            itemBuilder: (BuildContext context, int index) {
              String notificationBody = '';
              try {
                switch ('chat_message') {
                  case 'chat_message':
                    notificationBody = 'just sent you a private message.';
                    break;
                  case 'dating_match':
                    notificationBody = 'just matched with you.';
                    break;
                  case 'accept_friend':
                    notificationBody = 'just Accepted your friend request.';
                    break;
                  case 'friend_request':
                    notificationBody = 'just sent you a friend request.';
                    break;
                  case 'posts':
                    notificationBody = 'shared your post.';
                    break;
                  case 'posts_comments':
                    notificationBody = 'commented on your post.';
                    break;
                  case 'social_follow':
                    notificationBody = 'just followed you.';
                    break;
                  case 'social_reaction':
                    notificationBody = 'just reacted to your post.';
                    break;
                  default:
                    notificationBody = 'sent you a new notification';
                    break;
                }
              } catch (e) {}
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      MdiIcons.bellOutline,
                      size: 30,
                      color: ColorPalette.primary,
                    ),
                    title: Container(
                      margin: EdgeInsets.only(bottom: 15, top: 10),
                      padding: EdgeInsets.only(top: 2),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Manny',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.primary,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: '  $notificationBody',
                              style: TextStyle(
                                color: ColorPalette.grey,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    subtitle: Text(
                      '06:00 AM',
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorPalette.grey,
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  Divider()
                ],
              );
            },
          );
          // return ListView.builder(
          //   itemBuilder: (context, index) {
          //     String notificationBody = '';
          //     try {
          //       switch ('chat_message') {
          //         case 'chat_message':
          //           notificationBody = 'just sent you a private message.';
          //           break;
          //         case 'dating_match':
          //           notificationBody = 'just matched with you.';
          //           break;
          //         case 'accept_friend':
          //           notificationBody = 'just Accepted your friend request.';
          //           break;
          //         case 'friend_request':
          //           notificationBody = 'just sent you a friend request.';
          //           break;
          //         case 'posts':
          //           notificationBody = 'shared your post.';
          //           break;
          //         case 'social_comment':
          //           notificationBody = 'commented on your post.';
          //           break;
          //         case 'social_follow':
          //           notificationBody = 'just followed you.';
          //           break;
          //         case 'social_reaction':
          //           notificationBody = 'just reacted to your post.';
          //           break;
          //         default:
          //           notificationBody = 'sent you a new notification';
          //           break;
          //       }
          //     } catch (e) {}
          //     return Container(
          //       // margin: EdgeInsets.only(top: 5, bottom: 5),
          //       child: Column(
          //         children: [
          //           ListTile(
          //             enabled: true,
          //             onTap: () {},
          // leading: Icon(
          //   MdiIcons.bellOutline,
          //   size: 30,
          //   color: ColorPalette.primary,
          // ),
          //             title: Container(
          //               margin: EdgeInsets.symmetric(vertical: 10),
          //               padding: EdgeInsets.only(bottom: 15),
          //               // margin: EdgeInsets.only(top: 5, bottom: 5),
          //               child: RichText(
          //                 text: TextSpan(
          //                   children: [
          //                     TextSpan(
          //                       text: 'Manny',
          //                       style: TextStyle(
          //                         fontWeight: FontWeight.bold,
          //                         color: ColorPalette.black,
          //                         fontSize: 18,
          //                         fontFamily: 'SF UI Display Semibold',
          //                       ),
          //                     ),
          //                     TextSpan(
          //                       text: '  $notificationBody',
          //                       style: TextStyle(
          //                         color: ColorPalette.grey,
          //                         fontSize: 17,
          //                         fontFamily: 'SF UI Display Medium',
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //             subtitle: Text(
          //               '06:00 AM',
          //               style: TextStyle(
          //                 fontFamily: 'SF UI Display Medium',
          //                 color: ColorPalette.primary,
          //               ),
          //             ),
          //           ),
          //           Divider()
          //         ],
          //       ),
          //     );
          //   },
          //   itemCount: 5,
          // );
        },
      ),
    );
  }
}
