import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/redux/actions/created_post_action.dart';
import 'package:redux/redux.dart';

final createdPostReducer = combineReducers<Post>([
  TypedReducer<Post, CreatedPostAction>(_addCreatedPostSuccess),
]);

Post _addCreatedPostSuccess(Post state, CreatedPostAction action) {
  return state.copyWith(
    author: action.createdPost.author,
    id: action.createdPost.id,
    authorId: action.createdPost.authorId,
    username: action.createdPost.username,
    email: action.createdPost.email,
    avatarColor: action.createdPost.avatarColor,
    profilePicture: action.createdPost.profilePicture,
    post: action.createdPost.post,
    bgColor: action.createdPost.bgColor,
    gifUrl: action.createdPost.gifUrl,
    privacy: action.createdPost.privacy,
    commentsCount: action.createdPost.commentsCount,
    reactionsCount: action.createdPost.reactionsCount,
    createdAt: action.createdPost.createdAt,
    postMedia: action.createdPost.postMedia,
    postVideo: action.createdPost.postVideo,
    shareCount: action.createdPost.shareCount,
    sharedPost: action.createdPost.sharedPost,
    reactions: action.createdPost.reactions,
  );
}
