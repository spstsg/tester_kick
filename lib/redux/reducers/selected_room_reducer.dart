import 'package:kick_chat/models/audio_chat_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:redux/redux.dart';

final selectedRoomReducer = combineReducers<Room>([
  TypedReducer<Room, CreateSelectedRoomAction>(_addSelectedRoomSuccess),
]);

Room _addSelectedRoomSuccess(Room state, CreateSelectedRoomAction action) {
  return state.copyWith(
    id: action.selectedRoom.id,
    title: action.selectedRoom.title,
    tags: action.selectedRoom.tags,
    creator: action.selectedRoom.creator,
    speakers: action.selectedRoom.speakers,
    participants: action.selectedRoom.participants,
    raisedHands: action.selectedRoom.raisedHands,
    createdDate: action.selectedRoom.createdDate,
    roomStarted: action.selectedRoom.roomStarted,
    status: action.selectedRoom.status,
    channel: action.selectedRoom.channel,
    startTime: action.selectedRoom.startTime,
    endTime: action.selectedRoom.endTime,
    newEndTime: action.selectedRoom.newEndTime,
    newRoomStarted: action.selectedRoom.newRoomStarted,
  );
}
