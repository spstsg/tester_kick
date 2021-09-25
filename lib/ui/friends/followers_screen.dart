import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/blocked/blocked_service.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/friends/followers_skeleton.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

class FollowersScreen extends StatefulWidget {
  final User user;

  FollowersScreen({required this.user});
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  FollowService _followService = FollowService();
  UserService _userService = UserService();
  BlockedUserService _blockedUserService = BlockedUserService();
  late Future<List<User>> _followers;
  late List<User> blockedUsers;

  @override
  void initState() {
    super.initState();
    blockedUsers = [];
    _followers = _followService.getUserFollowers(widget.user.userID);
    _blockedUserService.getBlockedUsers(widget.user.userID).then((value) => {blockedUsers = value});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          FutureBuilder<List>(
            future: _followers,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Expanded(child: FollowersSkeleton());
              } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                return Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Center(
                    child: showEmptyState(
                      'Followers',
                      'When people follow you, you\'ll see them here',
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                          onTap: () async {
                            User? user = await _userService.getCurrentUser(
                              snapshot.data![index].userID,
                            );
                            push(context, ProfileScreen(user: user as User));
                          },
                          leading: ProfileAvatar(
                            imageUrl: snapshot.data![index].profilePictureURL,
                            username: snapshot.data![index].username,
                            avatarColor: snapshot.data![index].avatarColor,
                            radius: 25,
                            fontSize: 20,
                          ),
                          title: Text(
                            snapshot.data![index].username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              // color: ColorPalette.black,
                            ),
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }
}
