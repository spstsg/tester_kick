import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/models/audio_room_chat_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/services/audio/agora_service.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/chat/audio_room_chat.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/services/time/timer_service.dart';
import 'package:kick_chat/ui/audio/ui/edit_audio_room.dart';
import 'package:kick_chat/ui/audio/ui/room_discussion.dart';
import 'package:kick_chat/ui/audio/widgets/audio_room_single_skeleton.dart';
import 'package:kick_chat/ui/audio/widgets/room_user_profile.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// ignore: must_be_immutable
class AudioRoomScreen extends StatefulWidget {
  Room room;
  final ClientRole role;
  AudioRoomScreen({required this.room, required this.role});

  @override
  AudioRoomScreenState createState() => AudioRoomScreenState();
}

class AudioRoomScreenState extends State<AudioRoomScreen> {
  AudoChatService _audioChatService = AudoChatService();
  AudioRoomChatService _audioChatRoomService = AudioRoomChatService();
  AgoraService _agoraService = AgoraService();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  late Stream<List<AudioChatRoomModel>> _audioChatMessageStream;
  List raisedHands = [];
  List speakers = [];
  List participants = [];
  bool isHandRaised = false;
  bool userHandRaised = false;
  bool muted = true;
  late int localUid;
  static late RtcEngine engine;
  String agoraAppId = dotenv.get('AGORA_APP_ID');
  TimerService timerService = TimerService();
  TextEditingController _messageController = new TextEditingController();

  @override
  void initState() {
    _audioChatMessageStream = _audioChatRoomService.getAudioRoomMessages(widget.room.id);
    MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(Room()));
    raisedHands = widget.room.raisedHands;
    participants = widget.room.participants;

