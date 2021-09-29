import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/friends/followers_skeleton.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

class FollowingsScreen extends StatefulWidget {
  final User user;

  FollowingsScreen({required this.user});

  @override
  _FollowingsScreenState createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  FollowService _followService = FollowService();
  UserService _userService = UserService();
  late Future<List<User>> _followings;
  List<User> userFollowers = [];

  @override
  void initState() {
    super.initState();
    _followings = _followService.getUserFollowings(widget.user.userID);
    _followService.getUserFollowings(MyAppState.currentUser!.userID).then((value) => {userFollowers = value});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          FutureBuilder<List<User>>(
            future: _followings,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Expanded(child: FollowersSkeleton());
              } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                return Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Center(
                    child: showEmptyState(
                      'Following',
                      'When you follow people, you\'ll see them here',
                    ),
                  ),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                              left: 10,
                              right: 10,
                            ),
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
                                color: ColorPalette.black,
                              ),
                            ),
                            trailing: trailingButtons(snapshot.data!, index),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  Widget trailingButtons(List<User> snapshot, int index) {
    if (widget.user.username == MyAppState.currentUser!.username) {
      return unfollowButton(snapshot, index);
    } else {
      return followButton(snapshot, index);
    }
  }

  Widget unfollowButton(List<User> snapshot, int index) {
    return SizedBox(
      width: 100,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: ColorPalette.primary),
          ),
        ),
        onPressed: () async {
          try {
            await _followService.unFollowUser(
              MyAppState.currentUser!.userID,
              snapshot[index].userID,
            );
            setState(() {
              snapshot.removeWhere((User element) => element.username == snapshot[index].username);
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Cannot unfollow user. Try again later.',
                ),
              ),
            );
          }
        },
        child: Text(
          'Unfollow',
          style: TextStyle(
            color: ColorPalette.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget followButton(List<User> snapshot, int index) {
    bool checkUserFollowing = checkFollowing(snapshot[index].username);
    return SizedBox(
      width: 100,
      child: !checkUserFollowing
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: ColorPalette.primary),
                ),
              ),
              onPressed: () async {
                if (checkUserFollowing) return;
                try {
                  await _followService.followUser(MyAppState.currentUser!, snapshot[index]);
                  setState(() {
                    userFollowers.add(snapshot[index]);
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error following user. Try again later.',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                'Follow',
                style: TextStyle(
                  color: ColorPalette.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            )
          : Text(
              'Following',
              style: TextStyle(
                color: ColorPalette.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
    );
  }

  bool checkFollowing(String username) {
    var followers = userFollowers.firstWhere((element) => element.username == username, orElse: () => User());
    return followers.username.isNotEmpty;
  }
}
