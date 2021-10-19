import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/ui/friends/followers_screen.dart';
import 'package:kick_chat/ui/friends/followings_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FriendsTabScreen extends StatefulWidget {
  final int tabIndex;
  final User user;
  FriendsTabScreen({required this.tabIndex, required this.user});

  @override
  State<FriendsTabScreen> createState() => _FriendsTabScreenState();
}

class _FriendsTabScreenState extends State<FriendsTabScreen> {
  FollowService _followService = FollowService();
  int followersCount = 0;
  int followingsCount = 0;

  @override
  void initState() {
    getFollowersAndFollowingsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.tabIndex,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(MdiIcons.arrowLeft, color: ColorPalette.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.user.username,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: ColorPalette.white,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: [
              Tab(
                text: 'FOLLOWING (${NumberFormat.compact().format(followingsCount)})',
              ),
              Tab(
                text: 'FOLLOWERS (${NumberFormat.compact().format(followersCount)})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FollowingsScreen(user: widget.user),
            FollowersScreen(user: widget.user),
          ],
        ),
      ),
    );
  }

  Future<void> getFollowersAndFollowingsCount() async {
    int countFollowers = await _followService.getUserFollowersCount(widget.user.userID);
    int countFollowing = await _followService.getUserFollowingsCount(widget.user.userID);
    setState(() {
      followersCount = countFollowers;
      followingsCount = countFollowing;
    });
  }
}
