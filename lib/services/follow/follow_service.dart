import 'package:collection/collection.dart';

import 'package:kick_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';

class FollowService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  NotificationService _notificationService = NotificationService();
  UserService _userService = UserService();

  Future followUser(User currentUser, User visitedUser) async {
    try {
      User otherUser = User(
        userID: visitedUser.userID,
        username: visitedUser.username,
        profilePictureURL: visitedUser.profilePictureURL,
        avatarColor: visitedUser.avatarColor,
        fcmToken: visitedUser.fcmToken,
      );
      await firestore
          .collection(FOLLOWING)
          .doc(currentUser.userID)
          .collection(FOLLOWING)
          .doc(visitedUser.userID)
          .set(otherUser.toJson());
      DocumentReference<Map<String, dynamic>> incrementFollowingCount =
          firestore.collection(USERS).doc(MyAppState.currentUser!.userID);
      incrementFollowingCount.update({'followingCount': FieldValue.increment(1)});

      User current = User(
        userID: currentUser.userID,
        username: currentUser.username,
        profilePictureURL: currentUser.profilePictureURL,
        avatarColor: currentUser.avatarColor,
        fcmToken: currentUser.fcmToken,
      );

      await firestore
          .collection(FOLLOWERS)
          .doc(visitedUser.userID)
          .collection(FOLLOWERS)
          .doc(currentUser.userID)
          .set(current.toJson());

      DocumentReference<Map<String, dynamic>> incrementFollowersCount =
          firestore.collection(USERS).doc(visitedUser.userID);
      incrementFollowersCount.update({'followersCount': FieldValue.increment(1)});

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));

      await _notificationService.saveNotification(
        'follow_user',
        'started following you.',
        visitedUser,
        MyAppState.currentUser!.username,
        {'outBound': MyAppState.currentUser!.toJson()},
      );

      User? visitedUserData = await _userService.getCurrentUser(visitedUser.userID);
      if (visitedUserData!.settings.notifications && visitedUserData.notifications['followers']) {
        await _notificationService.sendNotification(
          visitedUserData.fcmToken,
          MyAppState.currentUser!.username,
          'started following you.',
          null,
        );
      }
    } catch (e) {
      throw e;
    }
  }

  Future unFollowUser(String currentUserId, String visitedUserId) async {
    try {
      await firestore
          .collection(FOLLOWING)
          .doc(currentUserId)
          .collection(FOLLOWING)
          .doc(visitedUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
          DocumentReference<Map<String, dynamic>> decrementFollowingCount =
              firestore.collection(USERS).doc(currentUserId);
          decrementFollowingCount.update({'followingCount': FieldValue.increment(-1)});
        }
      });

      await firestore
          .collection(FOLLOWERS)
          .doc(visitedUserId)
          .collection(FOLLOWERS)
          .doc(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
          DocumentReference<Map<String, dynamic>> decrementFollowersCount =
              firestore.collection(USERS).doc(visitedUserId);
          decrementFollowersCount.update({'followersCount': FieldValue.increment(-1)});
        }
      });

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
    } catch (e) {
      throw e;
    }
  }

  Future<bool> isFollowingUser(String currentUserId, String visitedUserId) async {
    try {
      DocumentSnapshot followingDoc =
          await firestore.collection(FOLLOWERS).doc(visitedUserId).collection(FOLLOWERS).doc(currentUserId).get();
      return followingDoc.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<List<User>> getUserFollowings(String userId) async {
    List<User> followings = [];

    QuerySnapshot userFollowing = await firestore.collection(FOLLOWING).doc(userId).collection(FOLLOWING).get();

    await Future.forEach(userFollowing.docs, (DocumentSnapshot actualFollowings) {
      followings.add(User.fromJson(actualFollowings.data() as Map<String, dynamic>));
    });
    return followings.toSet().toList();
  }

  Future<List<User>> getUserFollowers(String userId) async {
    List<User> followers = [];

    QuerySnapshot userFollowers = await firestore.collection(FOLLOWERS).doc(userId).collection(FOLLOWERS).get();

    await Future.forEach(userFollowers.docs, (DocumentSnapshot actualFollowers) {
      followers.add(User.fromJson(actualFollowers.data() as Map<String, dynamic>));
    });
    return followers.toSet().toList();
  }

  Future<List<User>> getUserFollowersWithRange(String userId) async {
    List<User> followers = [];
    QuerySnapshot userFollowers = await firestore.collection(FOLLOWERS).doc(userId).collection(FOLLOWERS).get();

    await Future.forEach(userFollowers.docs, (DocumentSnapshot actualFollowers) {
      followers.add(User.fromJson(actualFollowers.data() as Map<String, dynamic>));
    });
    List<User> items = getRandomUsersList(10, followers);
    return items;
  }

  List<User> getRandomUsersList(int n, List<User> source) => source.sample(n);
}
