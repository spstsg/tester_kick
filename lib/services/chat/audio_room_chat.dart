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
      await firestore
          .collection(AUDIO_ROOM_CHAT)
          .doc(conversation.id)
          .collection(AUDIO_ROOM_CHAT)
          .doc(uid)
          .set(conversation.toJson());
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  Stream<List<AudioChatRoomModel>> getAudioRoomMessages(String roomId) async* {
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

  void disposeAudioRoomMessageStream() {
    conversationsStream.close();
  }
}
