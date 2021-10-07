import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/audio/ui/audio_room.dart';
import 'package:kick_chat/ui/widgets/marquee.dart';
import 'package:kick_chat/ui/widgets/ripple/circle_painter.dart';
import 'package:kick_chat/ui/widgets/ripple/curve_wave.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserLiveWidget extends StatefulWidget {
  @override
  _UserLiveWidgetState createState() => _UserLiveWidgetState();
}

class _UserLiveWidgetState extends State<UserLiveWidget> with TickerProviderStateMixin {
  AudoChatService _audioChatService = AudoChatService();
  Room room = Room();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Room>(
      converter: (store) => store.state.selectedRoom,
      builder: (context, storeSelectedRoom) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade300, Colors.blue.shade400],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.13,
                child: CustomPaint(
                  painter: CirclePainter(_controller, color: Colors.red.shade200),
                  child: _circleTransition(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ClientRole role;
                  if (storeSelectedRoom.creator.username == MyAppState.currentUser!.username) {
                    role = ClientRole.Broadcaster;
                  } else {
                    role = ClientRole.Audience;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioRoomScreen(
                        room: storeSelectedRoom,
                        role: role,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarqueeWidget(
                        direction: Axis.horizontal,
                        child: Text(
                          truncateString(storeSelectedRoom.title, 40),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'Hosted by ${storeSelectedRoom.creator.username}',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: ColorPalette.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              storeSelectedRoom.creator.username != MyAppState.currentUser!.username
                  ? Container(
                      padding: EdgeInsets.only(right: 10),
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: GestureDetector(
                        onTap: () async {
                          removeUserFromRoom(storeSelectedRoom);
                        },
                        child: Icon(
                          MdiIcons.close,
                          color: ColorPalette.white,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _circleTransition() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: CurveWave(),
            ),
          ),
        ),
      ),
    );
  }

  removeUserFromRoom(Room room) async {
    AudioRoomScreenState.engine.leaveChannel();
    room.participants.removeWhere((participant) => participant['username'] == MyAppState.currentUser!.username);
    MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
    var result = await Future.wait([
      _audioChatService.removeSpeaker(room.id),
      _audioChatService.removeParticipant(room.creator.userID, room.id),
      _audioChatService.removeUserFromRaisedHands(
        room.id,
        MyAppState.currentUser!.username,
      )
    ]);
    if (result[0] != null || result[1] != null || result[2] != null) {
      final snackBar = SnackBar(content: Text('Error leaving room. Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
