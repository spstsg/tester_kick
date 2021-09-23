import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  String id;
  String creatorId;
  String lastMessage;
  String name;
  String senderId;
  String receiverId;
  Timestamp lastMessageDate;
  bool isRead;
  bool messageDeleted;

  ConversationModel({
    this.id = '',
    this.creatorId = '',
    this.lastMessage = '',
    this.name = '',
    this.senderId = '',
    this.receiverId = '',
    lastMessageDate,
    isRead,
    messageDeleted,
  })  : this.lastMessageDate = lastMessageDate ?? Timestamp.now(),
        this.isRead = isRead ?? false,
        this.messageDeleted = messageDeleted ?? false;

  factory ConversationModel.fromJson(Map<String, dynamic> parsedJson) {
    return new ConversationModel(
      id: parsedJson['id'] ?? '',
      creatorId: parsedJson['creatorID'] ?? parsedJson['creator_id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      name: parsedJson['name'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      receiverId: parsedJson['receiverId'] ?? '',
      lastMessageDate: parsedJson['lastMessageDate'],
      isRead: parsedJson['isRead'],
      messageDeleted: parsedJson['messageDeleted'],
    );
  }

  factory ConversationModel.fromPayload(Map<String, dynamic> parsedJson) {
    return new ConversationModel(
      id: parsedJson['id'] ?? '',
      creatorId: parsedJson['creatorID'] ?? parsedJson['creator_id'] ?? '',
      lastMessage: parsedJson['lastMessage'] ?? '',
      name: parsedJson['name'] ?? '',
      senderId: parsedJson['senderId'] ?? '',
      receiverId: parsedJson['receiverId'] ?? '',
      isRead: parsedJson['isRead'] ?? false,
      messageDeleted: parsedJson['messageDeleted'] ?? false,
      lastMessageDate: Timestamp.fromMillisecondsSinceEpoch(parsedJson['lastMessageDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'creatorID': this.creatorId,
      'lastMessage': this.lastMessage,
      'name': this.name,
      'senderId': this.senderId,
      'receiverId': this.receiverId,
      'lastMessageDate': this.lastMessageDate,
      'isRead': this.isRead,
      'messageDeleted': this.messageDeleted,
    };
  }

  Map<String, dynamic> toPayload() {
    return {
      'id': this.id,
      'creatorID': this.creatorId,
      'lastMessage': this.lastMessage,
      'name': this.name,
      'senderId': this.senderId,
      'receiverId': this.receiverId,
      'isRead': this.isRead,
      'messageDeleted': this.messageDeleted,
      'lastMessageDate': this.lastMessageDate.millisecondsSinceEpoch
    };
  }
}
