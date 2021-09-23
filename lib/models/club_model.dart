class Club {
  String id;
  String clubName;
  String lowercaseName;
  String league;
  String image;
  int fanCount;

  Club({
    this.id = '',
    this.clubName = '',
    this.lowercaseName = '',
    this.league = '',
    this.image = '',
    this.fanCount = 0,
  });

  factory Club.fromJson(Map<String, dynamic> parsedJson) {
    return new Club(
      id: parsedJson['id'] ?? '',
      clubName: parsedJson['clubName'] ?? '',
      lowercaseName: parsedJson['lowercaseName'] ?? '',
      league: parsedJson['league'] ?? '',
      image: parsedJson['image'] ?? '',
      fanCount: parsedJson['fanCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      'clubName': this.clubName,
      'lowercaseName': this.lowercaseName,
      'league': this.league,
      'image': this.image,
      'fanCount': this.fanCount,
    };
  }
}
