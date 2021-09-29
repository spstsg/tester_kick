import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/blocked/blocked_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

class BlockedUsers extends StatefulWidget {
  BlockedUsers({Key? key}) : super(key: key);

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  BlockedUserService _blockedUserService = BlockedUserService();
  List<User> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _blockedUserService.getBlockedUsers(MyAppState.currentUser!.userID).then((value) => {blockedUsers = value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0.0,
        title: Text('Blocked users'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            if (blockedUsers.isEmpty) ...{
              Container(
                height: MediaQuery.of(context).size.height / 1.5,
                child: Center(
                  child: showEmptyState(
                    'Blocked user',
                    'When people block users, you\'ll see them here',
                  ),
                ),
              )
            },
            if (blockedUsers.isNotEmpty) ...{
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: blockedUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        leading: ProfileAvatar(
                          imageUrl: blockedUsers[index].profilePictureURL,
                          username: blockedUsers[index].username,
                          avatarColor: blockedUsers[index].avatarColor,
                          radius: 25,
                          fontSize: 20,
                        ),
                        title: Text(
                          blockedUsers[index].username,
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.red),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await _blockedUserService.unblockUser(MyAppState.currentUser!, blockedUsers[index]);
                                blockedUsers
                                    .removeWhere((User element) => element.username == blockedUsers[index].username);
                                setState(() {});
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Cannot unblock user. Try again later.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Unblock',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              )
            }
          ],
        ),
      ),
    );
  }
}
