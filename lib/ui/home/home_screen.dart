import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/chat_notification_service.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/poll/poll_service.dart';
import 'package:kick_chat/ui/chat/conversation_screen.dart';
import 'package:kick_chat/ui/home/user_search.dart';
import 'package:kick_chat/ui/notifications/local_notification.dart';
// import 'package:kick_chat/ui/polls/create_poll.dart';
import 'package:kick_chat/ui/polls/widgets/live_poll_widget.dart';
// import 'package:kick_chat/ui/toberemoved/add_clubs.dart';
import 'package:kick_chat/ui/widgets/circle_button.dart';
import 'package:kick_chat/ui/posts/widgets/create_post_container.dart';
import 'package:kick_chat/ui/posts/widgets/post_container.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PollService _pollService = PollService();
  NotificationService _notificationService = NotificationService();
  ChatNotificationService _chatNotificationService = ChatNotificationService();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0);
    super.initState();
  }

  @override
  void dispose() {
    _notificationService.disposeUserNotificationCountStream();
    _chatNotificationService.disposeUserNotificationCountStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorPalette.greyWhite),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: ColorPalette.white,
            title: Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'KICKCHAT',
                style: TextStyle(
                  color: ColorPalette.primary,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.8,
                ),
              ),
            ),
            centerTitle: false,
            floating: true,
            actions: [
              StreamBuilder<int>(
                stream: _notificationService.getUserNotificationsCount(),
                initialData: 0,
                builder: (context, snapshot) {
                  return CircleButton(
                    icon: MdiIcons.bellOutline,
                    iconSize: 30.0,
                    showBadge: true,
                    badgeNumber: snapshot.hasData && snapshot.data! > 0 ? snapshot.data! : 0,
                    onPressed: () => push(context, LocalNotification()),
                  );
                },
              ),
              StreamBuilder<int>(
                stream: _chatNotificationService.getUserChatNotificationsCount(),
                initialData: 0,
                builder: (context, snapshot) {
                  return CircleButton(
                    icon: MdiIcons.chatOutline,
                    iconSize: 30.0,
                    showBadge: true,
                    badgeNumber: snapshot.hasData && snapshot.data! > 0 ? snapshot.data! : 0,
                    onPressed: () => push(context, ConversationsScreen(user: MyAppState.currentUser!)),
                  );
                },
              ),
              // CircleButton(
              //   icon: MdiIcons.poll,
              //   iconSize: 30.0,
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       new MaterialPageRoute<Null>(
              //         builder: (BuildContext context) {
              //           return new CreatePoll();
              //         },
              //         fullscreenDialog: true,
              //       ),
              //     );
              //   },
              // ),
              CircleButton(
                icon: Icons.search,
                iconSize: 30.0,
                onPressed: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new UserSearch();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),

              // CircleButton(
              //   icon: MdiIcons.plus,
              //   iconSize: 30.0,
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       new MaterialPageRoute<Null>(
              //         builder: (BuildContext context) {
              //           return new AddClubsScreen();
              //         },
              //         fullscreenDialog: true,
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
          SliverToBoxAdapter(
            child: CreatePostContainer(),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: _pollService.getPollByStatusStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || (snapshot.data?.docs.isEmpty ?? true)) {
                  return SizedBox.shrink();
                } else {
                  PollModel poll = PollModel.fromJson(snapshot.data!.docs[0].data() as Map<String, dynamic>);
                  return Container(
                    padding: EdgeInsets.only(top: 10),
                    color: ColorPalette.greyWhite,
                    child: LivePollWidget(poll: poll),
                  );
                }
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostContainer(scrollController: _scrollController);
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
