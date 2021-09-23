import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/redux/reducers/created_post_reducer.dart';
import 'package:kick_chat/redux/reducers/selected_room_reducer.dart';
import 'package:kick_chat/redux/reducers/user_reducer.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    user: userReducer(state.user, action),
    selectedRoom: selectedRoomReducer(state.selectedRoom, action),
    createdPost: createdPostReducer(state.createdPost, action),
  );
}
