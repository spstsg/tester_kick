import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/models/audio_upcoming_room_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/audio/audio_upcoming_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/audio/ui/audio_room.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class UpcomingAudioCard extends StatefulWidget {
  const UpcomingAudioCard({Key? key}) : super(key: key);

  @override
  State<UpcomingAudioCard> createState() => _UpcomingAudioCardState();
}

class _UpcomingAudioCardState extends State<UpcomingAudioCard> {
  UpcomingAudioService _upcomingAudioService = UpcomingAudioService();
  AudioChatService _audioChatService = AudioChatService();
  UserService _userService = UserService();
  NotificationService notificationService = NotificationService();
  late Stream<List<UpcomingRoom>> _upcomingRoomsStream;
  bool showStartButton = false;
  bool showJoinButton = false;

  @override
  void initState() {
    _upcomingRoomsStream = _upcomingAudioService.getUpcomingRooms();

    super.initState();
  }

  @override
  void dispose() {
    _upcomingAudioService.disposeUpcomingRoomsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      height: double.infinity,
      child: StreamBuilder<List<UpcomingRoom>>(
        stream: _upcomingRoomsStream,
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
                    'No upcoming audio rooms',
                    'All upcoming rooms will show up here',
                  ),
                );
              },
            );
          } else {
            List<UpcomingRoom> upcomingAudioRooms = snapshot.data!.where((i) => i.status != true).toList();
            if (upcomingAudioRooms.isEmpty) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: showEmptyState(
                  'No upcoming audio rooms',
                  'All upcoming rooms will show up here',
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              physics: ScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: upcomingAudioRooms.length,
              itemBuilder: (BuildContext context, int index) {
                checkEventTime(upcomingAudioRooms[index]);

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
                                    '${calculateDifference(upcomingAudioRooms[index].scheduledDate)},',
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
                                    '${getTime(upcomingAudioRooms[index].scheduledDate)}',
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
                                for (var tag in upcomingAudioRooms[index].tags)
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
                              upcomingAudioRooms[index].title,
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
                                  imageUrl: upcomingAudioRooms[index].creator.profilePictureURL,
                                  username: upcomingAudioRooms[index].creator.username,
                                  avatarColor: upcomingAudioRooms[index].creator.avatarColor,
                                  radius: 22,
                                  fontSize: 30,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Hosted by ${upcomingAudioRooms[index].creator.username}',
                                    style: TextStyle(
                                      color: ColorPalette.black,
                                      fontSize: 16.0,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                showStartButton &&
                                        upcomingAudioRooms[index].creator.username == MyAppState.currentUser!.username
                                    ? GestureDetector(
                                        onTap: () {
                                          startLiveRoom(upcomingAudioRooms[index]);
                                        },
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(40),
                                          ),
                                          child: Text(
                                            'START ROOM',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ColorPalette.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
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
                                    upcomingAudioRooms[index].description,
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
            );
          }
        },
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

  Future<void> checkEventTime(UpcomingRoom room) async {
    var now = DateTime.now();
    var date = DateTime.parse(room.scheduledDate);

    Duration duration = date.difference(now);
    final minutes = duration.inMinutes;
    if (minutes <= 5 && !room.creatorReminderSent) {
      sendCreatorNotification(room);
    }

    if (minutes <= 0 && !room.notificationSent) {
      notifyUsers(room);
    }
  }

  sendCreatorNotification(UpcomingRoom room) async {
    User? user = await _userService.getCurrentUser(room.creator.userID);
    _upcomingAudioService.updateNotificationStatus(room.id, 'creatorReminderSent');
    if (user!.settings.notifications) {
      await notificationService.sendPushNotification(
        user.fcmToken,
        'Audio room reminder',
        '5 minutes remaining before start.',
        {'type': 'upcomingRoom', 'roomId': room.id},
      );
    }
  }

  notifyUsers(UpcomingRoom room) async {
    _upcomingAudioService.updateNotificationStatus(room.id, 'notificationSent');
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        showStartButton = true;
        showJoinButton = true;
      });
    });
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
        id: getRandomString(20),
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
}
