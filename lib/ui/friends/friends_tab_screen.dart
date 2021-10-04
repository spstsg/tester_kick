import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/ui/friends/followers_screen.dart';
import 'package:kick_chat/ui/friends/followings_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FriendsTabScreen extends StatelessWidget {
  final int tabIndex;
  final User user;
  FriendsTabScreen({required this.tabIndex, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: tabIndex,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(MdiIcons.arrowLeft, color: ColorPalette.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            user.username,
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
                text:
                    'FOLLOWING (${NumberFormat.compact().format(user.username != MyAppState.currentUser!.username ? user.followingCount : MyAppState.currentUser!.followingCount)})',
              ),
              Tab(
                text:
                    'FOLLOWERS (${NumberFormat.compact().format(user.username != MyAppState.currentUser!.username ? user.followersCount : MyAppState.currentUser!.followersCount)})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FollowingsScreen(user: user),
            FollowersScreen(user: user),
          ],
        ),
      ),
    );
  }
}
