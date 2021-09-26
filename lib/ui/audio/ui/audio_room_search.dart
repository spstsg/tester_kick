// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_chat_model.dart';
// import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/search/search_service.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
// import 'package:kick_chat/ui/audio/ui/audio_room.dart';
// import 'package:permission_handler/permission_handler.dart';

class AudioRoomSearch extends StatefulWidget {
  const AudioRoomSearch({Key? key}) : super(key: key);

  @override
  _AudioRoomSearchState createState() => _AudioRoomSearchState();
}

class _AudioRoomSearchState extends State<AudioRoomSearch> {
  AudoChatService _audioChatService = AudoChatService();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  SearchService _searchService = SearchService();
  TextEditingController _searchController = TextEditingController();
  List<Room> rooms = [];
  bool hasParticipant = false;
  List roomParticipants = [];
  List roomSpeakers = [];
  List raisedHands = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              onChanged: (input) async {
                if (input.isNotEmpty) {
                  var roomList = await _searchService.searchLiveAudioRooms(input);
                  setState(() {
                    rooms = roomList;
                  });
                } else {
                  setState(() {
                    rooms = [];
                  });
                }
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.text = '';
                    setState(() {
                      rooms = [];
                    });
                  },
                ),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: StoreConnector<AppState, Room>(
        converter: (store) => store.state.selectedRoom,
        builder: (context, storeSelectedRoom) {
          return Container(
            child: Visibility(
              visible: rooms.isNotEmpty,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  SchedulerBinding.instance!.addPostFrameCallback((_) {
                    _audioChatService.getLiveRoom(rooms[index].id).listen((event) {
                      roomParticipants = [...event.participants];
                      roomSpeakers = [...event.speakers];
                      raisedHands = [...event.raisedHands];
                    });
                  });
                  return Container(
                    margin: EdgeInsets.only(left: 10, right: 20),
                    child: searchResults(rooms[index], storeSelectedRoom),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget searchResults(Room room, Room storeSelectedRoom) {
    var result = room.participants.where((participant) => participant['username'] == MyAppState.currentUser!.username);
    hasParticipant = result.isNotEmpty ? true : false;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(top: 10, left: 10),
          title: Row(
            children: [
              Text(
                truncateString(room.title, 33),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ColorPalette.black,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              children: [
                for (var tag in room.tags)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.0,
                      vertical: 1.0,
                    ),
                    margin: EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Tooltip(
                      message: tag,
                      preferBelow: false,
                      child: Text(
                        '#${truncateString(tag, 10)}',
                        style: TextStyle(color: ColorPalette.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              // ClientRole role;
              // if (room.creator.username == MyAppState.currentUser!.username) {
              //   role = ClientRole.Broadcaster;
              // } else {
              //   role = ClientRole.Audience;
              // }
              // audioCardOnPressed(
              //   storeSelectedRoom,
              //   room,
              //   role,
              // );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: !hasParticipant ? ColorPalette.primary : Colors.blue.shade200,
              textStyle: TextStyle(
                color: !hasParticipant ? ColorPalette.primary : Colors.blue.shade200,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: !hasParticipant ? ColorPalette.primary : Colors.blue.shade200,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Text(
              !hasParticipant ? 'JOIN' : 'JOINED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  // audioCardOnPressed(storeSelectedRoom, liveAudioRoom, ClientRole role) async {
  //   String roomCreatorId = await _sharedPreferences.getSharedPreferencesString('roomCreatorId');
  //   String selectedRoomId = await _sharedPreferences.getSharedPreferencesString('roomId');
  //   if (roomCreatorId == MyAppState.currentUser!.userID && selectedRoomId != liveAudioRoom.id) {
  //     await showCupertinoAlert(
  //       context,
  //       'Message',
  //       'You have to end your active room before you can join another room',
  //       'OK',
  //       '',
  //       false,
  //     );
  //     return;
  //   }

  //   removeUserFromRoom(storeSelectedRoom.participants, roomCreatorId, selectedRoomId);

  //   var participants = liveAudioRoom.participants;
  //   var result = participants
  //       .where((participant) => participant['username'] == MyAppState.currentUser!.username);
  //   hasParticipant = result.isNotEmpty ? true : false;
  //   Room room = Room(
  //     id: liveAudioRoom.id,
  //     title: liveAudioRoom.title,
  //     tags: liveAudioRoom.tags,
  //     creator: liveAudioRoom.creator,
  //     status: liveAudioRoom.status,
  //     channel: liveAudioRoom.channel,
  //     speakers: liveAudioRoom.speakers,
  //     participants: liveAudioRoom.participants,
  //     startTime: liveAudioRoom.startTime,
  //     endTime: liveAudioRoom.endTime,
  //   );
  //   await [Permission.microphone].request();
  //   if (!hasParticipant) {
  //     var newParticipants = {
  //       'id': MyAppState.currentUser!.userID,
  //       'username': MyAppState.currentUser!.username,
  //       'avatarColor': MyAppState.currentUser!.avatarColor,
  //       'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
  //     };
  //     room.participants.add(newParticipants);
  //     MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));

  //     _audioChatService.addParticipants(
  //       liveAudioRoom.id,
  //       newParticipants,
  //     );

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => AudioRoomScreen(
  //           room: liveAudioRoom,
  //           role: role,
  //         ),
  //       ),
  //     );
  //   } else {
  //     MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => AudioRoomScreen(
  //           room: liveAudioRoom,
  //           role: role,
  //         ),
  //       ),
  //     );
  //   }
  // }

  removeUserFromRoom(List participants, String roomCreatorId, String selectedRoomId) {
    var user = participants.where((participant) => participant['username'] == MyAppState.currentUser!.username);

    if (user.isNotEmpty && roomCreatorId != MyAppState.currentUser!.userID) {
      _audioChatService.removeSpeaker(selectedRoomId);
      _audioChatService.removeParticipant(
        roomCreatorId,
        selectedRoomId,
      );
      _sharedPreferences.deleteSharedPreferencesItem('roomId');
      _sharedPreferences.deleteSharedPreferencesItem('roomCreatorId');
    }
  }
}
