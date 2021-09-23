import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kick_chat/models/user_model.dart';

class Room {
  String id;
  String title;
  List tags;
  User creator;
  List speakers;
  List participants;
  List raisedHands;
  Timestamp createdDate;
  String status;
  String channel;
  String startTime;
  String endTime;
  String roomStarted;
  String newEndTime;
  String newRoomStarted;

  Room({
    creator,
    this.id = '',
    this.title = '',
    this.tags = const [],
    this.speakers = const [],
    this.participants = const [],
    this.raisedHands = const [],
    this.status = '',
    this.channel = '',
    this.startTime = '',
    this.endTime = '',
    this.roomStarted = '',
    this.newEndTime = '',
    this.newRoomStarted = '',
    createdDate,
  })  : this.creator = creator ?? User(),
        this.createdDate = createdDate ?? Timestamp.now();

  factory Room.fromJson(Map<String, dynamic> parsedJson) {
    List _tags = parsedJson['tags'] ?? [];
    List _speakers = parsedJson['speakers'] ?? [];
    List _participants = parsedJson['participants'] ?? [];
    List _raisedHands = parsedJson['raisedHands'] ?? [];
    return new Room(
      creator: parsedJson.containsKey('creator') ? User.fromJson(parsedJson['creator']) : User(),
      id: parsedJson['id'] ?? '',
      title: parsedJson['title'] ?? '',
      tags: _tags,
      speakers: _speakers,
      participants: _participants,
      raisedHands: _raisedHands,
      status: parsedJson['status'] ?? '',
      channel: parsedJson['channel'] ?? '',
      createdDate: parsedJson['createdDate'] ?? Timestamp.now(),
      roomStarted: parsedJson['roomStarted'] ?? '',
      startTime: parsedJson['startTime'] ?? '',
      endTime: parsedJson['endTime'] ?? '',
      newEndTime: parsedJson['newEndTime'] ?? '',
      newRoomStarted: parsedJson['newRoomStarted'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "creator": this.creator.toJson(),
      "id": this.id,
      'title': this.title,
      'tags': this.tags,
      'speakers': this.speakers,
      'participants': this.participants,
      'raisedHands': this.raisedHands,
      'status': this.status,
      'channel': this.channel,
      'createdDate': this.createdDate,
      'roomStarted': this.roomStarted,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'newEndTime': this.newEndTime,
      'newRoomStarted': this.newRoomStarted,
    };
  }

  Room copyWith({
    String? id,
    String? title,
    List? tags,
    User? creator,
    List? speakers,
    List? participants,
    List? raisedHands,
    Timestamp? createdDate,
    String? roomStarted,
    String? status,
    String? channel,
    String? startTime,
    String? endTime,
    String? newEndTime,
    String? newRoomStarted,
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      creator: creator ?? this.creator,
      speakers: speakers ?? this.speakers,
      participants: participants ?? this.participants,
      raisedHands: raisedHands ?? this.raisedHands,
      createdDate: createdDate ?? this.createdDate,
      roomStarted: roomStarted ?? this.roomStarted,
      status: status ?? this.status,
      channel: channel ?? this.channel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      newEndTime: newEndTime ?? this.newEndTime,
      newRoomStarted: newRoomStarted ?? this.newRoomStarted,
    );
  }
}
