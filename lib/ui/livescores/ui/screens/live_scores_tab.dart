import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/ui/livescores/ui/screens/all_games.dart';
import 'package:kick_chat/ui/livescores/ui/screens/live_games.dart';

class LiveScoresTabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Livescores',
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
              Tab(text: 'All Games'),
              Tab(text: 'Live'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllGamesScreen(),
            LiveGamesScreen(),
          ],
        ),
      ),
    );
  }
}
