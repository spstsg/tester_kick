import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String email;
  String password;
  UserSettings settings;
  String phoneNumber = '';
  bool active;
  Timestamp lastOnlineTimestamp;
  String userID;
  int uniqueId;
  String profilePictureURL;
  String appIdentifier = 'Flutter Social Network ${Platform.operatingSystem}';
  String fcmToken;
  String username;
  String lowercaseUsername;
  String dob;
  int postCount;
  String avatarColor;
  String bio;
  int followersCount;
  int followingCount;
  String team;
  String lowercaseTeam;

  //internal use only, don't save to db
  bool selected = false;

  User({
    this.username = '',
    this.lowercaseUsername = '',
    this.email = '',
    this.password = '',
    this.userID = '',
    this.uniqueId = 0,
    this.profilePictureURL = '',
    this.phoneNumber = '',
    this.active = false,
    lastOnlineTimestamp,
    settings,
    this.fcmToken = '',
    this.dob = '',
    this.bio = '',
    this.team = '',
    this.lowercaseTeam = '',
    this.avatarColor = '#ffffff',
    this.postCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  })  : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings();

  User copyWith({
    String? username,
    String? lowercaseUsername,
    String? email,
    String? password,
    String? userID,
    int? uniqueId,
    String? profilePictureURL,
    String? phoneNumber,
    bool? active,
    Timestamp? lastOnlineTimestamp,
    UserSettings? settings,
    String? fcmToken,
    String? dob,
    int? postCount,
    int? followersCount,
    int? followingCount,
    String? avatarColor,
    String? bio,
    String? team,
    String? lowercaseTeam,
  }) {
    return new User(
      username: username ?? this.username,
      lowercaseUsername: lowercaseUsername ?? this.lowercaseUsername,
      email: email ?? this.email,
      password: password ?? this.password,
      userID: userID ?? this.userID,
      uniqueId: uniqueId ?? this.uniqueId,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      active: active ?? this.active,
      lastOnlineTimestamp: lastOnlineTimestamp ?? this.lastOnlineTimestamp,
      settings: settings ?? this.settings,
      fcmToken: fcmToken ?? this.fcmToken,
      dob: dob ?? this.dob,
      postCount: postCount ?? this.postCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      avatarColor: avatarColor ?? this.avatarColor,
      bio: bio ?? this.bio,
      team: team ?? this.team,
      lowercaseTeam: lowercaseTeam ?? this.lowercaseTeam,
    );
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
      username: parsedJson['username'] ?? '',
      lowercaseUsername: parsedJson['lowercaseUsername'] ?? '',
      email: parsedJson['email'] ?? '',
      active: parsedJson['active'] ?? false,
      lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
      settings: parsedJson.containsKey('settings')
          ? UserSettings.fromJson(parsedJson['settings'])
          : UserSettings(),
      phoneNumber: parsedJson['phoneNumber'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      fcmToken: parsedJson['fcmToken'] ?? '',
      dob: parsedJson['dob'] ?? '',
      uniqueId: parsedJson['uniqueId'] ?? 0,
      bio: parsedJson['bio'] ?? '',
      team: parsedJson['team'] ?? '',
      lowercaseTeam: parsedJson['lowercaseTeam'] ?? '',
      postCount: parsedJson['postCount'] ?? 0,
      followersCount: parsedJson['followersCount'] ?? 0,
      followingCount: parsedJson['followingCount'] ?? 0,
      avatarColor: parsedJson['avatarColor'] ?? '#ffffff',
    );
  }

  factory User.fromPayload(Map<String, dynamic> parsedJson) {
    return new User(
      username: parsedJson['username'] ?? '',
      lowercaseUsername: parsedJson['lowercaseUsername'] ?? '',
      email: parsedJson['email'] ?? '',
      active: parsedJson['active'] ?? false,
      lastOnlineTimestamp: Timestamp.fromMillisecondsSinceEpoch(parsedJson['lastOnlineTimestamp']),
      settings: parsedJson.containsKey('settings')
          ? UserSettings.fromJson(parsedJson['settings'])
          : UserSettings(),
      phoneNumber: parsedJson['phoneNumber'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      uniqueId: parsedJson['uniqueId'] ?? parsedJson['uniqueId'] ?? 0,
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      fcmToken: parsedJson['fcmToken'] ?? '',
      dob: parsedJson['dob'] ?? '',
      bio: parsedJson['bio'] ?? '',
      team: parsedJson['team'] ?? '',
      lowercaseTeam: parsedJson['lowercaseTeam'] ?? '',
      postCount: parsedJson['postCount'] ?? 0,
      followersCount: parsedJson['followersCount'] ?? 0,
      followingCount: parsedJson['followingCount'] ?? 0,
      avatarColor: parsedJson['avatarColor'] ?? '#ffffff',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': this.username,
      'lowercaseUsername': this.lowercaseUsername,
      'email': this.email,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'uniqueId': this.uniqueId,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'dob': this.dob,
      'postCount': this.postCount,
      'followersCount': this.followersCount,
      'followingCount': this.followingCount,
      'avatarColor': this.avatarColor,
      'bio': this.bio,
      'team': this.team,
      'lowercaseTeam': this.lowercaseTeam,
    };
  }

  Map<String, dynamic> toPayload() {
    return {
      'username': this.username,
      'lowercaseUsername': this.lowercaseUsername,
      'email': this.email,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp.millisecondsSinceEpoch,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'dob': this.dob,
      'postCount': this.postCount,
      'followersCount': this.followersCount,
      'followingCount': this.followingCount,
      'avatarColor': this.avatarColor,
      'bio': this.bio,
      'team': this.team,
      'lowercaseTeam': this.lowercaseTeam,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.email == email &&
        other.password == password &&
        other.phoneNumber == phoneNumber &&
        other.active == active &&
        other.lastOnlineTimestamp == lastOnlineTimestamp &&
        other.userID == userID &&
        other.uniqueId == uniqueId &&
        other.profilePictureURL == profilePictureURL &&
        other.fcmToken == fcmToken &&
        other.username == username &&
        other.lowercaseUsername == lowercaseUsername &&
        other.dob == dob &&
        other.postCount == postCount &&
        other.avatarColor == avatarColor &&
        other.bio == bio &&
        other.followersCount == followersCount &&
        other.followingCount == followingCount &&
        other.team == team &&
        other.lowercaseTeam == lowercaseTeam &&
        other.selected == selected;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        phoneNumber.hashCode ^
        active.hashCode ^
        lastOnlineTimestamp.hashCode ^
        userID.hashCode ^
        uniqueId.hashCode ^
        profilePictureURL.hashCode ^
        fcmToken.hashCode ^
        username.hashCode ^
        lowercaseUsername.hashCode ^
        dob.hashCode ^
        postCount.hashCode ^
        avatarColor.hashCode ^
        bio.hashCode ^
        followersCount.hashCode ^
        followingCount.hashCode ^
        team.hashCode ^
        lowercaseTeam.hashCode ^
        selected.hashCode;
  }
}

class UserSettings {
  bool pushNewMessages;

  UserSettings({this.pushNewMessages = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new UserSettings(pushNewMessages: parsedJson['pushNewMessages'] ?? true);
  }

  Map<String, dynamic> toJson() {
    return {'pushNewMessages': this.pushNewMessages};
  }
}

// class UserSignup {
//   String email;
//   String password;
//   String dob;
//   String phoneNumber;
//   String profilePicture;
//   String team;

//   UserSignup({
//     this.email = '',
//     this.password = '',
//     this.dob = '',
//     this.phoneNumber = '',
//     this.profilePicture = '',
//     this.team = '',
//   });
// }
