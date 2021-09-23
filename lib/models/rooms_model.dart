class RoomModel {
  String leagueName;
  String leagueImageUrl;
  String country;

  RoomModel({
    required this.leagueName,
    required this.leagueImageUrl,
    required this.country,
  });
}

final List<RoomModel> roomsData = [
  RoomModel(
    leagueName: 'English Premier League',
    leagueImageUrl: 'assets/images/leagues/epl.png',
    country: 'England',
  ),
  RoomModel(
    leagueName: 'French Ligue 1',
    leagueImageUrl: 'assets/images/leagues/ligue1.png',
    country: 'France',
  ),
  RoomModel(
    leagueName: 'German Bundesliga',
    leagueImageUrl: 'assets/images/leagues/bundesliga.png',
    country: 'Germany',
  ),
  RoomModel(
    leagueName: 'Italian Seria A',
    leagueImageUrl: 'assets/images/leagues/seriaa.png',
    country: 'Italy',
  ),
  RoomModel(
    leagueName: 'Spanish La Liga',
    leagueImageUrl: 'assets/images/leagues/laliga.png',
    country: 'Spain',
  ),
];
