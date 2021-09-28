import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:kick_chat/models/user_model.dart';

class Post with ChangeNotifier {
  User author;
  String id;
  String authorId;
  String username;
  String email;
  String avatarColor;
  String profilePicture;
  String post;
  String bgColor;
  String gifUrl;
  String privacy;
  int commentsCount;
  int reactionsCount;
  Timestamp createdAt;
  Map reactions;
  List postMedia;
  List postVideo;
  int shareCount;
  SharedPost sharedPost;

  Post({
    author,
    this.id = '',
    this.authorId = '',
    this.username = '',
    this.email = '',
    this.avatarColor = '',
    this.profilePicture = '',
    this.bgColor = '',
    this.commentsCount = 0,
    this.postMedia = const [],
    this.postVideo = const [],
    createdAt,
    this.post = '',
    this.gifUrl = '',
    this.privacy = '',
    this.reactionsCount = 0,
    sharedPost,
    reactions,
    shareCount,
  })  : this.author = author ?? User(),
        this.sharedPost = sharedPost ?? SharedPost(),
        this.shareCount = shareCount ?? 0,
        this.createdAt = createdAt ?? Timestamp.now(),
        this.reactions = reactions ??
            {
              'angry': 0,
              'happy': 0,
              'wow': 0,
              'like': 0,
              'love': 0,
              'sad': 0,
            };

