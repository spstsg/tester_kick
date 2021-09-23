import 'package:kick_chat/models/audio_chat_model.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';

class AppState {
  late User user;
  late Room selectedRoom;
  late Post createdPost;

  AppState({
    required this.user,
    required this.selectedRoom,
    required this.createdPost,
  });

  factory AppState.initialState() {
    return AppState(
      user: User(),
      selectedRoom: Room(),
      createdPost: Post(),
    );
  }

  AppState copyWith({
    User? user,
    Room? selectedRoom,
    Post? createdPost,
  }) {
    return AppState(
      user: user ?? this.user,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      createdPost: createdPost ?? this.createdPost,
    );
  }
}
