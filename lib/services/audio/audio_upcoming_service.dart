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

  // Stream<Room> getLiveRoom(String roomId) async* {
  //   Stream<QuerySnapshot> result = firestore.collection(AUDIO_LIVE_ROOMS).where('id', isEqualTo: roomId).snapshots();
  //
  //   singleLiveRoomStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
  //     await Future.forEach(querySnapshot.docs, (DocumentSnapshot room) {
  //       try {
  //         singleLiveRoomStream.sink.add(Room.fromJson(room.data() as Map<String, dynamic>));
  //       } catch (e) {
  //         throw e;
  //       }
  //     });
  //   });
  //   yield* singleLiveRoomStream.stream;
  // }
  //
  // Future checkUserLiveRooms() async {
  //   List<Room> _roomList = [];
  //   QuerySnapshot result = await firestore
  //       .collection(AUDIO_LIVE_ROOMS)
  //       .where('creator.username', isEqualTo: MyAppState.currentUser!.username)
  //       .where('status', isEqualTo: 'live')
  //       .get();
  //
  //   await Future.forEach(result.docs, (DocumentSnapshot post) {
  //     Room postModel = Room.fromJson(post.data() as Map<String, dynamic>);
  //     _roomList.add(postModel);
  //   });
  //   return _roomList;
  // }
  //
  Stream<List<UpcomingRoom>> getUpcomingRooms() async* {
    List<UpcomingRoom> upcomingRooms = [];
    Stream<QuerySnapshot> result = firestore
        .collection(UPCOMING_AUDIO_ROOMS)
        .orderBy('createdDate', descending: true)
        .snapshots();

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

  Future updateUpcomingRoom(UpcomingRoom room) async {
    await firestore.collection(UPCOMING_AUDIO_ROOMS).doc(room.id).update(room.toJson()).then(
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