    Room selectedRoomState = MyAppState.reduxStore!.state.selectedRoom;
    setParticipantsState(selectedRoomState);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _audioChatService.getLiveRoom(widget.room.id).listen((event) {
        widget.room = event;
        if (event.id == widget.room.id && event.status == 'ended') {
          push(context, NavScreen(tabIndex: 1));
          return;
        }
        setParticipantsState(event);
      });
    });
    super.initState();

    initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    timerService.stop();
    timerService.reset();
    _audioChatService.disposeSingLiveStream();
    _audioChatRoomService.disposeAudioRoomMessageStream();
    removeUserFromRaisedHands();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timerService.start();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorPalette.white,
        leadingWidth: 80.0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_down,
            size: 30,
            color: ColorPalette.primary,
          ),
          onPressed: () async {
            removeSpeaker();
            await _sharedPreferences.setSharedPreferencesString('roomId', widget.room.id);
            await _sharedPreferences.setSharedPreferencesString(
              'roomCreatorId',
              widget.room.creator.userID,
            );
            push(
              context,
              NavScreen(tabIndex: 1)
            );
          },
        ),
        actions: [
          appBarActions(),
          Visibility(
            visible: widget.room.creator.userID == MyAppState.currentUser!.userID,
            child: PopupMenuButton(
              padding: EdgeInsets.all(0),
              icon: Icon(
                MdiIcons.dotsVertical,
                color: ColorPalette.primary,
              ),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return new EditRoomFormDialog(room: widget.room);
                            },
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        MdiIcons.pencil,
                        color: ColorPalette.primary,
                      ),
                      title: Text(
                        'Edit room',
                        style: TextStyle(
                          fontSize: 18,
                          color: ColorPalette.black,
                        ),
                      ),
                    ),
                  )
                ];
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          widget.room.creator.userID == MyAppState.currentUser!.userID ? roomInfo() : SizedBox.shrink(),
          Center(
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: timerService,
                builder: (context, child) {
                  return Text(
                    '${formatTime(timerService.currentDuration.inMilliseconds)}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          participantsWidget()
        ],
      ),
      bottomSheet: Container(
        height: 155.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<List<AudioChatRoomModel>>(
                  stream: _audioChatMessageStream,
                  initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return AudioRoomSingleSkeleton();
                    } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                      return Container(
                        child: Center(
                          child: Text('No conversations yet'),
                        ),
                      );
                    } else {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            new MaterialPageRoute<Null>(
                              builder: (BuildContext context) {
                                return new RoomDiscussion(room: widget.room);
                              },
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        leading: Container(
                          width: 40.0,
                          height: 40.0,
                          child: CircleAvatar(
                            child: ClipOval(
                              child: Image(
                                height: 40.0,
                                width: 40.0,
                                image: NetworkImage(snapshot.data!.last.profilePicture),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                snapshot.data!.last.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Icon(
                                MdiIcons.chevronRight,
                                size: 30,
                              ),
                            )
                          ],
                        ),
                        subtitle: Text(
                          truncateString(snapshot.data!.last.lastMessage, 40),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      );
                    }
                  }),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    hintText: 'Add to the discussion',
                    suffixIcon: Container(
                      margin: EdgeInsets.only(right: 15.0),
                      width: 35.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          primary: Colors.white,
                        ),
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(widget.room.id, _messageController.text);
                            _messageController.clear();
                            setState(() {});
                          }
                        },
                        child: Icon(
                          Icons.send,
                          size: 25.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _sendMessage(String roomId, String message) async {
    User user = MyAppState.currentUser!;
    AudioChatRoomModel conversation = AudioChatRoomModel(
      id: roomId,
      lastMessageDate: Timestamp.now(),
      lastMessage: _messageController.text,
      senderId: user.userID,
      username: user.username,
      profilePicture: user.profilePictureURL,
    );
    bool isSuccessful = await _audioChatRoomService.addAudioRoomMessage(conversation);
    if (isSuccessful) {
      setState(() {});
    }
    return isSuccessful;
  }

  Future<void> initialize() async {
    var role = '';
    if (widget.role == ClientRole.Audience) {
      role = 'subscriber';
    } else {
      role = 'publisher';
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    var result = await _agoraService.getToken(widget.room.channel, role, 0);
    await engine.joinChannel(result, widget.room.channel, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    engine = await RtcEngine.create(agoraAppId.toString());
    await engine.disableVideo();
    await engine.enableAudio();
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await engine.setClientRole(widget.role);
    await engine.muteLocalAudioStream(muted);
  }

  void _addAgoraEventHandlers() {
    engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          print(code);
        },
        joinChannelSuccess: (channel, uid, elapsed) async {
          final info = 'onJoinChannel: $channel, uid: $uid';
          print(info);
        },
        leaveChannel: (stats) async {
          inspect('leaveChannel: $stats');
        },
        userJoined: (uid, elapsed) {
          print('userJoined: $uid - $elapsed');
        },
        userOffline: (uid, reason) {
          final info = 'userOffline: $uid , reason: $reason';
          print(info);
        },
        tokenPrivilegeWillExpire: (token) async {
          var role = '';
          if (widget.role == ClientRole.Audience) {
            role = 'subscriber';
          } else {
            role = 'publisher';
          }
          var result = await _agoraService.getToken(widget.room.channel, role, 0);
          await engine.renewToken(result);
        },
      ),
    );
  }

  setParticipantsState(Room selectedRoom) {
    setState(() {
      participants = selectedRoom.participants;
      raisedHands = selectedRoom.raisedHands;
      speakers = selectedRoom.speakers;
      var result = raisedHands.where((user) => user == MyAppState.currentUser!.username).toList();
      isHandRaised = result.isNotEmpty;
    });
  }

  checkIfUserRaisedHand(String username) {
    var result = raisedHands.where((username) => username == username).toList();
    return result.isNotEmpty;
  }

  muteAndUnmuteSpeaker(String username) {
    var result = speakers.where((user) => user['username'] == username).toList();
    return result.isNotEmpty;
  }

  getUserRaisedHandIndex(String username) {
    int index = raisedHands.indexOf(username);
    if (index > -1) {
      return index + 1;
    } else {
      return 0;
    }
  }

  removeUserFromRaisedHands() async {
    await _audioChatService.removeUserFromRaisedHands(
      widget.room.id,
      MyAppState.currentUser!.username,
    );
  }

  void _onToggleMute() async {
    if (muted) {
      await addRoomSpeaker();
    } else {
      await removeSpeaker();
    }
  }

  addRoomSpeaker() async {
    var newSpeaker = {
      'id': MyAppState.currentUser!.userID,
      'username': MyAppState.currentUser!.username,
      'avatarColor': MyAppState.currentUser!.avatarColor,
      'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
    };
    Room room = Room(
      id: widget.room.id,
      title: widget.room.title,
      tags: widget.room.tags,
      creator: widget.room.creator,
      status: widget.room.status,
      channel: widget.room.channel,
      speakers: widget.room.speakers,
      participants: widget.room.participants,
      startTime: widget.room.startTime,
      endTime: widget.room.endTime,
    );
    room.speakers.add(newSpeaker);
    MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
    var result = await _audioChatService.addSpeakers(
      widget.room.id,
      newSpeaker,
    );
    if (result == null) {
      setState(() {
        muted = !muted;
        engine.muteLocalAudioStream(muted);
        if (!muted && widget.role == ClientRole.Audience) {
          engine.setClientRole(ClientRole.Broadcaster);
        }
      });
    } else {
      final snackBar = SnackBar(content: Text('Error unmuting yourself. Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  removeSpeaker() async {
    Room room = Room(
      id: widget.room.id,
      title: widget.room.title,
      tags: widget.room.tags,
      creator: widget.room.creator,
      status: widget.room.status,
      channel: widget.room.channel,
      speakers: widget.room.speakers,
      participants: widget.room.participants,
      startTime: widget.room.startTime,
      endTime: widget.room.endTime,
    );
    if (room.speakers.isNotEmpty) {
      room.speakers.removeWhere((speaker) => speaker['username'] == MyAppState.currentUser!.username);
    }
    MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
    var result = await _audioChatService.removeSpeaker(widget.room.id);
    if (result == null) {
      setState(() {
        muted = !muted;
        engine.muteLocalAudioStream(muted);
        if (!muted && widget.role == ClientRole.Audience) {
          engine.setClientRole(ClientRole.Broadcaster);
        }
      });
    } else {
      final snackBar = SnackBar(content: Text('Error muting yourself. Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  removeUserFromRoom(bool roomIsEnded) async {
    Room room = Room(
      id: widget.room.id,
      title: widget.room.title,
      tags: widget.room.tags,
      creator: widget.room.creator,
      status: widget.room.status,
      channel: widget.room.channel,
      speakers: widget.room.speakers,
      participants: widget.room.participants,
      startTime: widget.room.startTime,
      endTime: widget.room.endTime,
    );
    room.participants.removeWhere((participant) => participant['username'] == MyAppState.currentUser!.username);
    if (!roomIsEnded) {
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
    } else {
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(Room()));
    }
    var result = await Future.wait([
      _audioChatService.removeSpeaker(widget.room.id),
      _audioChatService.removeParticipant(
        widget.room.creator.userID,
        widget.room.id,
      )
    ]);
    if (result[0] == null && result[1] == null) {
      push(context, NavScreen(tabIndex: 1));
    } else {
      final snackBar = SnackBar(content: Text('Error leaving room. Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  String formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Widget appBarActions() {
    return Container(
      padding: EdgeInsets.only(
        right: widget.room.creator.userID == MyAppState.currentUser!.userID ? 0 : 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: 50),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                if (!isHandRaised) {
                  var result = await _audioChatService.addUserToRaisedHands(
                    widget.room.id,
                    MyAppState.currentUser!.username,
                  );
                  if (result != null) {
                    final snackBar = SnackBar(content: Text('Error raising hand. Try again'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                } else {
                  var result = await _audioChatService.removeUserFromRaisedHands(
                    widget.room.id,
                    MyAppState.currentUser!.username,
                  );
                  if (result != null) {
                    final snackBar = SnackBar(content: Text('Error removing hand. Try again'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHandRaised ? Colors.blue[300] : Colors.grey[300],
                ),
                child: Icon(
                  CupertinoIcons.hand_raised,
                  size: 25.0,
                  color: isHandRaised ? ColorPalette.white : ColorPalette.primary,
                ),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: _onToggleMute,
              child: Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(
                  muted ? CupertinoIcons.mic_off : CupertinoIcons.mic,
                  size: 25.0,
                  color: muted ? Colors.red : ColorPalette.primary,
                ),
              ),
            ),
            SizedBox(width: 20),
            widget.room.creator.username != MyAppState.currentUser!.username
                ? ElevatedButton(
                    onPressed: () async {
                      engine.leaveChannel();
                      _sharedPreferences.deleteSharedPreferencesItem('roomId');
                      _sharedPreferences.deleteSharedPreferencesItem('roomCreatorId');
                      removeUserFromRoom(false);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      primary: Colors.red,
                      textStyle: TextStyle(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Text(
                      'Leave',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget participantsWidget() {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  margin: EdgeInsets.only(top: 30, bottom: 20),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Text(
                        widget.room.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: ColorPalette.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              sliver: SliverGrid.count(
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.9,
                crossAxisCount: 4,
                children: participants
                    .map(
                      (data) => RoomUserProfile(
                        creatorName: widget.room.creator.username,
                        imageUrl: data['profilePictureURL'],
                        name: data['username'],
                        avatarColor: data['avatarColor'],
                        size: 60.0,
                        hasQueueNumber: checkIfUserRaisedHand(data['username']),
                        queueNumber: getUserRaisedHandIndex(data['username']),
                        isMuted: muteAndUnmuteSpeaker(data['username']),
                        onPressed: () {
                          participants.removeWhere(
                            (participant) => participant['username'] == data['username'],
                          );
                          widget.room.participants = participants;

                          MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(widget.room));

                          var participant = {
                            'id': data['id'],
                            'username': data['username'],
                            'avatarColor': data['avatarColor'],
                            'profilePictureURL': data['profilePictureURL'],
                          };

                          _audioChatService.removeParticipantToEndRoom(
                            widget.room.id,
                            participant,
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100.0)),
          ],
        ),
      ),
    );
  }

  Widget roomInfo() {
    return Row(children: [
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 15),
        child: ElevatedButton(
          onPressed: () async {
            var dialogResponse = await showCupertinoAlert(
              context,
              'Alert',
              'Do you really want to end this room?',
              'OK',
              'Cancel',
              '',
              true,
            );
            if (dialogResponse) {
              if (participants.length == 1 && participants[0]['username'] == MyAppState.currentUser!.username) {
                _sharedPreferences.deleteSharedPreferencesItem('roomId');
                _sharedPreferences.deleteSharedPreferencesItem('roomCreatorId');
                removeUserFromRoom(true);
                engine.leaveChannel();
                engine.destroy();
              } else {
                await showCupertinoAlert(
                  context,
                  'Alert',
                  'Sorry, you cannot end this room because there is still at least one other participant.',
                  'OK',
                  '',
                  '',
                  false,
                );
              }
            } else {
              return;
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 0.0,
            primary: ColorPalette.primary,
            textStyle: TextStyle(color: ColorPalette.primary),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: ColorPalette.primary),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Text(
            'End room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 180,
                  child: Text(
                    'Number of participants:',
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  '${participants.length}',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Container(
                  width: 180,
                  child: Text(
                    'Number of raised hands:',
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  '${raisedHands.length}',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
