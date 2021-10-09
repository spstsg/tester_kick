import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:redux/redux.dart';

final userReducer = combineReducers<User>([
  TypedReducer<User, CreateUserAction>(_addUserSuccess),
]);

User _addUserSuccess(User state, CreateUserAction action) {
  return state.copyWith(
    username: action.user.username,
    lowercaseUsername: action.user.lowercaseUsername,
    email: action.user.email,
    password: action.user.password,
    userID: action.user.userID,
    uniqueId: action.user.uniqueId,
    profilePictureURL: action.user.profilePictureURL,
    phoneNumber: action.user.phoneNumber,
    active: action.user.active,
    emailPasswordLogin: action.user.emailPasswordLogin,
    lastOnlineTimestamp: action.user.lastOnlineTimestamp,
    settings: action.user.settings,
    fcmToken: action.user.fcmToken,
    dob: action.user.dob,
    avatarColor: action.user.avatarColor,
    postCount: action.user.postCount,
    bio: action.user.bio,
    team: action.user.team,
    lowercaseTeam: action.user.lowercaseTeam,
    followingCount: action.user.followingCount,
    followersCount: action.user.followersCount,
    defaultImage: action.user.defaultImage,
    notifications: action.user.notifications,
    chat: action.user.chat,
    polls: action.user.polls,
  );
}
