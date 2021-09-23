import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/rooms_model.dart';
import 'package:kick_chat/ui/chat/league_clubs_screen.dart';

class LeaguesScreen extends StatefulWidget {
  @override
  _LeaguesScreenState createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  Widget _buildLeagues() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ListView.builder(
        physics: ScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: roomsData.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeagueClubsScreen(
                        leagueName: roomsData[index].leagueName,
                        leagueAsset: roomsData[index].leagueImageUrl,
                        country: roomsData[index].country,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                  leading: Container(
                    width: 40.0,
                    height: 40.0,
                    child: CircleAvatar(
                      backgroundColor: ColorPalette.white,
                      child: ClipOval(
                        child: Image(
                          height: 40.0,
                          width: 40.0,
                          image: AssetImage(roomsData[index].leagueImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: Container(
                    child: Text(
                      roomsData[index].leagueName,
                      style: TextStyle(
                        color: ColorPalette.primary,
                        // fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Divider()
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(
          'Leagues',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                child: _buildLeagues(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
