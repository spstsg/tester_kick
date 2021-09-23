import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/user_model.dart';

class UserService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot> _userStreamSubscription;
  StreamController<User> _userStream = StreamController<User>();
  StreamSubscription<QuerySnapshot>? _usersStreamSubscription;
  StreamController<List<User>> _usersStream = StreamController<List<User>>();
  // ignore: avoid_init_to_null
  late dynamic lastDocument = null;

  Stream<User> getCurrentUserStream(String userID) async* {
    Stream<QuerySnapshot> result =
        firestore.collection(USERS).where('id', isEqualTo: userID).snapshots();

    _userStreamSubscription =
        result.listen((QuerySnapshot querySnapshot) async {
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot user) {
        try {
          _userStream.sink
              .add(User.fromJson(user.data() as Map<String, dynamic>));
        } catch (e) {
          print(e);
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
      result = firestore
          .collection(USERS)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .snapshots();
    }

    _usersStreamSubscription =
        result.listen((QuerySnapshot querySnapshot) async {
      _usersList.clear();
      lastDocument = null;
      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      }
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot user) {
        _usersList.add(User.fromJson(user.data() as Map<String, dynamic>));
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
      result = await firestore
          .collection(USERS)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();
    }

    if (result.docs.isNotEmpty) {
      lastDocument = result.docs[result.docs.length - 1];
    }
    await Future.forEach(result.docs, (DocumentSnapshot user) {
      User userModel = User.fromJson(user.data() as Map<String, dynamic>);
      _usersList.add(userModel);
    });
    return _usersList;
  }

  Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot userDocument =
        await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return User.fromJson(userDocument.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<User?> updateCurrentUser(User user) async {
    return await firestore
        .collection(USERS)
        .doc(user.userID)
        .set(user.toJson())
        .then((document) {
      return user;
    });
  }

  Future<dynamic> getUserByUsername(String username) async {
    var userDocument = await FirebaseFirestore.instance
        .collection(USERS)
        .where('username', isEqualTo: username)
        .get();
    if (userDocument.docs.length >= 1) {
      return userDocument.docs.first;
    } else {
      return null;
    }
  }

  void disposeCurrentUserStream() {
    _userStream.close();
    _userStreamSubscription.cancel();
  }

  void disposeUsersStream() {
    _usersStream.close();
    _usersStreamSubscription!.cancel();
  }
}
