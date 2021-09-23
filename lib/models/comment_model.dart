import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String authorId;
  String commentId;
  String commentText;
  Timestamp createdAt;
  String id;
  String postId;
  String username;
  String avatarColor;
  String profilePicture;

  Comment({
    this.authorId = '',
    this.commentId = '',
    this.commentText = '',
    createdAt,
    this.id = '',
    this.postId = '',
    this.username = '',
    this.avatarColor = '',
    this.profilePicture = '',
  }) : this.createdAt = createdAt ?? Timestamp.now();

  factory Comment.fromJson(Map<String, dynamic> parsedJson) {
    return new Comment(
      authorId: parsedJson['authorId'] ?? '',
      commentId: parsedJson['commentId'] ?? '',
      commentText: parsedJson['commentText'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      postId: parsedJson['postId'] ?? '',
      username: parsedJson['username'] ?? '',
      avatarColor: parsedJson['avatarColor'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': this.authorId,
      'commentId': this.commentId,
      'commentText': this.commentText,
      'createdAt': this.createdAt,
      'id': this.id,
      'postId': this.postId,
      'username': this.username,
      'avatarColor': this.avatarColor,
      'profilePicture': this.profilePicture,
    };
  }
}
