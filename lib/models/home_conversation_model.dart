import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/user_model.dart';

class HomeConversationModel {
  List<User> members;
  ConversationModel? conversationModel;

  HomeConversationModel({
    this.members = const [],
    this.conversationModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'members': [
        {
          'username': this.members[0].username,
          'email': this.members[0].email,
          'settings': this.members[0].settings.toJson(),
          'phoneNumber': this.members[0].phoneNumber,
          'id': this.members[0].userID,
          'active': this.members[0].active,
          'lastOnlineTimestamp': this.members[0].lastOnlineTimestamp,
          'profilePictureURL': this.members[0].profilePictureURL,
          'appIdentifier': this.members[0].appIdentifier,
          'fcmToken': this.members[0].fcmToken,
          'dob': this.members[0].dob,
          'postCount': this.members[0].postCount,
          'followersCount': this.members[0].followersCount,
          'followingCount': this.members[0].followingCount,
          'avatarColor': this.members[0].avatarColor,
          'bio': this.members[0].bio,
        }
      ],
      'conversationModel': {
        'id': this.conversationModel!.id,
        'creatorID': this.conversationModel!.creatorId,
        'lastMessage': this.conversationModel!.lastMessage,
        'senderId': this.conversationModel!.senderId,
        'receiverId': this.conversationModel!.receiverId,
        'isRead': this.conversationModel!.isRead,
        'messageDeleted': this.conversationModel!.messageDeleted,
        'lastMessageDate': this.conversationModel!.lastMessageDate
      }
    };
  }
}
