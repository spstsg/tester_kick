import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/games/games_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

class Games extends StatefulWidget {
  const Games({Key? key}) : super(key: key);

  @override
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> {
  GameService _gameService = GameService();
  late Future<List<dynamic>> _gamesFuture;
  List<dynamic> favoriteGames = [];

  @override
  void initState() {
    _gamesFuture = _gameService.getGames();
    getUserGameFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Games',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        actions: [],
      ),
      body: Container(
        child: FutureBuilder<List<dynamic>>(
          future: _gamesFuture,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return PostSkeleton();
            } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: showEmptyState(
                    'No games available.',
                    'Please check back later.',
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4),
                physics: ScrollPhysics(),
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildGameDisplayWidget(snapshot.data![index]);
                },
              );
            }
          },
        ),
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
      // height: game['height'].toDouble(),
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
              Text(
                '${NumberFormat.compact().format(game['gamePlays'])} plays',
                style: TextStyle(
                  color: ColorPalette.grey,
                  fontSize: 16.0,
                ),
              ),
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
              if (checkIfGameExistInFavorites(game['code'])) return;
              _gameService.addUserFavoriteGame(game);
              getUserGameFavorites();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                checkIfGameExistInFavorites(game['code']) ? Icons.check_circle_outline : Icons.add_circle_outline,
                color: checkIfGameExistInFavorites(game['code']) ? Colors.grey : Colors.blue,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getUserGameFavorites() async {
    List games = await _gameService.getUserGameFavorites();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        favoriteGames = games;
      });
    });
  }

  bool checkIfGameExistInFavorites(String gameCode) {
    if (favoriteGames.isEmpty) return false;
    List game = favoriteGames.where((element) => element['code'] == gameCode).toList();
    return game.isNotEmpty;
  }
}
