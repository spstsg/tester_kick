import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/chat/chat_screen.dart';
import 'package:kick_chat/ui/chat/widgets/conversation_followers_skeleton.dart';
import 'package:kick_chat/ui/chat/widgets/conversation_skeleton.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ConversationsScreen extends StatefulWidget {
  final User user;

  ConversationsScreen({required this.user});

  @override
  State createState() {
    return _ConversationsState();
  }
}

class _ConversationsState extends State<ConversationsScreen> {
  ChatService _chatService = ChatService();
  FollowService _followService = FollowService();
  late User user;
  late Future<List<User>> _friendsFuture;
  late Stream<List<HomeConversationModel>> _conversationsStream;
  bool hasConversations = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _friendsFuture = _followService.getUserFollowersWithRange(MyAppState.currentUser!.userID);
    _conversationsStream = _chatService.getChatConversations(MyAppState.currentUser!.userID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Conversations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: hasConversations ? 10 : 0),
          Expanded(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  hasConversations ? _followersList() : SizedBox.shrink(),
                  _buildConversation(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConversation() {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 10),
      child: StreamBuilder<List<HomeConversationModel>>(
        stream: _conversationsStream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ConversationSkeleton();
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: showEmptyState(
                  'No conversations found.',
                  'All your conversations will show up here',
                ),
              ),
            );
          } else {
            return _buildConversationList(snapshot);
          }
        },
      ),
    );
  }

  Widget _buildConversationList(AsyncSnapshot<List<dynamic>> snapshot) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        final homeConversationModel = snapshot.data![index];
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          setState(() {
            hasConversations = true;
          });
        });
        return GestureDetector(
          onTap: () {
            if (homeConversationModel.conversationModel!.creatorId == MyAppState.currentUser!.userID) {
              _chatService.markConversationAsRead(homeConversationModel.conversationModel!);
              _chatService.markMessageAsRead(homeConversationModel.conversationModel!);
            }
            push(
              context,
              ChatScreen(
                homeConversationModel: homeConversationModel,
                user: homeConversationModel.members.first,
              ),
            );
          },
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.only(left: 20),
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    ProfileAvatar(
                      imageUrl: homeConversationModel.members.first.profilePictureURL,
                      username: homeConversationModel.members.first.username,
                      avatarColor: homeConversationModel.members.first.avatarColor,
                      radius: 20,
                      fontSize: 30,
                    ),
                    homeConversationModel.members.first.active
                        ? Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink()
                  ],
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        homeConversationModel.members.first.username,
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 10,
                        children: [
                          Text(
                            timeFromDate(homeConversationModel.conversationModel!.lastMessageDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorPalette.primary,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                      child: Text(
                        !homeConversationModel.conversationModel!.messageDeleted
                            ? truncateString(
                                homeConversationModel.conversationModel!.lastMessage,
                                35,
                              )
                            : 'message deleted',
                        style: TextStyle(
                          fontSize: 15,
                          color: ColorPalette.grey,
                          fontStyle: !homeConversationModel.conversationModel!.messageDeleted
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(
                        !homeConversationModel.conversationModel!.isRead ? Icons.check : MdiIcons.checkAll,
                        size: 16,
                        color: !homeConversationModel.conversationModel!.isRead ? Colors.grey : Colors.blue,
                      ),
                    )
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }

  FutureBuilder<List<User>> _followersList() {
    return FutureBuilder<List<User>>(
      future: _friendsFuture,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ConversationFollowersSkeleton();
        } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
          return SizedBox(height: 0);
        } else {
          return SizedBox(
            height: snapshot.hasData ? 75 : 0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                User friend = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 10, right: 4),
                  child: InkWell(
                    onTap: () async {
                      ConversationModel? conversationModel = await _chatService.getSingleConversation(
                        MyAppState.currentUser!.userID,
                        friend.userID,
                      );
                      push(
                        context,
                        ChatScreen(
                          homeConversationModel: HomeConversationModel(
                            members: [friend],
                            conversationModel: conversationModel,
                          ),
                          user: widget.user,
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        displayCircleImage(friend.profilePictureURL, 40, false),
                        Expanded(
                          child: Container(
                            width: 75,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                              child: Text(
                                '${friend.username}',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
