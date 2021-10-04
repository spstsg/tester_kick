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
  late StreamSubscription<QuerySnapshot> _profilePostsStreamSubscription;
  StreamController<List<Post>> _postsStream = StreamController.broadcast();

  Stream<List<Post>> getProfilePosts(String userID) async* {
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
        await Future.forEach(querySnapshot.docs, (DocumentSnapshot post) {
          try {
            _profilePosts.add(Post.fromJson(post.data() as Map<String, dynamic>));
          } catch (e) {
            print(e);
          }
        });
        _profilePostsStream.sink.add(_profilePosts);
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
      await Future.forEach(querySnapshot.docs, (DocumentSnapshot post) {
        Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
        _postsList.add(postModel);
      });
      _postsStream.sink.add(_postsList);
    });
    yield* _postsStream.stream;
  }

  Future<List<Post>> getPosts() async {
    List<Post> _postsList = [];
    QuerySnapshot result = await firestore.collection(SOCIAL_POSTS).orderBy('createdAt', descending: true).get();

    await Future.forEach(result.docs, (DocumentSnapshot post) {
      Post postModel = Post.fromJson(post.data() as Map<String, dynamic>);
      _postsList.add(postModel);
    });
    return _postsList;
  }

  Future<List<Comment>> getPostComments(Post post) async {
    List<Comment> _commentsList = [];
    QuerySnapshot result = await firestore.collection(POSTS_COMMENTS).where('postId', isEqualTo: post.id).get();
    await Future.forEach(result.docs, (DocumentSnapshot post) {
      try {
        Comment socialCommentModel = Comment.fromJson(post.data() as Map<String, dynamic>);
        _commentsList.add(socialCommentModel);
      } catch (e) {
        print('FireStoreUtils.getPostComments POST_COMMENTS table invalid json '
            'structure exception, doc id is => ${post.id}');
      }
    });
    return _commentsList;
  }

  publishPost(Post post) async {
    try {
      String uid = getRandomString(28);
      post.id = uid;
      await firestore.collection(SOCIAL_POSTS).doc(uid).set(post.toJson()).then((value) => null, onError: (e) {
        return e;
      });

      if (post.sharedPost.authorId != '') {
        DocumentReference<Map<String, dynamic>> incrementShareCount =
            firestore.collection(SOCIAL_POSTS).doc(post.sharedPost.id);
        incrementShareCount.update({'shareCount': FieldValue.increment(1)});

        User? author = await _userService.getCurrentUser(post.sharedPost.author.userID);
        if (author!.userID != MyAppState.currentUser!.userID) {
          await notificationService.saveNotification(
            'posts_shared',
            'shared your post.',
            author,
            MyAppState.currentUser!.username,
            {'outBound': MyAppState.currentUser!.toJson()},
          );

          if (author.settings.notifications && author.notifications['shared']) {
            await notificationService.sendNotification(
              author.fcmToken,
              MyAppState.currentUser!.username,
              'shared your post.',
              null,
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

  updatePost(Post post) async {
    var sharedPostId = post.sharedPost.id;
    if (post.sharedPost.authorId == '') {
      post.sharedPost = SharedPost();
    }
    await firestore
        .collection(SOCIAL_POSTS)
        .doc(post.id)
        .update(post.toJson())
        .then((value) => null, onError: (e) => e);

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

  deletePost(Post post) async {
    await firestore.collection(SOCIAL_POSTS).doc(post.id).delete();
    DocumentReference<Map<String, dynamic>> decrementPostCount = firestore.collection(USERS).doc(post.authorId);
    decrementPostCount.update({'postCount': FieldValue.increment(-1)});
    User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
    MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
    MyAppState.currentUser = user;
  }

  postComment(String uid, Comment newComment, Post post) async {
    DocumentReference commentDocument = firestore.collection(POSTS_COMMENTS).doc(uid);
    await commentDocument.set(newComment.toJson());
    DocumentReference<Map<String, dynamic>> incrementCommentsCount = firestore.collection(SOCIAL_POSTS).doc(post.id);
    incrementCommentsCount.update({'commentsCount': FieldValue.increment(1)});

    User? user = await _userService.getCurrentUser(post.author.userID);
    if (user!.userID != MyAppState.currentUser!.userID) {
      await notificationService.saveNotification(
        'posts_comments',
        'commented on your post.',
        user,
        MyAppState.currentUser!.username,
        {'outBound': MyAppState.currentUser!.toJson()},
      );

      if (user.settings.notifications && user.notifications['comments']) {
        await notificationService.sendNotification(
          user.fcmToken,
          MyAppState.currentUser!.username,
          'commented on your post.',
          null,
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