  factory Post.fromJson(Map<String, dynamic> parsedJson) {
    List _postMedia = parsedJson['postMedia'] ?? [];
    List _postVideo = parsedJson['postVideo'] ?? [];
    return new Post(
      author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
      id: parsedJson['id'] ?? '',
      authorId: parsedJson['authorId'] ?? '',
      username: parsedJson['username'] ?? '',
      email: parsedJson['email'] ?? '',
      avatarColor: parsedJson['avatarColor'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
      bgColor: parsedJson['bgColor'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      commentsCount: parsedJson['commentsCount'] ?? 0,
      shareCount: parsedJson['shareCount'] ?? 0,
      sharedPost: parsedJson.containsKey('sharedPost') ? SharedPost.fromJson(parsedJson['sharedPost']) : SharedPost(),
      post: parsedJson['post'] ?? '',
      gifUrl: parsedJson['gifUrl'] ?? '',
      privacy: parsedJson['privacy'] ?? '',
      reactionsCount: parsedJson['reactionsCount'] ?? 0,
      postMedia: _postMedia,
      postVideo: _postVideo,
      reactions: parsedJson['reactions'] ??
          {
            'angry': 0,
            'happy': 0,
            'wow': 0,
            'like': 0,
            'love': 0,
            'sad': 0,
          },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "author": this.author.toJson(),
      "id": this.id,
      'authorId': this.authorId,
      'username': this.username,
      'email': this.email,
      'avatarColor': this.avatarColor,
      'profilePicture': this.profilePicture,
      'bgColor': this.bgColor,
      'commentsCount': this.commentsCount,
      'shareCount': this.shareCount,
      'sharedPost': this.sharedPost.toJson(),
      'createdAt': this.createdAt,
      'post': this.post,
      'gifUrl': this.gifUrl,
      'privacy': this.privacy,
      'reactionsCount': this.reactionsCount,
      'reactions': this.reactions,
      "postMedia": this.postMedia,
      "postVideo": this.postVideo,
    };
  }

  Post copyWith({
    User? author,
    String? id,
    String? authorId,
    String? username,
    String? email,
    String? avatarColor,
    String? profilePicture,
    String? post,
    String? bgColor,
    String? gifUrl,
    String? privacy,
    int? commentsCount,
    int? reactionsCount,
    Timestamp? createdAt,
    List? postMedia,
    List? postVideo,
    int? shareCount,
    SharedPost? sharedPost,
    Map? reactions,
  }) {
    return Post(
      author: author ?? this.author,
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarColor: avatarColor ?? this.avatarColor,
      profilePicture: profilePicture ?? this.profilePicture,
      post: post ?? this.post,
      bgColor: bgColor ?? this.bgColor,
      gifUrl: gifUrl ?? this.gifUrl,
      privacy: privacy ?? this.privacy,
      commentsCount: commentsCount ?? this.commentsCount,
      reactionsCount: reactionsCount ?? this.reactionsCount,
      createdAt: createdAt ?? this.createdAt,
      postMedia: postMedia ?? this.postMedia,
      postVideo: postVideo ?? this.postVideo,
      shareCount: shareCount ?? this.shareCount,
      sharedPost: sharedPost ?? this.sharedPost,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.author == author &&
        other.id == id &&
        other.authorId == authorId &&
        other.username == username &&
        other.email == email &&
        other.avatarColor == avatarColor &&
        other.profilePicture == profilePicture &&
        other.post == post &&
        other.bgColor == bgColor &&
        other.gifUrl == gifUrl &&
        other.privacy == privacy &&
        other.commentsCount == commentsCount &&
        other.reactionsCount == reactionsCount &&
        other.createdAt == createdAt &&
        listEquals(other.postMedia, postMedia) &&
        listEquals(other.postVideo, postVideo) &&
        other.shareCount == shareCount &&
        DeepCollectionEquality().equals(other.sharedPost.toJson(), sharedPost.toJson()) &&
        DeepCollectionEquality().equals(other.reactions, reactions);
  }

  @override
  int get hashCode {
    return author.hashCode ^
        id.hashCode ^
        authorId.hashCode ^
        username.hashCode ^
        email.hashCode ^
        avatarColor.hashCode ^
        profilePicture.hashCode ^
        post.hashCode ^
        bgColor.hashCode ^
        gifUrl.hashCode ^
        privacy.hashCode ^
        commentsCount.hashCode ^
        reactionsCount.hashCode ^
        createdAt.hashCode ^
        postMedia.hashCode ^
        postVideo.hashCode ^
        reactions.hashCode ^
        shareCount.hashCode ^
        sharedPost.hashCode;
  }
}

class SharedPost {
  String id;
  String authorId;
  String username;
  String avatarColor;
  String profilePicture;
  String post;
  String bgColor;
  String gifUrl;
  Timestamp createdAt;
  List postMedia;
  List postVideo;
  Map reactions;

  SharedPost({
    this.id = '',
    this.authorId = '',
    this.username = '',
    this.avatarColor = '',
    this.profilePicture = '',
    this.post = '',
    this.bgColor = '',
    this.gifUrl = '',
    createdAt,
    this.postMedia = const [],
    this.postVideo = const [],
    reactions,
  })  : this.createdAt = createdAt ?? Timestamp.now(),
        this.reactions = reactions ??
            {
              'angry': 0,
              'happy': 0,
              'wow': 0,
              'like': 0,
              'love': 0,
              'sad': 0,
            };

  factory SharedPost.fromJson(Map<String, dynamic> parsedJson) {
    List _postMedia = parsedJson['postMedia'] ?? [];
    List _postVideo = parsedJson['postVideo'] ?? [];
    return new SharedPost(
      id: parsedJson['id'] ?? '',
      authorId: parsedJson['authorId'] ?? '',
      username: parsedJson['username'] ?? '',
      avatarColor: parsedJson['avatarColor'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
      bgColor: parsedJson['bgColor'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      post: parsedJson['post'] ?? '',
      gifUrl: parsedJson['gifUrl'] ?? '',
      reactions: parsedJson['reactions'] ??
          {
            'angry': 0,
            'happy': 0,
            'wow': 0,
            'like': 0,
            'love': 0,
            'sad': 0,
          },
      postMedia: _postMedia,
      postVideo: _postVideo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      'authorId': this.authorId,
      'username': this.username,
      'avatarColor': this.avatarColor,
      'profilePicture': this.profilePicture,
      'bgColor': this.bgColor,
      'createdAt': this.createdAt,
      'post': this.post,
      'gifUrl': this.gifUrl,
      "postMedia": this.postMedia,
      "postVideo": this.postVideo,
      "reactions": this.reactions,
    };
  }
}
