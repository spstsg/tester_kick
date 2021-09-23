import 'package:cloud_firestore/cloud_firestore.dart';

class Reactions {
  final String reactionAuthorId;
  final String postId;
  String type;
  final String username;
  final String avatarColor;
  final String profilePicture;
  Timestamp createdAt;

  Reactions({
    this.reactionAuthorId = '',
    required this.postId,
    required this.type,
    required this.username,
    required this.avatarColor,
    required this.profilePicture,
    createdAt,
  }) : this.createdAt = createdAt ?? Timestamp.now();

  factory Reactions.fromJson(Map<String, dynamic> parsedJson) {
    return new Reactions(
      // reactionId: parsedJson['id'] ?? parsedJson['reactionId'] ?? '',
      reactionAuthorId: parsedJson['reactionAuthorId'] ?? '',
      postId: parsedJson['postId'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      type: parsedJson['type'] ?? '',
      username: parsedJson['username'] ?? '',
      avatarColor: parsedJson['avatarColor'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'reactionId': this.reactionId,
      'reactionAuthorId': this.reactionAuthorId,
      'createdAt': this.createdAt,
      'type': this.type,
      'postId': this.postId,
      'username': this.username,
      'avatarColor': this.avatarColor,
      'profilePicture': this.profilePicture,
    };
  }
}
