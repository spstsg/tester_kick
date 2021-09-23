import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

String url = 'https://api-football-v1.p.rapidapi.com/v3';

class LiveScores {
  final soccerApiKey = dotenv.get('SOCCER_API_KEY');
  late StreamController<dynamic> matchDetailsController;
  late StreamController<dynamic> liveMatchesController;
  late StreamController<dynamic> todaysMatchesController;

  Stream<dynamic> getTodaysMatches() async* {
    todaysMatchesController = StreamController();
    final DateFormat format = DateFormat('yyyy-MM-dd');
    var todaysDate = format.format(DateTime.now());
    var soccerApiEndpoint = Uri.parse('$url/fixtures?date=$todaysDate');
    var response = await http.get(soccerApiEndpoint, headers: {
      'x-rapidapi-host': 'api-football-v1.p.rapidapi.com',
      'x-rapidapi-key': soccerApiKey,
    });
    if (response.statusCode == 200) {
      todaysMatchesController.sink.add(jsonDecode(response.body));
    } else {
      todaysMatchesController.sink.add(null);
    }
    yield* todaysMatchesController.stream;
  }

  Stream<dynamic> getLiveMatches() async* {
    liveMatchesController = StreamController();
    var soccerApiEndpoint = Uri.parse('$url/fixtures?live=all');
    var response = await http.get(soccerApiEndpoint, headers: {
      'x-rapidapi-host': 'api-football-v1.p.rapidapi.com',
      'x-rapidapi-key': soccerApiKey,
    });
    if (response.statusCode == 200) {
      liveMatchesController.sink.add(jsonDecode(response.body));
    } else {
      liveMatchesController.sink.add(null);
    }
    yield* liveMatchesController.stream;
  }

  Stream<dynamic> getMatchDetails(String fixtureId) async* {
    matchDetailsController = StreamController();
    var soccerApiEndpoint = Uri.parse('$url/fixtures?id=$fixtureId');
    var response = await http.get(soccerApiEndpoint, headers: {
      'x-rapidapi-host': 'api-football-v1.p.rapidapi.com',
      'x-rapidapi-key': soccerApiKey,
    });
    if (response.statusCode == 200) {
      matchDetailsController.sink.add(jsonDecode(response.body));
    } else {
      matchDetailsController.sink.add(null);
    }
    yield* matchDetailsController.stream;
  }

  void disposeMatchDetailsStream() {
    matchDetailsController.close();
  }

  void disposeLiveMatchesStream() {
    liveMatchesController.close();
  }

  void disposeTodaysMatchesStream() {
    todaysMatchesController.close();
  }
}
