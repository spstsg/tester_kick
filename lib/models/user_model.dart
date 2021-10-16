import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

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
  bool emailPasswordLogin;
  bool defaultImage;
  Map notifications;
  Map chat;
  List polls;
  bool deleted;

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
    this.polls = const [],
    emailPasswordLogin,
    defaultImage,
    notifications,
    chat,
    deleted,
  })  : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.emailPasswordLogin = emailPasswordLogin ?? false,
        this.deleted = deleted ?? false,
        this.defaultImage = defaultImage ?? true,
        this.chat = chat ?? {'userOne': '', 'userTwo': ''},
        this.notifications = notifications ??
            {
              'followers': true,
              'reactions': true,
              'comments': true,
              'messages': true,
              'shared': true,
            };

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
    bool? emailPasswordLogin,
    bool? defaultImage,
    Map? notifications,
    Map? chat,
    List? polls,
    bool? deleted,
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
      emailPasswordLogin: emailPasswordLogin ?? this.emailPasswordLogin,
      defaultImage: defaultImage ?? this.defaultImage,
      notifications: notifications ?? this.notifications,
      chat: chat ?? this.chat,
      polls: polls ?? this.polls,
      deleted: deleted ?? this.deleted,
    );
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    List _polls = parsedJson['polls'] ?? [];
    return new User(
      username: parsedJson['username'] ?? '',
      lowercaseUsername: parsedJson['lowercaseUsername'] ?? '',
      email: parsedJson['email'] ?? '',
      active: parsedJson['active'] ?? false,
      emailPasswordLogin: parsedJson['emailPasswordLogin'] ?? false,
      defaultImage: parsedJson['defaultImage'] ?? true,
      deleted: parsedJson['deleted'] ?? false,
      lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
      settings: parsedJson.containsKey('settings') ? UserSettings.fromJson(parsedJson['settings']) : UserSettings(),
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
      chat: parsedJson['chat'] ?? {'userOne': '', 'userTwo': ''},
      polls: _polls,
      notifications: parsedJson['notifications'] ??
          {
            'followers': true,
            'reactions': true,
            'comments': true,
            'messages': true,
            'shared': true,
          },
    );
  }

  factory User.fromPayload(Map<String, dynamic> parsedJson) {
    List _polls = parsedJson['polls'] ?? [];
    return new User(
      username: parsedJson['username'] ?? '',
      lowercaseUsername: parsedJson['lowercaseUsername'] ?? '',
      email: parsedJson['email'] ?? '',
      active: parsedJson['active'] ?? false,
      emailPasswordLogin: parsedJson['emailPasswordLogin'] ?? false,
      defaultImage: parsedJson['defaultImage'] ?? true,
      lastOnlineTimestamp: Timestamp.fromMillisecondsSinceEpoch(parsedJson['lastOnlineTimestamp']),
      settings: parsedJson.containsKey('settings') ? UserSettings.fromJson(parsedJson['settings']) : UserSettings(),
      phoneNumber: parsedJson['phoneNumber'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      uniqueId: parsedJson['uniqueId'] ?? parsedJson['uniqueId'] ?? 0,
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      fcmToken: parsedJson['fcmToken'] ?? '',
      dob: parsedJson['dob'] ?? '',
      bio: parsedJson['bio'] ?? '',
      team: parsedJson['team'] ?? '',
      deleted: parsedJson['deleted'] ?? false,
      lowercaseTeam: parsedJson['lowercaseTeam'] ?? '',
      postCount: parsedJson['postCount'] ?? 0,
      followersCount: parsedJson['followersCount'] ?? 0,
      followingCount: parsedJson['followingCount'] ?? 0,
      avatarColor: parsedJson['avatarColor'] ?? '#ffffff',
      chat: parsedJson['chat'] ?? {'userOne': '', 'userTwo': ''},
      polls: _polls,
      notifications: parsedJson['notifications'] ??
          {
            'followers': true,
            'reactions': true,
            'comments': true,
            'messages': true,
            'shared': true,
          },
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
      'emailPasswordLogin': this.emailPasswordLogin,
      'defaultImage': this.defaultImage,
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
      'notifications': this.notifications,
      'chat': this.chat,
      'polls': this.polls,
      'deleted': this.deleted,
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
      'emailPasswordLogin': this.emailPasswordLogin,
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
      'defaultImage': this.defaultImage,
      'notifications': this.notifications,
      'chat': this.chat,
      'polls': this.polls,
      'deleted': this.deleted,
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
        other.emailPasswordLogin == emailPasswordLogin &&
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
        other.defaultImage == defaultImage &&
        other.deleted == deleted &&
        listEquals(other.polls, polls) &&
        DeepCollectionEquality().equals(other.notifications, notifications) &&
        DeepCollectionEquality().equals(other.chat, chat);
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        phoneNumber.hashCode ^
        active.hashCode ^
        emailPasswordLogin.hashCode ^
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
        defaultImage.hashCode ^
        chat.hashCode ^
        polls.hashCode ^
        deleted.hashCode ^
        notifications.hashCode;
  }
}

class UserSettings {
  bool notifications;

  UserSettings({this.notifications = true});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new UserSettings(notifications: parsedJson['notifications'] ?? true);
  }

  Map<String, dynamic> toJson() {
    return {'notifications': this.notifications};
  }
}
