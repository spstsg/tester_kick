import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/user_model.dart';

class UpcomingRoom {
  User? creator;
  String creatorId;
  String id;
  String title;
  List tags;
  String createdDate;
  String scheduledDate;
  String description;
  bool status;
  bool notificationSent;
  bool creatorReminderSent;
  List fcmTokens;

  UpcomingRoom({
    creator,
    this.creatorId = '',
    this.id = '',
    this.title = '',
    this.tags = const [],
    this.fcmTokens = const [],
    this.description = '',
    this.scheduledDate = '',
    createdDate,
    status,
    notificationSent,
    creatorReminderSent,
  })  : this.status = status ?? false,
        this.notificationSent = notificationSent ?? false,
        this.creatorReminderSent = creatorReminderSent ?? false,
        this.createdDate = createdDate ?? '${Timestamp.now()}';

  factory UpcomingRoom.fromJson(Map<String, dynamic> parsedJson) {
    List _tags = parsedJson['tags'] ?? [];
    List _fcmTokens = parsedJson['fcmTokens'] ?? [];
    return new UpcomingRoom(
      creator: parsedJson.containsKey('creator') ? User.fromJson(parsedJson['creator']) : User(),
      creatorId: parsedJson['creatorId'] ?? '',
      id: parsedJson['id'] ?? '',
      title: parsedJson['title'] ?? '',
      description: parsedJson['description'] ?? '',
      scheduledDate: parsedJson['scheduledDate'] ?? '',
      tags: _tags,
      fcmTokens: _fcmTokens,
      status: parsedJson['status'] ?? false,
      notificationSent: parsedJson['notificationSent'] ?? false,
      creatorReminderSent: parsedJson['creatorReminderSent'] ?? false,
      createdDate: parsedJson['createdDate'] ?? '${Timestamp.now()}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "creator": this.creator != null ? this.creator!.toJson() : null,
      "creatorId": this.creatorId,
      "id": this.id,
      'title': this.title,
      'tags': this.tags,
      'fcmTokens': this.fcmTokens,
      'status': this.status,
      'notificationSent': this.notificationSent,
      'creatorReminderSent': this.creatorReminderSent,
      'description': this.description,
      'scheduledDate': this.scheduledDate,
      'createdDate': this.createdDate,
    };
  }
}
