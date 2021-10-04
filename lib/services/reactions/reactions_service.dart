import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';

class ReactionService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  NotificationService notificationService = NotificationService();
  UserService _userService = UserService();

  Future<Map> getMyReactions(String postId) async {
    DocumentSnapshot<Map<String, dynamic>> result = await firestore
        .collection(SOCIAL_REACTIONS)
        .doc(postId)
        .collection(SOCIAL_REACTIONS)
        .doc(MyAppState.currentUser!.userID)
        .get();
    if (result.data() == null) {
      return {
        'angry': 0,
        'happy': 0,
        'wow': 0,
        'like': 0,
        'love': 0,
        'sad': 0,
      };
    }
    return {
      'angry': result.data()!['angry'],
      'happy': result.data()!['happy'],
      'wow': result.data()!['wow'],
      'like': result.data()!['like'],
      'love': result.data()!['love'],
      'sad': result.data()!['sad'],
    };
  }

  Future<bool> addPostReaction(Map reactions, Post post) async {
    try {
      await firestore
          .collection(SOCIAL_REACTIONS)
          .doc(post.id)
          .collection(SOCIAL_REACTIONS)
          .doc(MyAppState.currentUser!.userID)
          .set({
        'like': reactions['like'],
        'love': reactions['love'],
        'happy': reactions['happy'],
        'angry': reactions['angry'],
        'sad': reactions['sad'],
        'wow': reactions['wow'],
      });
      return true;
    } on Exception catch (e) {
      throw e;
    }
  }

  postReaction(Map reactions, String newReaction, Post post) async {
    await addPostReaction(reactions, post);

    DocumentReference<Map<String, dynamic>> updatePostDocument = firestore.collection(SOCIAL_POSTS).doc(post.id);
    updatePostDocument
        .update({'reactionsCount': FieldValue.increment(1), 'reactions.${newReaction}': FieldValue.increment(1)});

    User? user = await _userService.getCurrentUser(post.author.userID);
    if (user!.userID != MyAppState.currentUser!.userID) {
      await notificationService.saveNotification(
        'social_reaction',
        'reacted to your post.',
        user,
        MyAppState.currentUser!.username,
        {'outBound': MyAppState.currentUser!.toJson()},
      );

      if (user.settings.notifications && user.notifications['reactions']) {
        await notificationService.sendNotification(
          user.fcmToken,
          MyAppState.currentUser!.username,
          'reacted to your post.',
          null,
        );
      }
    }
  }

  void updateReaction(Map reactions, Post post, String newPostReaction, String previousReaction) async {
    DocumentReference<Map<String, dynamic>> updatePostDocument = firestore.collection(SOCIAL_POSTS).doc(post.id);
    updatePostDocument.update({
      'reactions.${newPostReaction}': FieldValue.increment(1),
      'reactions.$previousReaction': FieldValue.increment(-1),
    });
    await addPostReaction(reactions, post);
  }

  removeReaction(Post post, String previousReaction) async {
    DocumentSnapshot<Map<String, dynamic>> result = await firestore
        .collection(SOCIAL_REACTIONS)
        .doc(post.id)
        .collection(SOCIAL_REACTIONS)
        .doc(MyAppState.currentUser!.userID)
        .get();

    if (result.data() != null) {
      result.reference.delete();
      DocumentReference<Map<String, dynamic>> updatePostDocument = firestore.collection(SOCIAL_POSTS).doc(post.id);
      updatePostDocument.update({
        'reactionsCount': FieldValue.increment(-1),
        'reactions.$previousReaction': FieldValue.increment(-1),
      });
    }
  }

  dynamic updatePostReactionCount(data, type, value) {
    if (data[type] >= 0 && value > 0 || value < 0) {
      data[type] += value;
    }
    return data;
  }
}
