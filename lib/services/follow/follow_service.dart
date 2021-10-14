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

  Future followUser(String currentUserId, String visitedUserId) async {
    try {
      await firestore
          .collection(FOLLOWING)
          .doc(currentUserId)
          .collection(FOLLOWING)
          .doc(visitedUserId)
          .set({'user': visitedUserId});
      DocumentReference<Map<String, dynamic>> incrementFollowingCount =
          firestore.collection(USERS).doc(MyAppState.currentUser!.userID);
      incrementFollowingCount.update({'followingCount': FieldValue.increment(1)});

      await firestore
          .collection(FOLLOWERS)
          .doc(visitedUserId)
          .collection(FOLLOWERS)
          .doc(currentUserId)
          .set({'user': currentUserId});

      DocumentReference<Map<String, dynamic>> incrementFollowersCount = firestore.collection(USERS).doc(visitedUserId);
      incrementFollowersCount.update({'followersCount': FieldValue.increment(1)});

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
      MyAppState.currentUser = user;

      User? visitedUserData = await _userService.getCurrentUser(visitedUserId);

      if (visitedUserData!.userID != MyAppState.currentUser!.userID) {
        await _notificationService.saveNotification(
          'follow_user',
          'started following you.',
          visitedUserData,
          MyAppState.currentUser!.username,
          {'outBound': MyAppState.currentUser!.toJson(), 'userId': MyAppState.currentUser!.userID},
        );

        if (visitedUserData.settings.notifications && visitedUserData.notifications['followers']) {
          await _notificationService.sendPushNotification(
            visitedUserData.fcmToken,
            MyAppState.currentUser!.username,
            'started following you.',
            {'type': 'follow', 'userId': MyAppState.currentUser!.userID},
          );
        }
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
      MyAppState.currentUser = user;
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

    await Future.forEach(userFollowing.docs, (DocumentSnapshot actualFollowings) async {
      Map<String, dynamic> userFollowings = actualFollowings.data() as Map<String, dynamic>;
      User? user = await _userService.getCurrentUser(userFollowings['user']);
      followings.add(user!);
    });
    return followings.toSet().toList();
  }

  Future<List<User>> getUserFollowers(String userId) async {
    List<User> followers = [];

    QuerySnapshot userFollowers = await firestore.collection(FOLLOWERS).doc(userId).collection(FOLLOWERS).get();

    await Future.forEach(userFollowers.docs, (DocumentSnapshot actualFollowers) async {
      Map<String, dynamic> userFollowers = actualFollowers.data() as Map<String, dynamic>;
      User? user = await _userService.getCurrentUser(userFollowers['user']);
      followers.add(user!);
    });
    return followers.toSet().toList();
  }

  Future<List<User>> getUserFollowersWithRange(String userId) async {
    List<User> followers = [];
    QuerySnapshot userFollowers = await firestore.collection(FOLLOWERS).doc(userId).collection(FOLLOWERS).get();

    await Future.forEach(userFollowers.docs, (DocumentSnapshot actualFollowers) async {
      Map<String, dynamic> userFollowers = actualFollowers.data() as Map<String, dynamic>;
      User? user = await _userService.getCurrentUser(userFollowers['user']);
      followers.add(user!);
    });
    List<User> items = getRandomUsersList(10, followers);
    return items;
  }

  List<User> getRandomUsersList(int n, List<User> source) => source.sample(n);
}
