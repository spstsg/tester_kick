import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/user_model.dart';

class Comment {
  User? author;
  String authorId;
  String commentId;
  String commentText;
  Timestamp createdAt;
  String id;
  String postId;

  Comment({
    author,
    this.authorId = '',
    this.commentId = '',
    this.commentText = '',
    createdAt,
    this.id = '',
    this.postId = '',
  }) : this.createdAt = createdAt ?? Timestamp.now();

  factory Comment.fromJson(Map<String, dynamic> parsedJson) {
    return new Comment(
      author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
      authorId: parsedJson['authorId'] ?? '',
      commentId: parsedJson['commentId'] ?? '',
      commentText: parsedJson['commentText'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      postId: parsedJson['postId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "author": this.author != null ? this.author!.toJson() : null,
      'authorId': this.authorId,
      'commentId': this.commentId,
      'commentText': this.commentText,
      'createdAt': this.createdAt,
      'id': this.id,
      'postId': this.postId,
    };
  }
}
