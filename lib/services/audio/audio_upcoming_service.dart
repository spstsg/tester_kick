import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/audio_upcoming_room_model.dart';

class UpcomingAudioService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamController<List<UpcomingRoom>> upcomingRoomsStream = StreamController();
  StreamController<UpcomingRoom> singleLiveRoomStream = StreamController();
  late StreamSubscription<QuerySnapshot> singleLiveRoomStreamSubscription;
  late StreamSubscription<QuerySnapshot> upcomingRoomsStreamSubscription;

  Future<UpcomingRoom> getSingleUpcomingRoom(String roomId) async {
    List<UpcomingRoom> upcomingRoom = [];
    QuerySnapshot result = await firestore.collection(UPCOMING_AUDIO_ROOMS).where('id', isEqualTo: roomId).get();

    await Future.forEach(result.docs, (DocumentSnapshot room) {
      try {
        upcomingRoom.add(UpcomingRoom.fromJson(room.data() as Map<String, dynamic>));
      } catch (e) {
        throw e;
      }
    });
    return upcomingRoom[0];
  }

  Stream<List<UpcomingRoom>> getUpcomingRooms() async* {
    List<UpcomingRoom> upcomingRooms = [];
    Stream<QuerySnapshot> result =
        firestore.collection(UPCOMING_AUDIO_ROOMS).orderBy('scheduledDate', descending: true).snapshots();

    upcomingRoomsStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      upcomingRooms.clear();
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot room) {
        UpcomingRoom roomModel = UpcomingRoom.fromJson(room.data() as Map<String, dynamic>);
        upcomingRooms.add(roomModel);
      });
      upcomingRoomsStream.sink.add(upcomingRooms);
    });
    yield* upcomingRoomsStream.stream;
  }

  Future createUpcomingRoom(UpcomingRoom room) async {
    try {
      await firestore.collection(UPCOMING_AUDIO_ROOMS).doc(room.id).set(room.toJson());
    } catch (e) {
      throw e;
    }
  }

  Future addFcmTokens(String roomId, String token) async {
    await firestore.collection(UPCOMING_AUDIO_ROOMS).doc(roomId).update({
      'fcmTokens': FieldValue.arrayUnion([token])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future updateUpcomingRoom(UpcomingRoom room) async {
    await firestore.collection(UPCOMING_AUDIO_ROOMS).doc(room.id).update(room.toJson()).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future updateNotificationStatus(String roomId, String key) async {
    await firestore.collection(UPCOMING_AUDIO_ROOMS).doc(roomId).update({
      '${key}': true,
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  void disposeUpcomingRoomsStream() {
    upcomingRoomsStream.close();
    upcomingRoomsStreamSubscription.cancel();
  }

  void disposeSingLiveStream() {
    singleLiveRoomStream.close();
    singleLiveRoomStreamSubscription.cancel();
  }
}
