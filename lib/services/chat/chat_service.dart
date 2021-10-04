import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/chat_model.dart';
import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/message_data_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/user/user_service.dart';

class ChatService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserService _userService = UserService();
  late StreamController<User> userStreamController;
  // ignore: close_sinks
  StreamController<List<HomeConversationModel>> conversationsStream = StreamController<List<HomeConversationModel>>();
  // ignore: unused_field
  late StreamSubscription<QuerySnapshot> _conversationsStreamSubscription;

  Stream<User> getUserByID(String id) async* {
    userStreamController = StreamController();
    firestore.collection(USERS).doc(id).snapshots().listen((user) {
      try {
        User userModel = User.fromJson(user.data() as Map<String, dynamic>);
        if (!userStreamController.isClosed) {
          userStreamController.sink.add(userModel);
        }
      } catch (e) {
        throw e;
      }
    });
    yield* userStreamController.stream;
  }

  Stream<ChatModel> getChatMessages(HomeConversationModel homeConversationModel) async* {
    // ignore: close_sinks
    StreamController<ChatModel> chatModelStreamController = StreamController();
    ChatModel chatModel = ChatModel();
    List<MessageData> listOfMessages = [];
    List<User> listOfMembers = homeConversationModel.members;
    User friend = homeConversationModel.members.first;
    getUserByID(friend.userID).listen((user) {
      listOfMembers.clear();
      listOfMembers.add(user);
      chatModel.message = listOfMessages;
      chatModel.members = listOfMembers;
      chatModelStreamController.sink.add(chatModel);
    });
    if (homeConversationModel.conversationModel != null) {
      firestore
          .collection(CHANNELS)
          .doc(homeConversationModel.conversationModel!.id)
          .collection(THREAD)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) {
        listOfMessages.clear();
        onData.docs.forEach((document) {
          listOfMessages.add(MessageData.fromJson(document.data()));
        });
        chatModel.message = listOfMessages;
        chatModel.members = listOfMembers;
        chatModelStreamController.sink.add(chatModel);
      });
    }
    yield* chatModelStreamController.stream;
  }

  Future<void> sendMessage(List<User> members, MessageData message, ConversationModel conversationModel) async {
    var ref = firestore.collection(CHANNELS).doc(conversationModel.id).collection(THREAD).doc();
    // message.messageID = ref.id;
    if (message.gifUrl.isNotEmpty) {
      message.content = '';
    }
    ref.set(message.toJson());

    await createChatConversation(conversationModel);

    await Future.forEach(members, (User element) async {
      if (element.settings.notifications) {
        // User? friend;
        // if (isGroup) {
        //   friend = payloadFriends.firstWhere((user) => user.fcmToken == element.fcmToken);
        //   payloadFriends.remove(friend);
        //   payloadFriends.add(MyAppState.currentUser!);
        // }
        // Map<String, dynamic> payload = <String, dynamic>{
        //   'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        //   'id': '1',
        //   'status': 'done',
        //   'conversationModel': conversationModel.toPayload(),
        //   'isGroup': isGroup,
        //   'members': payloadFriends.map((e) => e.toPayload()).toList()
        // };
        // await sendNotification(
        //     element.fcmToken,
        //     isGroup ? conversationModel.name : MyAppState.currentUser!.fullName(),
        //     message.content,
        //     payload);
        // if (isGroup) {
        //   payloadFriends.remove(MyAppState.currentUser);
        //   payloadFriends.add(friend!);
        // }
      }
    });
  }

  Future<bool> createChatConversation(ConversationModel conversation) async {
    try {
      await firestore
          .collection(CONVERSATION)
          .doc(conversation.senderId)
          .collection(CONVERSATION)
          .doc(conversation.receiverId)
          .set(conversation.toJson());
      await firestore
          .collection(CONVERSATION)
          .doc(conversation.receiverId)
          .collection(CONVERSATION)
          .doc(conversation.senderId)
          .set(conversation.toJson());
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<bool> markConversationAsRead(ConversationModel conversation) async {
    try {
      await firestore
          .collection(CONVERSATION)
          .doc(conversation.senderId)
          .collection(CONVERSATION)
          .doc(conversation.receiverId)
          .update({'isRead': true});
      await firestore
          .collection(CONVERSATION)
          .doc(conversation.receiverId)
          .collection(CONVERSATION)
          .doc(conversation.senderId)
          .update({'isRead': true});
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<bool> markMessageAsRead(ConversationModel conversation) async {
    try {
      QuerySnapshot<Map<String, dynamic>> result = await firestore
          .collection(CHANNELS)
          .doc(conversation.id)
          .collection(THREAD)
          .where('isRead', isEqualTo: false)
          .get();
      await Future.forEach(result.docs, (DocumentSnapshot message) {
        message.reference.update({'isRead': true});
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<ConversationModel?> getSingleConversation(String senderId, String receiverId) async {
    ConversationModel? conversationModel;
    try {
      DocumentSnapshot<Map<String, dynamic>> channel =
          await firestore.collection(CONVERSATION).doc(senderId).collection(CONVERSATION).doc(receiverId).get();
      if (channel.exists) {
        conversationModel = ConversationModel.fromJson(channel.data() ?? {});
      }
      return conversationModel;
    } on Exception catch (e) {
      throw e;
    }
  }

  HomeConversationModel homeConversation(ConversationModel participation, User user) {
    return HomeConversationModel(conversationModel: participation, members: [user]);
  }

  Stream<List<HomeConversationModel>> getChatConversations(String userID) async* {
    HomeConversationModel newHomeConversation;
    List<HomeConversationModel> homeConversations = [];

    Stream<QuerySnapshot> result = firestore.collection(CONVERSATION).doc(userID).collection(CONVERSATION).snapshots();
    _conversationsStreamSubscription = result.listen(
      (QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isEmpty) {
          conversationsStream.sink.add(homeConversations);
        } else {
          homeConversations.clear();
          await Future.forEach(querySnapshot.docs, (DocumentSnapshot document) async {
            if (document.exists) {
              ConversationModel participation = ConversationModel.fromJson(document.data() as Map<String, dynamic>);
              String userId = participation.receiverId != MyAppState.currentUser!.userID
                  ? participation.receiverId
                  : participation.senderId;
              User? user = await _userService.getCurrentUser(userId);
              newHomeConversation = homeConversation(participation, user!);
              homeConversations.add(newHomeConversation);
              homeConversations.sort(
                (a, b) => b.conversationModel!.lastMessageDate.compareTo(a.conversationModel!.lastMessageDate),
              );
              conversationsStream.sink.add(homeConversations.toList());
            }
          });
        }
      },
    );
    yield* conversationsStream.stream;
  }

  Future deleteChatMessage(ConversationModel conversation, String messageId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> result = await firestore
          .collection(CHANNELS)
          .doc(conversation.id)
          .collection(THREAD)
          .where('id', isEqualTo: messageId)
          .get();
      await Future.forEach(result.docs, (DocumentSnapshot message) {
        message.reference.update({'messageDeleted': true});
      });
      await firestore
          .collection(CONVERSATION)
          .doc(conversation.senderId)
          .collection(CONVERSATION)
          .doc(conversation.receiverId)
          .update({'messageDeleted': true});
      await firestore
          .collection(CONVERSATION)
          .doc(conversation.receiverId)
          .collection(CONVERSATION)
          .doc(conversation.senderId)
          .update({'messageDeleted': true});
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future updateUserOneUserTwoChat(String userOne, String userTwo) async {
    await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({
      'chat.userOne': userOne,
      'chat.userTwo': userTwo,
    });
    User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
    MyAppState.currentUser = user;
  }

  void disposeChatStream() {
    userStreamController.close();
    // chatModelStreamController.close();
  }
}
