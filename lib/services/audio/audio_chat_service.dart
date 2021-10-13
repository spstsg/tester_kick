import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';

class AudioChatService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamController<List<Room>> liveRoomsStream = StreamController();
  StreamController<Room> singleLiveRoomStream = StreamController();
  late StreamSubscription<QuerySnapshot> singleLiveRoomStreamSubscription;
  late StreamSubscription<QuerySnapshot> liveRoomsStreamSubscription;

  Stream<Room> getLiveRoom(String roomId) async* {
    Stream<QuerySnapshot> result = firestore.collection(AUDIO_LIVE_ROOMS).where('id', isEqualTo: roomId).snapshots();

    singleLiveRoomStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot room) {
        try {
          singleLiveRoomStream.sink.add(Room.fromJson(room.data() as Map<String, dynamic>));
        } catch (e) {
          throw e;
        }
      });
    });
    yield* singleLiveRoomStream.stream;
  }

  Future checkUserLiveRooms() async {
    List<Room> _roomList = [];
    QuerySnapshot result = await firestore
        .collection(AUDIO_LIVE_ROOMS)
        .where('creator.username', isEqualTo: MyAppState.currentUser!.username)
        .where('status', isEqualTo: 'live')
        .get();

    await Future.forEach(result.docs, (DocumentSnapshot post) {
      Room postModel = Room.fromJson(post.data() as Map<String, dynamic>);
      _roomList.add(postModel);
    });
    return _roomList;
  }

  Stream<List<Room>> getLiveRooms() async* {
    List<Room> liveRooms = [];
    Stream<QuerySnapshot> result =
        firestore.collection(AUDIO_LIVE_ROOMS).orderBy('createdDate', descending: true).snapshots();

    liveRoomsStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      liveRooms.clear();
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot room) {
        Room roomModel = Room.fromJson(room.data() as Map<String, dynamic>);
        liveRooms.add(roomModel);
      });
      liveRoomsStream.sink.add(liveRooms);
    });
    yield* liveRoomsStream.stream;
  }

  Future<Room> geSingleActiveRoom(String roomId) async {
    List<Room> activeRoom = [];
    QuerySnapshot result = await firestore.collection(AUDIO_LIVE_ROOMS).where('id', isEqualTo: roomId).get();

    await Future.forEach(result.docs, (DocumentSnapshot room) {
      try {
        activeRoom.add(Room.fromJson(room.data() as Map<String, dynamic>));
      } catch (e) {
        throw e;
      }
    });
    return activeRoom[0];
  }

  Future createLiveRoom(Room room) async {
    Room? liveRoom;
    String roomId = room.id;
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(room.id).set(room.toJson()).then(
      (value) async {
        await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).get().then((roomData) {
          if (roomData.exists) {
            liveRoom = Room.fromJson(roomData.data() ?? {});
          }
        }, onError: (e) {
          throw e;
        });
      },
      onError: (e) {
        print(e);
        throw e;
      },
    );
    return liveRoom;
  }

  Future updateLiveRoom(Room room) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(room.id).update(room.toJson()).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future addParticipants(String roomId, Map<String, dynamic> user) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
      'participants': FieldValue.arrayUnion([user])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future removeParticipant(String creatorId, String roomId) async {
    if (creatorId != MyAppState.currentUser!.userID) {
      await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
        'participants': FieldValue.arrayRemove([
          {
            'id': MyAppState.currentUser!.userID,
            'username': MyAppState.currentUser!.username,
            'avatarColor': MyAppState.currentUser!.avatarColor,
            'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
          }
        ])
      }).then(
        (value) => null,
        onError: (e) {
          throw e;
        },
      );
    } else {
      // await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).delete().then(
      //   (value) => null,
      //   onError: (e) {
      //     throw e;
      //   },
      // );
      await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({'status': 'ended'}).then(
        (value) => null,
        onError: (e) {
          throw e;
        },
      );
    }
  }

  Future removeParticipantToEndRoom(String roomId, Map participant) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
      'participants': FieldValue.arrayRemove([participant])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future addUserToRaisedHands(String roomId, String username) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
      'raisedHands': FieldValue.arrayUnion([username])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future removeUserFromRaisedHands(String roomId, String username) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
      'raisedHands': FieldValue.arrayRemove([username])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future addSpeakers(String roomId, Map<String, dynamic> user) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
      'speakers': FieldValue.arrayUnion([user])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future removeSpeaker(String roomId) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({
      'speakers': FieldValue.arrayRemove([
        {
          'id': MyAppState.currentUser!.userID,
          'username': MyAppState.currentUser!.username,
          'avatarColor': MyAppState.currentUser!.avatarColor,
          'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
        }
      ])
    }).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future updateRoomStartedDate(String roomId, String roomStarted) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({'roomStarted': roomStarted}).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  Future updateDate(String roomId, String key, String newEndTime) async {
    await firestore.collection(AUDIO_LIVE_ROOMS).doc(roomId).update({'$key': newEndTime}).then(
      (value) => null,
      onError: (e) {
        throw e;
      },
    );
  }

  void disposeLiveRoomsStream() {
    liveRoomsStream.close();
    liveRoomsStreamSubscription.cancel();
  }

  void disposeSingLiveStream() {
    singleLiveRoomStream.close();
    singleLiveRoomStreamSubscription.cancel();
  }
}
