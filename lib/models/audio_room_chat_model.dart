import 'package:cloud_firestore/cloud_firestore.dart';

class AudioChatRoomModel {
  String id;
  String lastMessage;
  String senderId;
  String username;
  String profilePicture;
  Timestamp lastMessageDate;

  AudioChatRoomModel({
    this.id = '',
    this.lastMessage = '',
    this.senderId = '',
    this.username = '',
    this.profilePicture = '',
    lastMessageDate,
  }) : this.lastMessageDate = lastMessageDate ?? Timestamp.now();

  factory AudioChatRoomModel.fromJson(Map<String, dynamic> parsedJson) {
    return new AudioChatRoomModel(
      id: parsedJson['id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      username: parsedJson['username'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
      lastMessageDate: parsedJson['lastMessageDate'],
    );
  }

  factory AudioChatRoomModel.fromPayload(Map<String, dynamic> parsedJson) {
    return new AudioChatRoomModel(
      id: parsedJson['id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      username: parsedJson['username'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
      lastMessageDate: Timestamp.fromMillisecondsSinceEpoch(parsedJson['lastMessageDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'lastMessage': this.lastMessage,
      'senderId': this.senderId,
      'username': this.username,
      'profilePicture': this.profilePicture,
      'lastMessageDate': this.lastMessageDate
    };
  }

  Map<String, dynamic> toPayload() {
    return {
      'id': this.id,
      'lastMessage': this.lastMessage,
      'senderId': this.senderId,
      'username': this.username,
      'profilePicture': this.profilePicture,
      'lastMessageDate': this.lastMessageDate.millisecondsSinceEpoch
    };
  }
}
