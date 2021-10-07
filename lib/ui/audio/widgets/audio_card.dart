import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/services/helper.dart';
// import 'package:kick_chat/ui/widgets/countdown/cupertino_timer.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

class AudioCard extends StatelessWidget {
  final VoidCallback onPressed;
  final Room room;

  const AudioCard({
    required this.onPressed,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    var participants = room.participants;
    var result = participants.where((participant) => participant['username'] == MyAppState.currentUser!.username);
    bool hasParticipant = result.isNotEmpty ? true : false;

    return Container(
      decoration: BoxDecoration(color: ColorPalette.greyWhite),
      child: Card(
        elevation: 1.0,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.2, color: ColorPalette.grey),
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
                        horizontal: 7.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.primary,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        'Live',
                        style: TextStyle(
                          color: ColorPalette.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    for (var tag in room.tags)
                      Container(
                        constraints: BoxConstraints(maxWidth: 120),
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.0,
                          vertical: 1.0,
                        ),
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
              SizedBox(height: 10),
              // Container(
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Container(
              //         width: MediaQuery.of(context).size.width * 0.18,
              //         child: Text(
              //           'Duration:',
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //             color: ColorPalette.primary,
              //           ),
              //         ),
              //       ),
              //       Container(
              //         width: MediaQuery.of(context).size.width * 0.42,
              //         constraints: BoxConstraints(maxWidth: 200),
              //         margin: EdgeInsets.only(right: 8),
              //         child: Text(
              //           room.newEndTime.isEmpty
              //               ? '${timeFormat(room.startTime, room.endTime)}'
              //               : '${timeFormat(room.endTime, room.newEndTime)}',
              //           style: TextStyle(color: ColorPalette.black),
              //         ),
              //       ),
              //       Container(
              //         width: MediaQuery.of(context).size.width * 0.25,
              //         child: CupertinoTimer(
              //           alignment: Alignment.centerRight,
              //           startOnInit: true,
              //           duration: Duration(minutes: countDownTime() > 0 ? countDownTime() : 0),
              //           timeStyle: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.blue,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: room.participants.length >= 21 ? 21 : room.participants.length,
                  physics: ScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemBuilder: (context, index) {
                    List participants = room.participants.toList();
                    return Container(
                      child: Stack(
                        children: <Widget>[
                          ProfileAvatar(
                            imageUrl: participants[index]['profilePictureURL'],
                            username: participants[index]['username'],
                            avatarColor: participants[index]['avatarColor'],
                            radius: 22,
                            fontSize: 30,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Text(
                  room.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: ColorPalette.primary,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        showParticipantsNames(room.participants),
                        style: TextStyle(
                          color: ColorPalette.grey,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
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
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String showParticipantsNames(List participants) {
    if (participants.isNotEmpty) {
      if (participants.length >= 2 && participants.length <= 10) {
        return '${participants[0]['username']} & ${participants.length - 1} other are here';
      } else if (participants.length > 10) {
        return '${participants[0]['username']}, ${participants[1]['username']} + ${participants.length - 2} other listeners';
      } else {
        return '${participants[0]['username']} is here';
      }
    } else {
      return '';
    }
  }

  String timeFormat(startTime, endTime) {
    final startTimeDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(startTime);
    final endTimeDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(endTime);
    final Duration difference = endTimeDate.difference(startTimeDate);
    if (difference.inHours > 0 && difference.inMinutes.remainder(60) == 0 && difference.inSeconds.remainder(60) == 0) {
      return difference.inHours == 1 ? '${difference.inHours} hour' : '${difference.inHours} hours';
    } else if (difference.inHours == 0 && difference.inMinutes.remainder(60) > 0) {
      return difference.inMinutes.remainder(60) == 1
          ? '${difference.inMinutes.remainder(60)} minute'
          : '${difference.inMinutes.remainder(60)} minutes';
    } else if (difference.inHours == 0 &&
        difference.inMinutes.remainder(60) == 0 &&
        difference.inSeconds.remainder(60) > 0) {
      return difference.inSeconds.remainder(60) == 1
          ? '${difference.inSeconds.remainder(60)} second'
          : '${difference.inSeconds.remainder(60)} seconds';
    } else {
      var hours = difference.inHours == 1 ? '${difference.inHours} hour' : '${difference.inHours} hours';
      var minutes = difference.inMinutes.remainder(60) == 1
          ? '${difference.inMinutes.remainder(60)} minute'
          : '${difference.inMinutes.remainder(60)} minutes';
      return '$hours ${difference.inMinutes.remainder(60) > 0 ? minutes : ""}';
    }
  }

  int timeDifference(startTime, endTime) {
    final startTimeDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(startTime);
    final endTimeDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(endTime);
    final Duration difference = endTimeDate.difference(startTimeDate);
    return difference.inMinutes;
  }

  int countDownTime() {
    int elapsedRoomTime = 0;
    String roomStarted = DateTime.now().toString();
    int roomTime = 0;
    if (room.newEndTime.isEmpty) {
      roomTime = timeDifference(room.roomStarted, roomStarted);
      int currentTime = timeDifference(room.startTime, room.endTime);
      elapsedRoomTime = currentTime - roomTime;
    }

    if (room.newEndTime.isNotEmpty) {
      int newRoomTime = timeDifference(room.newRoomStarted, DateTime.now().toString());
      int newCurrentTime = timeDifference(room.endTime, room.newEndTime);
      elapsedRoomTime = newCurrentTime - newRoomTime;
    }
    return elapsedRoomTime;
  }
}
