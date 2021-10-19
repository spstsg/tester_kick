import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';

class UserService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot> _userStreamSubscription;
  StreamController<User> _userStream = StreamController<User>();
  StreamSubscription<QuerySnapshot>? _usersStreamSubscription;
  StreamController<List<User>> _usersStream = StreamController<List<User>>();
  // ignore: avoid_init_to_null
  late dynamic lastDocument = null;

  Stream<User> getCurrentUserStream(String userID) async* {
    Stream<QuerySnapshot> result = firestore.collection(USERS).where('id', isEqualTo: userID).snapshots();

    _userStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot user) {
        try {
          User userModel = User.fromJson(user.data() as Map<String, dynamic>);
          if (!userModel.deleted) {
            _userStream.sink.add(userModel);
          }
        } catch (e) {
          throw e;
        }
      });
    }, cancelOnError: true);
    yield* _userStream.stream;
  }

  Stream<List<User>> getUsersStream(int limit) async* {
    List<User> _usersList = [];
    Stream<QuerySnapshot> result;
    if (lastDocument == null) {
      result = firestore.collection(USERS).limit(limit).snapshots();
    } else {
      result = firestore.collection(USERS).startAfterDocument(lastDocument).limit(limit).snapshots();
    }

    _usersStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      _usersList.clear();
      lastDocument = null;
      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      }
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot user) {
        User userModel = User.fromJson(user.data() as Map<String, dynamic>);
        if (!userModel.deleted) {
          _usersList.add(userModel);
        }
      });
      _usersStream.sink.add(_usersList);
    }, cancelOnError: true);
    yield* _usersStream.stream;
  }

  Future<List<User>> getUsers(int limit) async {
    List<User> _usersList = [];
    QuerySnapshot result;
    if (lastDocument == null) {
      result = await firestore.collection(USERS).limit(limit).get();
    } else {
      result = await firestore.collection(USERS).startAfterDocument(lastDocument).limit(limit).get();
    }

    if (result.docs.isNotEmpty) {
      lastDocument = result.docs[result.docs.length - 1];
    }
    await Future.forEach(result.docs, (DocumentSnapshot user) {
      User userModel = User.fromJson(user.data() as Map<String, dynamic>);
      if (!userModel.deleted) {
        _usersList.add(userModel);
      }
    });
    return _usersList;
  }

  Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot userDocument = await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      User user = User.fromJson(userDocument.data() as Map<String, dynamic>);
      if (!user.deleted) {
        return user;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<User?> updateCurrentUser(User user) async {
    return await firestore.collection(USERS).doc(user.userID).set(user.toJson()).then((document) {
      return user;
    });
  }

  Future<User?> updateCurrentUsername(String username) async {
    try {
      await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({'username': username});
    } catch (e) {
      throw e;
    }
  }

  Future<User?> updateDeleteProp(bool deleted) async {
    try {
      await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({'deleted': deleted});
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateDefaultImageProp(bool defaultImage) async {
    await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({'defaultImage': defaultImage});
    User? user = await getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
  }

  Future<void> updatePushNotificationSetting(bool notification) async {
    await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({
      'settings.notifications': notification,
    });
    User? user = await getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
  }

  Future<void> updateNotificationType(String type, bool notification) async {
    await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update({
      'notifications.${type}': notification,
    });
    User? user = await getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
  }

  void disposeCurrentUserStream() {
    _userStream.close();
    _userStreamSubscription.cancel();
  }

  void disposeUsersStream() {
    _usersStream.close();
    if (_usersStreamSubscription != null) {
      _usersStreamSubscription!.cancel();
    }
  }
}
