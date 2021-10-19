import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/livescores_chat_model.dart';
import 'package:kick_chat/services/helper.dart';

class LiveScoresChat {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamController<List<LivescoresModel>> conversationsStream;

  Future<bool> addLivescoresMessages(LivescoresModel conversation) async {
    try {
      String uid = getRandomString(20);
      Map<String, dynamic> data = conversation.toJson();
      data.removeWhere((key, value) => value == null);
      await firestore.collection(LIVESCORES_CHAT).doc(conversation.id).collection(LIVESCORES_CHAT).doc(uid).set(data);
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Stream<List<LivescoresModel>> getLiveScoreMessagesStream(String teamId) async* {
    conversationsStream = StreamController<List<LivescoresModel>>();
    List<LivescoresModel> messages = [];
    firestore
        .collection(LIVESCORES_CHAT)
        .doc(teamId)
        .collection(LIVESCORES_CHAT)
        .orderBy('lastMessageDate')
        .snapshots()
        .listen(
      (querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          conversationsStream.sink.add([]);
        } else {
          messages.clear();
          Future.forEach(
            querySnapshot.docs,
            (DocumentSnapshot document) async {
              if (document.exists) {
                LivescoresModel messageJson = LivescoresModel.fromJson(document.data() as Map<String, dynamic>);
                messages.add(messageJson);

                conversationsStream.sink.add(messages);
              }
            },
          );
        }
      },
    );
    yield* conversationsStream.stream;
  }

  Future<List<LivescoresModel>> getLiveScoreMessages(String teamId) async {
    List<LivescoresModel> _chatList = [];
    QuerySnapshot result = await firestore
        .collection(LIVESCORES_CHAT)
        .doc(teamId)
        .collection(LIVESCORES_CHAT)
        .orderBy('lastMessageDate')
        .get();

    await Future.forEach(result.docs, (DocumentSnapshot chat) async {
      LivescoresModel chatModel = LivescoresModel.fromJson(chat.data() as Map<String, dynamic>);
      _chatList.add(chatModel);
    });
    return _chatList;
  }

  void disposeMessageStream() {
    conversationsStream.close();
  }
}
