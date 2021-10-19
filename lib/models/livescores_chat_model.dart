import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/user_model.dart';

class LivescoresModel {
  User? sender;
  String id;
  String lastMessage;
  String senderId;
  Timestamp lastMessageDate;

  LivescoresModel({
    sender,
    this.id = '',
    this.lastMessage = '',
    this.senderId = '',
    lastMessageDate,
  }) : this.lastMessageDate = lastMessageDate ?? Timestamp.now();

  factory LivescoresModel.fromJson(Map<String, dynamic> parsedJson) {
    return new LivescoresModel(
      sender: parsedJson.containsKey('sender') ? User.fromJson(parsedJson['sender']) : User(),
      id: parsedJson['id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      lastMessageDate: parsedJson['lastMessageDate'],
    );
  }

  factory LivescoresModel.fromPayload(Map<String, dynamic> parsedJson) {
    return new LivescoresModel(
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
