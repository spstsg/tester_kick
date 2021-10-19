import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/models/club_model.dart';
import 'package:kick_chat/models/user_model.dart';

class SearchService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<String>> searchClubs(String name) async {
    String searchTerm = name.toLowerCase();
    List<String> _clubList = [];
    QuerySnapshot clubs =
        await firestore.collection('england').where('lowercaseName', isGreaterThanOrEqualTo: searchTerm).get();

    await Future.forEach(clubs.docs, (DocumentSnapshot club) {
      Club clubModel = Club.fromJson(club.data() as Map<String, dynamic>);
      _clubList.add(clubModel.clubName);
    });
    return _clubList;
  }

  Future<List<User>> searchUsers(String name) async {
    String searchTerm = name.toLowerCase();
    List<User> _userList = [];
    QuerySnapshot users = await firestore
        .collection(USERS)
        .where('lowercaseUsername', isGreaterThanOrEqualTo: name)
        .where('lowercaseUsername', isLessThan: searchTerm + 'z')
        .get();

    Future.forEach(users.docs, (DocumentSnapshot user) {
      User userModel = User.fromJson(user.data() as Map<String, dynamic>);
      if (!userModel.deleted) {
        _userList.add(userModel);
      }
    });
    return _userList;
  }

  Future<List<Room>> searchLiveAudioRooms(String name) async {
    String searchTerm = name.toLowerCase();
    List<Room> _audioList = [];
    QuerySnapshot audios = await firestore.collection(AUDIO_LIVE_ROOMS).where('tags', arrayContains: searchTerm).get();

    Future.forEach(audios.docs, (DocumentSnapshot audio) {
      Room audioModel = Room.fromJson(audio.data() as Map<String, dynamic>);
      _audioList.add(audioModel);
    });
    return _audioList;
  }

  Future<List<User>> filterByClubName(String name) async {
    String searchTerm = name.toLowerCase();
    List<User> _usersList = [];
    QuerySnapshot result =
        await firestore.collection(USERS).where('lowercaseTeam', isGreaterThanOrEqualTo: searchTerm).get();
    await Future.forEach(result.docs, (DocumentSnapshot user) {
      User userModel = User.fromJson(user.data() as Map<String, dynamic>);
      if (!userModel.deleted) {
        _usersList.add(userModel);
      }
    });
    return _usersList;
  }
}
