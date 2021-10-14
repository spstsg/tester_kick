import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/models/audio_upcoming_room_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/audio/audio_upcoming_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/audio/ui/audio_room.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class NotificationUpcomingRoom extends StatefulWidget {
  final UpcomingRoom upcomingRoom;
  const NotificationUpcomingRoom({Key? key, required this.upcomingRoom}) : super(key: key);

  @override
  State<NotificationUpcomingRoom> createState() => _NotificationUpcomingRoomState();
}

class _NotificationUpcomingRoomState extends State<NotificationUpcomingRoom> {
  UpcomingAudioService _upcomingAudioService = UpcomingAudioService();
  AudioChatService _audioChatService = AudioChatService();
  bool hasParticipant = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.greyWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Your room',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
      ),
      body: Container(
        color: Colors.grey.shade200,
        height: double.infinity,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: ScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              decoration: BoxDecoration(color: ColorPalette.greyWhite),
              child: Card(
                elevation: 1.0,
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: ColorPalette.grey, width: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: EdgeInsets.only(top: 12, bottom: 10, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.0,
                                vertical: 1.0,
                              ),
                              child: Text(
                                '${calculateDifference(widget.upcomingRoom.createdDate)},',
                                style: TextStyle(
                                  color: ColorPalette.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 1.0,
                              ),
                              width: MediaQuery.of(context).size.width * 0.47,
                              child: Text(
                                '${getTime(widget.upcomingRoom.createdDate)}',
                                style: TextStyle(
                                  color: ColorPalette.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var tag in widget.upcomingRoom.tags)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.blueAccent),
                                ),
                                child: Tooltip(
                                  message: tag,
                                  preferBelow: false,
                                  child: Text(
                                    '#${truncateString(tag, 10)}',
                                    style: TextStyle(color: ColorPalette.black),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Text(
                          widget.upcomingRoom.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: ColorPalette.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        child: Row(
                          children: [
                            ProfileAvatar(
                              imageUrl: widget.upcomingRoom.creator!.profilePictureURL,
                              username: widget.upcomingRoom.creator!.username,
                              avatarColor: widget.upcomingRoom.creator!.avatarColor,
                              radius: 22,
                              fontSize: 30,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Hosted by ${widget.upcomingRoom.creator!.username}',
                                style: TextStyle(
                                  color: ColorPalette.black,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (widget.upcomingRoom.creator!.userID == MyAppState.currentUser!.userID) {
                                  startLiveRoom(widget.upcomingRoom);
                                } else {
                                  addParticipantToRoom(widget.upcomingRoom);
                                }
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  widget.upcomingRoom.creator!.userID == MyAppState.currentUser!.userID
                                      ? 'START ROOM'
                                      : 'JOIN ROOM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                widget.upcomingRoom.description,
                                style: TextStyle(
                                  color: ColorPalette.grey,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String calculateDifference(String dateString) {
    var date = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    int days = DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    }
    final DateFormat format = DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  String getTime(String dateString) {
    var date = DateTime.parse(dateString);
    final DateFormat format = DateFormat('HH:m a');
    return format.format(date.toUtc().toLocal());
  }

  Future startLiveRoom(UpcomingRoom upcomingRoom) async {
    String title = upcomingRoom.title;
    List tags = upcomingRoom.tags;
    SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(
      context: context,
      barrierDimisable: false,
    );
    try {
      progressDialog(
        context,
        _dialog,
        SimpleFontelicoProgressDialogType.normal,
        'Starting room...',
      );
      await Future.delayed(Duration(seconds: 5));
      Room room = Room(
        id: upcomingRoom.id,
        title: title,
        tags: tags,
        creator: MyAppState.currentUser!,
        status: 'live',
        channel: getRandomString(10),
        participants: [
          {
            'id': MyAppState.currentUser!.userID,
            'username': MyAppState.currentUser!.username,
            'avatarColor': MyAppState.currentUser!.avatarColor,
            'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
          }
        ],
      );
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));

      var result = await _audioChatService.createLiveRoom(room);
      await Permission.microphone.request();
      if (result is Room) {
        upcomingRoom.status = true;
        _upcomingAudioService.updateUpcomingRoom(upcomingRoom);
        _dialog.hide();
        push(
          context,
          AudioRoomScreen(room: result, role: ClientRole.Broadcaster),
        );
      }
    } catch (e) {
      _dialog.hide();
      final snackBar = SnackBar(content: Text('Error starting room. Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future addParticipantToRoom(UpcomingRoom upcomingRoom) async {
    Room activeRoom = await _audioChatService.geSingleActiveRoom(upcomingRoom.id);
    if (activeRoom.id.isEmpty) {
      await showCupertinoAlert(
        context,
        'Message',
        'Room has not been started by its creator. Check back.',
        'OK',
        '',
        '',
        false,
      );
      return;
    }

    if (activeRoom.id.isNotEmpty && activeRoom.status == 'ended') {
      await showCupertinoAlert(
        context,
        'Alert',
        'Sorry, the audio chat has ended.',
        'OK',
        '',
        '',
        false,
      );
      return;
    }

    var participants = activeRoom.participants;
    var result =
        participants.where((participant) => participant['username'] == MyAppState.currentUser!.username).toList();
    hasParticipant = result.isNotEmpty;
    Room room = Room(
      id: activeRoom.id,
      title: activeRoom.title,
      tags: activeRoom.tags,
      creator: activeRoom.creator,
      status: activeRoom.status,
      channel: activeRoom.channel,
      speakers: activeRoom.speakers,
      participants: activeRoom.participants,
      startTime: activeRoom.startTime,
      endTime: activeRoom.endTime,
    );
    await [Permission.microphone].request();
    if (!hasParticipant) {
      var newParticipants = {
        'id': MyAppState.currentUser!.userID,
        'username': MyAppState.currentUser!.username,
        'avatarColor': MyAppState.currentUser!.avatarColor,
        'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
      };
      room.participants.add(newParticipants);
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
      _audioChatService.addParticipants(activeRoom.id, newParticipants);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioRoomScreen(
            room: activeRoom,
            role: ClientRole.Audience,
          ),
        ),
      );
    } else {
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioRoomScreen(
            room: activeRoom,
            role: ClientRole.Audience,
          ),
        ),
      );
    }
  }
}
