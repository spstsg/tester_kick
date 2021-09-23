import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/reactions_model.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';

class ReactionService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  NotificationService notificationService = NotificationService();

  Future<List<Reactions>> getMyReactions() async {
    List<Reactions> myReactions = [];
    QuerySnapshot result = await firestore
        .collection(SOCIAL_REACTIONS)
        .where('reactionAuthorId', isEqualTo: MyAppState.currentUser!.userID)
        .get();

    await Future.forEach(
      result.docs,
      (DocumentSnapshot reaction) => myReactions.add(
        Reactions.fromJson(reaction.data() as Map<String, dynamic>),
      ),
    );
    return myReactions;
  }

  String getReactionString(int id) {
    String reaction = 'like';
    switch (id) {
      case 1:
        reaction = 'like';
        break;
      case 2:
        reaction = 'love';
        break;
      case 3:
        reaction = 'wow';
        break;
      case 4:
        reaction = 'haha';
        break;
      case 5:
        reaction = 'sad';
        break;
      case 6:
        reaction = 'angry';
        break;
    }
    return reaction;
  }

  int getReactionIndex(String type) {
    int reaction = 1;
    switch (type) {
      case 'like':
        reaction = 1;
        break;
      case 'love':
        reaction = 2;
        break;
      case 'wow':
        reaction = 3;
        break;
      case 'haha':
        reaction = 4;
        break;
      case 'sad':
        reaction = 5;
        break;
      case 'angry':
        reaction = 6;
        break;
    }
    return reaction;
  }

  postReaction(Reactions newReaction, Post post) async {
    await firestore.collection(SOCIAL_REACTIONS).doc().set(newReaction.toJson());

    DocumentReference<Map<String, dynamic>> updatePostDocument =
        firestore.collection(SOCIAL_POSTS).doc(post.id);
    updatePostDocument.update({
      'reactionsCount': FieldValue.increment(1),
      'reactions.${newReaction.type}': FieldValue.increment(1)
    });

    await notificationService.saveNotification(
      'social_reaction',
      'Just reacted to your post.',
      post.author,
      MyAppState.currentUser!.username,
      {'outBound': MyAppState.currentUser!.toJson()},
    );

    if (post.author.settings.pushNewMessages) {
      await notificationService.sendNotification(
        post.author.fcmToken,
        MyAppState.currentUser!.username,
        'Reacted to your post.',
        null,
      );
    }
  }

  void updateReaction(Reactions postReaction, Post post, String previousReaction) async {
    QuerySnapshot result = await firestore
        .collection(SOCIAL_REACTIONS)
        .where('reactionAuthorId', isEqualTo: MyAppState.currentUser!.userID)
        .where('postId', isEqualTo: post.id)
        .get();
    if (result.docs.isNotEmpty) {
      DocumentReference<Map<String, dynamic>> updatePostDocument =
          firestore.collection(SOCIAL_POSTS).doc(postReaction.postId);
      updatePostDocument.update({
        'reactions.${postReaction.type}': FieldValue.increment(1),
        'reactions.$previousReaction': FieldValue.increment(-1),
      });
      await firestore
          .collection(SOCIAL_REACTIONS)
          .doc(result.docs.first.id)
          .update(postReaction.toJson());
    }
  }

  removeReaction(Post post, String previousReaction) async {
    QuerySnapshot querySnapshot = await firestore
        .collection(SOCIAL_REACTIONS)
        .where('postId', isEqualTo: post.id)
        .where('reactionAuthorId', isEqualTo: MyAppState.currentUser!.userID)
        .get();
    if (querySnapshot.docs.first.exists) {
      await firestore.collection(SOCIAL_REACTIONS).doc(querySnapshot.docs.first.id).delete();

      DocumentReference<Map<String, dynamic>> updatePostDocument =
          firestore.collection(SOCIAL_POSTS).doc(post.id);
      updatePostDocument.update({
        'reactionsCount': FieldValue.increment(-1),
        'reactions.$previousReaction': FieldValue.increment(-1)
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
