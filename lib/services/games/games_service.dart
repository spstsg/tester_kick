import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';

class GameService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<dynamic>> getGames() async {
    final response = await http.get(
      Uri.parse('https://pub.gamezop.com/v3/games?id=rJ49y5XJx'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['games'];
    } else {
      throw 'Failed to fetch the games';
    }
  }

  Future<List<dynamic>> getUserGameFavorites() async {
    List<dynamic> listOfGames = [];
    try {
      firestore.collection(FAVORITE_GAMES).doc(MyAppState.currentUser!.userID).collection('games').snapshots().listen(
        (onData) {
          listOfGames.clear();
          onData.docs.forEach((document) {
            listOfGames.add(document.data());
          });
        },
      );
      return listOfGames;
    } on Exception catch (e) {
      throw e;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGameFavoritesStream(String userId) {
    try {
      return firestore.collection(FAVORITE_GAMES).doc(userId).collection('games').snapshots();
    } catch (e) {
      throw e;
    }
  }

  dynamic addUserFavoriteGame(dynamic game) {
    try {
      var ref = firestore.collection(FAVORITE_GAMES).doc(MyAppState.currentUser!.userID).collection('games').doc();
      ref.set(game);
      return game;
    } catch (e) {
      throw e;
    }
  }

  Future removeGameFromFavorites(String gameCode) async {
    try {
      QuerySnapshot<Map<String, dynamic>> result = await firestore
          .collection(FAVORITE_GAMES)
          .doc(MyAppState.currentUser!.userID)
          .collection('games')
          .where('code', isEqualTo: gameCode)
          .get();
      await Future.forEach(result.docs, (DocumentSnapshot video) {
        video.reference.delete();
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }
}
