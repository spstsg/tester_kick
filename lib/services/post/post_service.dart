import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/comment_model.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';

class PostService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  NotificationService notificationService = NotificationService();
  UserService _userService = UserService();
  late StreamSubscription<QuerySnapshot> _postsStreamSubscription;
  StreamController<List<Post>> _profilePostsStream = StreamController.broadcast();
  StreamController<List<Post>> postStream = StreamController.broadcast();
  late StreamSubscription<QuerySnapshot> _profilePostsStreamSubscription;
  StreamController<List<Post>> _postsStream = StreamController.broadcast();
  int postsCount = 0;
  // ignore: avoid_init_to_null
  late dynamic lastDocument = null;
  // ignore: avoid_init_to_null
  late dynamic lastStreamDocument = null;

  Stream<List<Post>> getProfilePostsStream(String userID) async* {
    List<Post> _profilePosts = [];
    _profilePostsStream = StreamController();
    Stream<QuerySnapshot> result = firestore
        .collection(SOCIAL_POSTS)
        .where('authorId', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .snapshots();

    _profilePostsStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      _profilePosts.clear();
      if (querySnapshot.docs.isEmpty) {
        _profilePostsStream.sink.add([]);
      } else {
        await Future.forEach(querySnapshot.docs, (DocumentSnapshot post) async {
          try {
            Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
            _profilePosts.add(postModel);
          } catch (e) {
            throw e;
          }
        });
        if (!_profilePostsStream.isClosed) {
          _profilePostsStream.sink.add(_profilePosts);
        }
      }
    }, cancelOnError: true);
    yield* _profilePostsStream.stream;
  }

  Stream<List<Post>> getPostsStream() async* {
    List<Post> _postsList = [];
    _postsStream = StreamController();
    Stream<QuerySnapshot> result =
        firestore.collection(SOCIAL_POSTS).orderBy('createdAt', descending: true).snapshots();

    _postsStreamSubscription = result.listen((QuerySnapshot querySnapshot) async {
      _postsList.clear();
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot post) async {
        Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
        _postsList.add(postModel);
      });
      if (!_postsStream.isClosed) {
        _postsStream.sink.add(_postsList);
      }
    });

    yield* _postsStream.stream;
  }

  getTotalPostCount() async {
    QuerySnapshot result = await firestore.collection(SOCIAL_POSTS).get();
    return result.size;
  }

  Future<List<Post>> getPosts(int limit) async {
    List<Post> _postsList = [];
    QuerySnapshot result;
    // QuerySnapshot result = await firestore.collection(SOCIAL_POSTS).orderBy('createdAt', descending: true).get();

    if (lastDocument == null) {
      result = await firestore.collection(SOCIAL_POSTS).limit(limit).orderBy('createdAt', descending: true).get();
    } else {
      result = await firestore
          .collection(SOCIAL_POSTS)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();
    }

    lastDocument = null;

    if (result.docs.isNotEmpty) {
      lastDocument = result.docs[result.docs.length - 1];
    }

    await Future.forEach(result.docs, (DocumentSnapshot post) async {
      Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
      _postsList.add(postModel);
    });
    return _postsList;
  }

  Future<List<Post>> getProfilePosts(String userID) async {
    List<Post> _postsList = [];
    QuerySnapshot result = await firestore
        .collection(SOCIAL_POSTS)
        .where('authorId', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .get();

    await Future.forEach(result.docs, (DocumentSnapshot post) async {
      Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
      _postsList.add(postModel);
    });
    return _postsList;
  }

  Future<Post> getSinglePost(String postId) async {
    List<Post> _postsList = [];
    QuerySnapshot result = await firestore.collection(SOCIAL_POSTS).where('id', isEqualTo: postId).get();

    await Future.forEach(result.docs, (DocumentSnapshot post) async {
      Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
      User? author = await _userService.getCurrentUser(postModel.authorId);
      if (author != null) {
        postModel.author = author;
        if (postModel.sharedPost.authorId.isNotEmpty) {
          User? sharedPostAuthor = await _userService.getCurrentUser(postModel.sharedPost.authorId);
          postModel.sharedPost.author = sharedPostAuthor;
        }
        _postsList.add(postModel);
      }
    });
    return _postsList[0];
  }

  Future<List<Comment>> getPostComments(Post post) async {
    List<Comment> _commentsList = [];
    QuerySnapshot result = await firestore.collection(POSTS_COMMENTS).where('postId', isEqualTo: post.id).get();
    await Future.forEach(result.docs, (DocumentSnapshot post) async {
      try {
        Comment socialCommentModel = Comment.fromJson(post.data() as Map<String, dynamic>);
        User? author = await _userService.getCurrentUser(socialCommentModel.authorId);
        socialCommentModel.author = author!;
        _commentsList.add(socialCommentModel);
      } catch (e) {
        throw e;
      }
    });
    return _commentsList;
  }

  Future publishPost(Post post) async {
    try {
      String uid = getRandomString(28);
      post.id = uid;
      Map<String, dynamic> data = post.toJson();
      data.removeWhere((key, value) => value == null);
      data['sharedPost'].removeWhere((key, value) => value == null);

      await firestore.collection(SOCIAL_POSTS).doc(uid).set(data).then((value) => null, onError: (e) {
        throw e;
      });

      if (post.sharedPost.authorId != '') {
        DocumentReference<Map<String, dynamic>> incrementShareCount =
            firestore.collection(SOCIAL_POSTS).doc(post.sharedPost.id);
        incrementShareCount.update({'shareCount': FieldValue.increment(1)});

        User? author = await _userService.getCurrentUser(post.sharedPost.authorId);
        if (author!.userID != MyAppState.currentUser!.userID) {
          await notificationService.saveNotification(
            'posts_shared',
            'shared your post.',
            author,
            MyAppState.currentUser!.username,
            {'outBound': MyAppState.currentUser!.toJson(), 'postId': post.id},
          );

          if (author.settings.notifications && author.notifications['shared']) {
            await notificationService.sendPushNotification(
              author.fcmToken,
              MyAppState.currentUser!.username,
              'shared your post.',
              {'type': 'shared', 'postId': post.id},
            );
          }
        }
      }

      DocumentReference<Map<String, dynamic>> incrementPostCount = firestore.collection(USERS).doc(post.authorId);
      incrementPostCount.update({'postCount': FieldValue.increment(1)});

      User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
      MyAppState.currentUser = user;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future updatePost(Post post) async {
    post.author = null;
    post.sharedPost.author = null;
    Map<String, dynamic> data = post.toJson();
    data.removeWhere((key, value) => value == null);
    data['sharedPost'].removeWhere((key, value) => value == null);
    var sharedPostId = post.sharedPost.id;
    if (post.sharedPost.authorId == '') {
      post.sharedPost = SharedPost();
    }
    await firestore.collection(SOCIAL_POSTS).doc(post.id).update(data).then((value) => null, onError: (e) => e);

    if (post.sharedPost.authorId == '' && sharedPostId != '') {
      DocumentReference<Map<String, dynamic>> decrementShareCount =
          firestore.collection(SOCIAL_POSTS).doc(sharedPostId);
      decrementShareCount.update({'shareCount': FieldValue.increment(-1)});
    }
  }

  void updateVideoViewCount(Post post) {
    int count = post.postVideo[0]['count'];
    count++;
    Map<String, dynamic> videoUrl = {
      'count': count,
      'url': post.postVideo[0]['url'],
      'videoThumbnail': post.postVideo[0]['videoThumbnail'],
      'mime': 'video',
    };
    DocumentReference<Map<String, dynamic>> increment = firestore.collection(SOCIAL_POSTS).doc(post.id);
    increment.update({
      'postVideo': [videoUrl]
    });
  }

  Future<void> deletePost(Post post) async {
    await firestore.collection(SOCIAL_POSTS).doc(post.id).delete();
    DocumentReference<Map<String, dynamic>> decrementPostCount = firestore.collection(USERS).doc(post.authorId);
    decrementPostCount.update({'postCount': FieldValue.increment(-1)});
    User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
    MyAppState.currentUser = user;
  }

  Future<void> postComment(String uid, Comment newComment, Post post) async {
    DocumentReference commentDocument = firestore.collection(POSTS_COMMENTS).doc(uid);
    Map<String, dynamic> data = newComment.toJson();
    data.removeWhere((key, value) => value == null);
    await commentDocument.set(data);
    DocumentReference<Map<String, dynamic>> incrementCommentsCount = firestore.collection(SOCIAL_POSTS).doc(post.id);
    incrementCommentsCount.update({'commentsCount': FieldValue.increment(1)});

    User? user = await _userService.getCurrentUser(post.authorId);
    if (user!.userID != MyAppState.currentUser!.userID) {
      await notificationService.saveNotification(
        'posts_comments',
        'commented on your post.',
        user,
        MyAppState.currentUser!.username,
        {
          'outBound': MyAppState.currentUser!.toJson(),
          'postId': post.id,
          'commentId': newComment.commentId,
        },
      );

      if (user.settings.notifications && user.notifications['comments']) {
        await notificationService.sendPushNotification(
          user.fcmToken,
          '${truncateString('${MyAppState.currentUser!.username} commented on your post', 40)}',
          '${truncateString(newComment.commentText, 40)}',
          {'type': 'comment', 'postId': post.id, 'commentId': newComment.commentId},
        );
      }
    }
  }

  void disposeProfilePostsStream() {
    _profilePostsStream.close();
    _profilePostsStreamSubscription.cancel();
  }

  void disposePostsStream() {
    _postsStream.close();
    _postsStreamSubscription.cancel();
  }
}
