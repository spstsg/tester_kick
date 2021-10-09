import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/services/user/user_service.dart';

class PollService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserService _userService = UserService();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  StreamController<List<PollModel>> userPollsStreamController = StreamController();
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _userPollStreamSubscription;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getPollStream(String pollId) {
    try {
      return firestore.collection(POLLS).doc(pollId).snapshots();
    } catch (e) {
      throw e;
    }
  }

  Future getPoll(String pollId) async {
    try {
      List<PollModel> _pollList = [];
      QuerySnapshot result = await firestore.collection(POLLS).where('pollId', isEqualTo: pollId).get();
      await Future.forEach(result.docs, (DocumentSnapshot poll) {
        PollModel pollModel = PollModel.fromJson(poll.data() as Map<String, dynamic>);
        _pollList.add(pollModel);
      });
      return _pollList[0];
    } catch (e) {
      throw e;
    }
  }

  Stream<List<PollModel>> getUserPolls(User user) async* {
    try {
      List<PollModel> _pollList = [];
      if (user.polls.isNotEmpty) {
        for (var poll in user.polls) {
          Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshotResult =
              firestore.collection(POLLS).doc(poll['poll']).snapshots();
          _userPollStreamSubscription = querySnapshotResult.listen(
            (DocumentSnapshot querySnapshot) async {
              if (!querySnapshot.exists) {
                userPollsStreamController.sink.add([]);
              } else {
                PollModel pollModel = PollModel.fromJson(querySnapshot.data() as Map<String, dynamic>);
                _pollList.add(pollModel);
                userPollsStreamController.sink.add(_pollList);
              }
            },
          );
        }
      }
      yield* userPollsStreamController.stream;
    } catch (e) {
      throw e;
    }
  }

  Future createPoll(PollModel poll) async {
    Map pollResult = {};
    for (var item in poll.answers) {
      pollResult['$item'] = 0;
    }
    try {
      poll.pollResultPercentage = pollResult;
      await firestore.collection(POLLS).doc(poll.pollId).set(poll.toJson());
      _sharedPreferences.setSharedPreferencesString('poll', poll.pollId);
    } catch (e) {
      throw e;
    }
  }

  Future updatePollAnswer(String pollId, String pollAnswer) async {
    try {
      Map userAnswersPoll = {
        'poll': pollId,
        'answer': pollAnswer,
      };
      await firestore.collection(POLLS).doc(pollId).update({
        'pollResultPercentage.${pollAnswer}': FieldValue.increment(1),
        'totalVotes': FieldValue.increment(1),
      });
      await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({
        'polls': FieldValue.arrayUnion([userAnswersPoll])
      });
      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
      MyAppState.currentUser = user;
    } catch (e) {
      throw e;
    }
  }

  Future endPoll(String pollId) async {
    try {
      await firestore.collection(POLLS).doc(pollId).update({
        'status': 'ended',
      });
      _sharedPreferences.deleteSharedPreferencesItem('poll');
    } catch (e) {
      throw e;
    }
  }

  void disposeUserPollStream() {
    userPollsStreamController.close();
    _userPollStreamSubscription.cancel();
  }
}
