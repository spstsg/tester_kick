import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/user_model.dart';

class NotificationModel {
  Timestamp createdAt;
  String body;
  String id;
  String type;
  bool seen;
  String title;
  String toUserID;
  String fromUserID;
  User toUser;
  Map<String, dynamic> metadata;

  NotificationModel({
    createdAt,
    this.body = '',
    this.id = '',
    this.type = '',
    this.seen = false,
    this.title = '',
    this.toUserID = '',
    this.fromUserID = '',
    toUser,
    this.metadata = const {},
  })  : this.createdAt = createdAt ?? Timestamp.now(),
        this.toUser = toUser ?? User();

  factory NotificationModel.fromJson(Map<String, dynamic> parsedJson) {
    return new NotificationModel(
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      body: parsedJson['body'] ?? '',
      id: parsedJson['id'] ?? '',
      seen: parsedJson['seen'] ?? false,
      title: parsedJson['title'] ?? '',
      toUserID: parsedJson['toUserID'] ?? '',
      fromUserID: parsedJson['fromUserID'] ?? '',
      metadata: parsedJson['metadata'] ?? Map(),
      type: parsedJson['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': this.createdAt,
      'body': this.body,
      'id': this.id,
      'seen': this.seen,
      'title': this.title,
      'toUserID': this.toUserID,
      'fromUserID': this.fromUserID,
      'metadata': this.metadata,
      'type': this.type
    };
  }
}
