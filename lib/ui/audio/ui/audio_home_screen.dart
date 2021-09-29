import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_chat_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/audio/ui/audio_room_search.dart';
import 'package:kick_chat/ui/audio/ui/create_room_form.dart';
import 'package:kick_chat/ui/audio/ui/live_audio_rooms.dart';
import 'package:kick_chat/ui/audio/ui/upcoming_room_form.dart';
import 'package:kick_chat/ui/audio/widgets/upcoming_audio_card.dart';
import 'package:kick_chat/ui/widgets/circle_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AudioHomeScreen extends StatefulWidget {
  const AudioHomeScreen({Key? key}) : super(key: key);

  @override
  _AudioHomeScreenState createState() => _AudioHomeScreenState();
}

class _AudioHomeScreenState extends State<AudioHomeScreen> {
  AudoChatService _audioChatService = AudoChatService();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Room>(
      converter: (store) => store.state.selectedRoom,
      builder: (context, storeSelectedRoom) {
        return DefaultTabController(
          length: 2,
          child: CustomScrollView(
            controller: null,
            physics: ScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: ColorPalette.white,
                leading: CircleButton(
                  icon: Icons.search,
                  iconSize: 30.0,
                  onPressed: () {
                    Navigator.of(context).push(
                      new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new AudioRoomSearch();
                        },
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                titleSpacing: 2.0,
                title: Text(
                  'AUDIO ROOMS',
                  style: TextStyle(
                    color: ColorPalette.primary,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
                floating: true,
                actions: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(right: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(height: 30),
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: ColorPalette.greyWhite,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: ColorPalette.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            MdiIcons.volumeHigh,
                                            size: 20,
                                            color: ColorPalette.white,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 20),
                                        title: Text(
                                          'Start a room',
                                          style: TextStyle(
                                            color: ColorPalette.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () {
                                          checkParticipant(storeSelectedRoom);
                                          Navigator.pop(context);
                                          startRoomNavigation();
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.only(bottom: 30),
                                      child: ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: ColorPalette.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.calendar_today,
                                            size: 20,
                                            color: ColorPalette.white,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 20),
                                        title: Text(
                                          'Schedule a room',
                                          style: TextStyle(
                                            color: ColorPalette.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                            new MaterialPageRoute<Null>(
                                              builder: (BuildContext context) {
                                                return new UpcomingRoomFormDialog();
                                              },
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            primary: Colors.blue,
                            textStyle: TextStyle(color: ColorPalette.primary),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: ColorPalette.primary),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text(
                            'CREATE ROOM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: TabBar(
                  labelColor: ColorPalette.primary,
                  labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  unselectedLabelColor: ColorPalette.grey,
                  tabs: [
                    Tab(text: 'LIVE'),
                    Tab(text: 'UPCOMING'),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  children: <Widget>[
                    LiveAudioRooms(),
                    Container(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return UpcomingAudioCard();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  startRoomNavigation() async {
    var result = await _audioChatService.checkUserLiveRooms();
    if (result.isEmpty) {
      Navigator.of(context).push(
        new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new CreateRoomFormDialog();
          },
          fullscreenDialog: true,
        ),
      );
    } else {
      await showCupertinoAlert(
        context,
        'Alert',
        'Sorry, you cannot create another live room because you still have one open.',
        'Close',
        '',
        '',
        false,
      );
    }
  }

  checkParticipant(Room room) {
    var participants = room.participants;
    var user =
        participants.where((participant) => participant['username'] == MyAppState.currentUser!.username).toList();
    if (user.isNotEmpty && room.creator.username != user[0]['username']) {
      participants.removeWhere((participant) => participant['username'] == MyAppState.currentUser!.username);
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));
      _audioChatService.removeSpeaker(room.id);
      _audioChatService.removeParticipant(
        room.creator.userID,
        room.id,
      );
    }
  }
}
