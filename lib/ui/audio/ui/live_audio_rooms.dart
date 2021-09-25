// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_chat_model.dart';
// import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
// import 'package:kick_chat/ui/audio/ui/audio_room.dart';
import 'package:kick_chat/ui/audio/ui/user_live_widget.dart';
import 'package:kick_chat/ui/audio/widgets/audio_card.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';
// import 'package:permission_handler/permission_handler.dart';

class LiveAudioRooms extends StatefulWidget {
  const LiveAudioRooms({Key? key}) : super(key: key);

  @override
  _LiveAudioRoomsState createState() => _LiveAudioRoomsState();
}

class _LiveAudioRoomsState extends State<LiveAudioRooms> {
  AudoChatService _audioChatService = AudoChatService();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  late Stream<List<Room>> _liveRoomsStream;
  bool hasParticipant = false;
  Room selectedRoom = Room();

  @override
  void initState() {
    _liveRoomsStream = _audioChatService.getLiveRooms();
    super.initState();
  }

  @override
  void dispose() {
    _audioChatService.disposeLiveRoomsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Room>(
      converter: (store) => store.state.selectedRoom,
      builder: (context, storeSelectedRoom) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          setState(() {
            selectedRoom = storeSelectedRoom;
          });
        });
        return Container(
          color: Colors.grey.shade200,
          height: double.infinity,
          child: StreamBuilder<List<Room>>(
            stream: _liveRoomsStream,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return PostSkeleton();
              } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: showEmptyState(
                        'No live audio rooms',
                        'All live rooms will show up here',
                      ),
                    );
                  },
                );
              } else {
                var liveAudioRooms = snapshot.data!.where((i) => i.status != 'ended').toList();
                if (liveAudioRooms.isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: showEmptyState(
                      'No live audio rooms',
                      'All live rooms will show up here',
                    ),
                  );
                }
                var result = storeSelectedRoom.participants
                    .where((participant) => participant['username'] == MyAppState.currentUser!.username);

                return Stack(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: ScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: liveAudioRooms.length,
                      itemBuilder: (BuildContext context, int index) {
                        // ClientRole role;
                        // if (liveAudioRooms[index].creator.username ==
                        //     MyAppState.currentUser!.username) {
                        //   role = ClientRole.Broadcaster;
                        // } else {
                        //   role = ClientRole.Audience;
                        // }

                        return AudioCard(
                          onPressed: () async {
                            // audioCardOnPressed(
                            //   storeSelectedRoom,
                            //   liveAudioRooms,
                            //   index,
                            //   role,
                            // );
                          },
                          room: liveAudioRooms[index],
                        );
                      },
                    ),
                    storeSelectedRoom.creator.username.isNotEmpty && result.isNotEmpty
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: UserLiveWidget(),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  // audioCardOnPressed(storeSelectedRoom, liveAudioRooms, int index, ClientRole role) async {
  //   String roomCreatorId = await _sharedPreferences.getSharedPreferencesString('roomCreatorId');
  //   String selectedRoomId = await _sharedPreferences.getSharedPreferencesString('roomId');
  //   if (roomCreatorId == MyAppState.currentUser!.userID &&
  //       selectedRoomId != liveAudioRooms[index].id) {
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

  //   var participants = liveAudioRooms[index].participants;
  //   var result = participants
  //       .where((participant) => participant['username'] == MyAppState.currentUser!.username);
  //   hasParticipant = result.isNotEmpty ? true : false;
  //   Room room = Room(
  //     id: liveAudioRooms[index].id,
  //     title: liveAudioRooms[index].title,
  //     tags: liveAudioRooms[index].tags,
  //     creator: liveAudioRooms[index].creator,
  //     status: liveAudioRooms[index].status,
  //     channel: liveAudioRooms[index].channel,
  //     speakers: liveAudioRooms[index].speakers,
  //     participants: liveAudioRooms[index].participants,
  //     startTime: liveAudioRooms[index].startTime,
  //     endTime: liveAudioRooms[index].endTime,
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
  //       liveAudioRooms[index].id,
  //       newParticipants,
  //     );

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => AudioRoomScreen(
  //           room: liveAudioRooms[index],
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
  //           room: liveAudioRooms[index],
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
