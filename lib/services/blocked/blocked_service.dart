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

  Future<bool> blockUser(User currentUser, User blockedUser) async {
    try {
      User otherUser = User(
        userID: blockedUser.userID,
        username: blockedUser.username,
        profilePictureURL: blockedUser.profilePictureURL,
        avatarColor: blockedUser.avatarColor,
        fcmToken: blockedUser.fcmToken,
      );
      await firestore
          .collection(BLOCKED)
          .doc(currentUser.userID)
          .collection(BLOCKED)
          .doc(blockedUser.userID)
          .set(otherUser.toJson());

      User current = User(
        userID: currentUser.userID,
        username: currentUser.username,
        profilePictureURL: currentUser.profilePictureURL,
        avatarColor: currentUser.avatarColor,
        fcmToken: currentUser.fcmToken,
      );

      await firestore
          .collection(BLOCKEDBY)
          .doc(blockedUser.userID)
          .collection(BLOCKEDBY)
          .doc(currentUser.userID)
          .set(current.toJson());

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
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

    await Future.forEach(blocked.docs, (DocumentSnapshot actualBlockedUser) {
      blockedUsers.add(User.fromJson(actualBlockedUser.data() as Map<String, dynamic>));
    });
    return blockedUsers.toSet().toList();
  }

  Future<List<User>> getBlockedByUsers(String userId) async {
    List<User> blockedByUsers = [];

    QuerySnapshot blockedBy = await firestore.collection(BLOCKEDBY).doc(userId).collection(BLOCKEDBY).get();

    await Future.forEach(blockedBy.docs, (DocumentSnapshot actualBlockedByUser) {
      blockedByUsers.add(User.fromJson(actualBlockedByUser.data() as Map<String, dynamic>));
    });
    return blockedByUsers.toSet().toList();
  }
}
