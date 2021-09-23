import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/ui/audio/ui/audio_home_screen.dart';
import 'package:kick_chat/ui/chat/conversation_screen.dart';
import 'package:kick_chat/ui/fans/fans_screen.dart';
import 'package:kick_chat/ui/home/home_screen.dart';
import 'package:kick_chat/ui/livescores/ui/screens/live_scores_tab.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/custom_tab_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NavScreen extends StatefulWidget {
  final int tabIndex;

  const NavScreen({this.tabIndex = 0});

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final List<Widget> _screens = [
    HomeScreen(),
    AudioHomeScreen(),
    LiveScoresTabScreen(),
    FanScreen(),
    ConversationsScreen(user: MyAppState.currentUser!),
    ProfileScreen(user: MyAppState.currentUser!),
    Scaffold(),
    Scaffold(),
  ];
  final List _tabIcons = const [
    {'name': 'Feeds', 'icon': Icons.home},
    {'name': 'Audio', 'icon': MdiIcons.castAudio},
    {'name': 'Scores', 'icon': MdiIcons.soccerField},
    {'name': 'Fans', 'icon': Icons.people},
    {'name': 'Chat', 'icon': Icons.chat_bubble_outline},
    {'name': 'Profile', 'icon': Icons.person},
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _selectedIndex = widget.tabIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabIcons.length,
      initialIndex: widget.tabIndex,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          color: Colors.white,
          child: CustomTabBar(
              icons: _tabIcons,
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              }),
        ),
      ),
    );
  }
}
