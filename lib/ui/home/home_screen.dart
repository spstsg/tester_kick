import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:kick_chat/ui/home/user_search.dart';
import 'package:kick_chat/ui/toberemoved/add_clubs.dart';
import 'package:kick_chat/ui/widgets/circle_button.dart';
import 'package:kick_chat/ui/posts/widgets/create_post_container.dart';
import 'package:kick_chat/ui/posts/widgets/post_container.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        controller: null,
        slivers: [
          SliverAppBar(
            leading: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () async {
                  MyAppState.currentUser!.active = false;
                  MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
                  await _userService.updateCurrentUser(
                    MyAppState.currentUser!,
                  );
                  await FirebaseAuth.instance.signOut();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(context, LoginScreen(), false, false);
                },
                child: Icon(
                  Icons.menu,
                  size: 25.0,
                  color: ColorPalette.primary,
                ),
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: ColorPalette.white,
            title: Text(
              'KICKCHAT',
              style: TextStyle(
                color: ColorPalette.primary,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.8,
              ),
            ),
            centerTitle: false,
            floating: true,
            actions: [
              CircleButton(
                icon: MdiIcons.bellOutline,
                iconSize: 30.0,
                onPressed: () => print('Search'),
              ),
              CircleButton(
                icon: Icons.search,
                iconSize: 30.0,
                onPressed: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new UserSearch();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              CircleButton(
                icon: MdiIcons.plus,
                iconSize: 30.0,
                onPressed: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new AddClubsScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: CreatePostContainer(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostContainer();
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
