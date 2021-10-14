import 'package:cloud_firestore/cloud_firestore.dart';

class MessageData {
  String messageID;
  String content;
  Timestamp created;
  String recipientID;
  String senderID;
  String gifUrl;
  List chatImages;
  bool isRead;
  bool messageDeleted;
  bool gifDeleted;
  bool imageDeleted;

  MessageData({
    this.messageID = '',
    this.content = '',
    created,
    isRead,
    messageDeleted,
    gifDeleted,
    imageDeleted,
    this.recipientID = '',
    this.senderID = '',
    this.gifUrl = '',
    this.chatImages = const [],
  })  : this.created = created ?? Timestamp.now(),
        this.isRead = isRead ?? false,
        this.messageDeleted = messageDeleted ?? false,
        this.gifDeleted = gifDeleted ?? false,
        this.imageDeleted = imageDeleted ?? false;

  factory MessageData.fromJson(Map<String, dynamic> parsedJson) {
    List _chatImages = parsedJson['chatImages'] ?? [];
    return new MessageData(
      messageID: parsedJson['id'] ?? parsedJson['messageID'] ?? '',
      content: parsedJson['content'] ?? '',
      created: parsedJson['createdAt'] ?? parsedJson['created'],
      recipientID: parsedJson['recipientID'] ?? '',
      senderID: parsedJson['senderID'] ?? '',
      gifUrl: parsedJson['gifUrl'] ?? '',
      isRead: parsedJson['isRead'] ?? false,
      messageDeleted: parsedJson['messageDeleted'] ?? false,
      gifDeleted: parsedJson['gifDeleted'] ?? false,
      imageDeleted: parsedJson['imageDeleted'] ?? false,
      chatImages: _chatImages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.messageID,
      'content': this.content,
      'createdAt': this.created,
      'recipientID': this.recipientID,
      'senderID': this.senderID,
      'gifUrl': this.gifUrl,
      "chatImages": this.chatImages,
      "isRead": this.isRead,
      "messageDeleted": this.messageDeleted,
      "gifDeleted": this.gifDeleted,
      "imageDeleted": this.imageDeleted,
    };
  }
}
