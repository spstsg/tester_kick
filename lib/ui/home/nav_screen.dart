import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/ui/audio/ui/audio_home_screen.dart';
import 'package:kick_chat/ui/chat/conversation_screen.dart';
import 'package:kick_chat/ui/fans/fans_screen.dart';
import 'package:kick_chat/ui/home/home_screen.dart';
import 'package:kick_chat/ui/livescores/ui/screens/live_scores_tab.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NavScreen extends StatefulWidget {
  final int tabIndex;
  const NavScreen({this.tabIndex = 0});

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;
  final List _tabElements = [
    {'name': 'Feeds', 'index': 0, 'icon': Icons.home, 'screen': HomeScreen()},
    {'name': 'Audio', 'index': 1, 'icon': MdiIcons.castAudio, 'screen': AudioHomeScreen()},
    {'name': 'Scores', 'index': 2, 'icon': MdiIcons.soccerField, 'screen': LiveScoresTabScreen()},
    {'name': 'Fans', 'index': 3, 'icon': Icons.people, 'screen': FanScreen()},
    {
      'name': 'Chat',
      'index': 4,
      'icon': Icons.chat_bubble_outline,
      'screen': ConversationsScreen(user: MyAppState.currentUser!)
    },
    {'name': 'Profile', 'index': 5, 'icon': Icons.person, 'screen': ProfileScreen(user: MyAppState.currentUser!)},
  ];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = HomeScreen();

  @override
  void initState() {
    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    NotificationService.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _selectedIndex = widget.tabIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 40,
          margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              for (var item in _tabElements)
                MaterialButton(
                  minWidth: 30,
                  onPressed: () {
                    setState(() {
                      currentScreen = item['screen'];
                      _selectedIndex = item['index'];
                    });
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          item['icon'],
                          color: _selectedIndex == item['index'] ? Colors.blue : Colors.grey,
                          size: 20,
                        ),
                        SizedBox(height: 2),
                        Text(
                          item['name'],
                          style: TextStyle(
                            color: _selectedIndex == item['index'] ? Colors.blue : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
