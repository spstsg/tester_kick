import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/user_model.dart';

class UpcomingRoom {
  String id;
  String title;
  List tags;
  User creator;
  String createdDate;
  String description;
  bool status;

  UpcomingRoom({
    creator,
    this.id = '',
    this.title = '',
    this.tags = const [],
    this.description = '',
    createdDate,
    status,
  })  : this.creator = creator ?? User(),
        this.status = status ?? false,
        this.createdDate = createdDate ?? Timestamp.now().toString();

  factory UpcomingRoom.fromJson(Map<String, dynamic> parsedJson) {
    List _tags = parsedJson['tags'] ?? [];
    return new UpcomingRoom(
      creator: parsedJson.containsKey('creator') ? User.fromJson(parsedJson['creator']) : User(),
      id: parsedJson['id'] ?? '',
      title: parsedJson['title'] ?? '',
      description: parsedJson['description'] ?? '',
      tags: _tags,
      status: parsedJson['status'] ?? false,
      createdDate: parsedJson['createdDate'] ?? Timestamp.now().toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "creator": this.creator.toJson(),
      "id": this.id,
      'title': this.title,
      'tags': this.tags,
      'status': this.status,
      'description': this.description,
      'createdDate': this.createdDate,
    };
  }
}
