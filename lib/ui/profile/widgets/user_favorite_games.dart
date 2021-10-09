import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/games/games_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

class UserFavoriteGames extends StatefulWidget {
  final User user;
  const UserFavoriteGames({Key? key, required this.user}) : super(key: key);

  @override
  _UserFavoriteGamesState createState() => _UserFavoriteGamesState();
}

class _UserFavoriteGamesState extends State<UserFavoriteGames> {
  GameService _gameService = GameService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _gameService.getUserGameFavoritesStream(widget.user.userID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PostSkeleton();
          } else if (!snapshot.hasData || (snapshot.data?.docs.isEmpty ?? true)) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: showEmptyState(
                  'No favorite games available.',
                  '',
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4),
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildGameDisplayWidget(snapshot.data!.docs[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildGameDisplayWidget(dynamic game) {
    return Card(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: ColorPalette.grey, width: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 10, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            gameDisplay(context, game),
            SizedBox(height: 20),
            gameDetails(game),
            SizedBox(height: 20),
            gameGategory(game),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget gameDisplay(BuildContext context, game) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: game['width'].toDouble(),
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Image.network(
            game['assets']['cover'],
          ).image,
        ),
      ),
    );
  }

  Widget gameDetails(dynamic game) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game['name']['en'],
                style: TextStyle(
                  color: ColorPalette.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 3),
            ],
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (await canLaunch(game['url'])) {
                await launch(game['url']);
              } else {
                await showCupertinoAlert(
                  context,
                  'Error',
                  'Could not launch game. Try again later.',
                  'OK',
                  '',
                  '',
                  false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: ColorPalette.primary,
              textStyle: TextStyle(
                color: ColorPalette.primary,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: ColorPalette.primary,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Text(
              'PLAY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget gameGategory(dynamic game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Text(
              game['categories']['en'][0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              _gameService.removeGameFromFavorites(game['code']);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
