import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/ui/audio/ui/audio_home_screen.dart';
import 'package:kick_chat/ui/fans/fans_screen.dart';
import 'package:kick_chat/ui/games/games.dart';
import 'package:kick_chat/ui/home/home_screen.dart';
import 'package:kick_chat/ui/livescores/ui/screens/live_scores_tab.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/custom_tab_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';

class NavScreen extends StatefulWidget {
  final int tabIndex;
  const NavScreen({this.tabIndex = 0});

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  UserService _userService = UserService();
  final List<Widget> _screens = [
    HomeScreen(),
    AudioHomeScreen(),
    LiveScoresTabScreen(),
    FanScreen(),
    Games(),
    ProfileScreen(user: MyAppState.currentUser!),
  ];
  final List _tabIcons = const [
    {'name': 'Feeds', 'icon': Icons.home},
    {'name': 'Audio', 'icon': MdiIcons.castAudio},
    {'name': 'Scores', 'icon': MdiIcons.soccerField},
    {'name': 'Fans', 'icon': Icons.room},
    {'name': 'Games', 'icon': Icons.gamepad_outlined},
    {'name': 'Profile', 'icon': Icons.person},
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    requestNotificationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabIcons.length,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          alignment: AlignmentDirectional.centerStart,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(bottom: 12.0),
          color: Colors.white,
          child: CustomTabBar(
            icons: _tabIcons,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await NotificationService.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied && MyAppState.currentUser!.settings.notifications) {
      await _userService.updatePushNotificationSetting(false);
    }
  }
}
