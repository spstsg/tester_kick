import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/user_model.dart';

class AudioChatRoomModel {
  User? sender;
  String id;
  String lastMessage;
  String senderId;
  Timestamp lastMessageDate;

  AudioChatRoomModel({
    sender,
    this.id = '',
    this.lastMessage = '',
    this.senderId = '',
    lastMessageDate,
  }) : this.lastMessageDate = lastMessageDate ?? Timestamp.now();

  factory AudioChatRoomModel.fromJson(Map<String, dynamic> parsedJson) {
    return new AudioChatRoomModel(
      sender: parsedJson.containsKey('sender') ? User.fromJson(parsedJson['sender']) : User(),
      id: parsedJson['id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      lastMessageDate: parsedJson['lastMessageDate'],
    );
  }

  factory AudioChatRoomModel.fromPayload(Map<String, dynamic> parsedJson) {
    return new AudioChatRoomModel(
      sender: parsedJson.containsKey('sender') ? User.fromJson(parsedJson['sender']) : User(),
      id: parsedJson['id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      lastMessageDate: Timestamp.fromMillisecondsSinceEpoch(parsedJson['lastMessageDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": this.sender != null ? this.sender!.toJson() : null,
      'id': this.id,
      'lastMessage': this.lastMessage,
      'senderId': this.senderId,
      'lastMessageDate': this.lastMessageDate
    };
  }

  Map<String, dynamic> toPayload() {
    return {
      "sender": this.sender != null ? this.sender!.toJson() : null,
      'id': this.id,
      'lastMessage': this.lastMessage,
      'senderId': this.senderId,
      'lastMessageDate': this.lastMessageDate.millisecondsSinceEpoch
    };
  }
}
