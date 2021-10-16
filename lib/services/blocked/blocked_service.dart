import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/user/user_service.dart';

class BlockedUserService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserService _userService = UserService();

  Future<bool> blockUser(String currentUserId, String blockedUserId) async {
    try {
      await firestore
          .collection(BLOCKED)
          .doc(currentUserId)
          .collection(BLOCKED)
          .doc(blockedUserId)
          .set({'user': blockedUserId});

      await firestore
          .collection(BLOCKEDBY)
          .doc(blockedUserId)
          .collection(BLOCKEDBY)
          .doc(currentUserId)
          .set({'user': currentUserId});

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
      MyAppState.currentUser = user;
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> unblockUser(User currentUser, User blockedUser) async {
    try {
      await firestore
          .collection(BLOCKED)
          .doc(currentUser.userID)
          .collection(BLOCKED)
          .doc(blockedUser.userID)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      await firestore
          .collection(BLOCKEDBY)
          .doc(blockedUser.userID)
          .collection(BLOCKEDBY)
          .doc(currentUser.userID)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
      MyAppState.currentUser = user;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> validateIfUserBlocked(String blockedUserId) async {
    try {
      var blockedUser = await firestore
          .collection(BLOCKED)
          .doc(MyAppState.currentUser!.userID)
          .collection(BLOCKED)
          .doc(blockedUserId)
          .get();
      return blockedUser.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<List<User>> getBlockedUsers(String userId) async {
    List<User> blockedUsers = [];

    QuerySnapshot blocked = await firestore.collection(BLOCKED).doc(userId).collection(BLOCKED).get();

    await Future.forEach(blocked.docs, (DocumentSnapshot actualBlockedUser) async {
      Map<String, dynamic> usersBlocked = actualBlockedUser.data() as Map<String, dynamic>;
      User? user = await _userService.getCurrentUser(usersBlocked['user']);
      if (user != null) {
        blockedUsers.add(user);
      }
    });
    return blockedUsers.toSet().toList();
  }

  Future<List<User>> getBlockedByUsers(String userId) async {
    List<User> blockedByUsers = [];

    QuerySnapshot blockedBy = await firestore.collection(BLOCKEDBY).doc(userId).collection(BLOCKEDBY).get();

    await Future.forEach(blockedBy.docs, (DocumentSnapshot actualBlockedByUser) async {
      Map<String, dynamic> usersBlockedBy = actualBlockedByUser.data() as Map<String, dynamic>;
      User? user = await _userService.getCurrentUser(usersBlockedBy['user']);
      if (user != null) {
        blockedByUsers.add(user);
      }
    });
    return blockedByUsers.toSet().toList();
  }
}
