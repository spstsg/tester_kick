import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/audio_room_chat_model.dart';
import 'package:kick_chat/services/helper.dart';

class AudioRoomChatService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamController<List<AudioChatRoomModel>> conversationsStream;

  Future<bool> addAudioRoomMessage(AudioChatRoomModel conversation) async {
    try {
      String uid = getRandomString(20);
      Map<String, dynamic> data = conversation.toJson();
      data.removeWhere((key, value) => value == null);
      await firestore.collection(AUDIO_ROOM_CHAT).doc(conversation.id).collection(AUDIO_ROOM_CHAT).doc(uid).set(data);
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Stream<List<AudioChatRoomModel>> getAudioRoomMessagesStream(String roomId) async* {
    conversationsStream = StreamController<List<AudioChatRoomModel>>();
    List<AudioChatRoomModel> messages = [];
    firestore
        .collection(AUDIO_ROOM_CHAT)
        .doc(roomId)
        .collection(AUDIO_ROOM_CHAT)
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
                AudioChatRoomModel messageJson = AudioChatRoomModel.fromJson(document.data() as Map<String, dynamic>);
                messages.add(messageJson);
                if (!conversationsStream.isClosed) {
                  conversationsStream.sink.add(messages);
                }
              }
            },
          );
        }
      },
    );
    yield* conversationsStream.stream;
  }

  Future<List<AudioChatRoomModel>> getAudioRoomMessages(String roomId) async {
    List<AudioChatRoomModel> _chatList = [];
    QuerySnapshot result = await firestore
        .collection(AUDIO_ROOM_CHAT)
        .doc(roomId)
        .collection(AUDIO_ROOM_CHAT)
        .orderBy('lastMessageDate')
        .get();

    await Future.forEach(result.docs, (DocumentSnapshot chat) async {
      AudioChatRoomModel chatModel = AudioChatRoomModel.fromJson(chat.data() as Map<String, dynamic>);
      _chatList.add(chatModel);
    });
    return _chatList;
  }

  void disposeAudioRoomMessageStream() {
    conversationsStream.close();
  }
}
