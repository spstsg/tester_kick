import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/livescores_chat_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/chat/livescores_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/friends/followers_skeleton.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widget_chats.dart';

class GameChatScreen extends StatefulWidget {
  final matchDetails;
  final User user;

  GameChatScreen({required this.matchDetails, required this.user});

  @override
  _GameChatScreenState createState() => _GameChatScreenState();
}

class _GameChatScreenState extends State<GameChatScreen> {
  LiveScoresChat _livescoresChatService = LiveScoresChat();
  TextEditingController _messageController = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  late Stream<List<LivescoresModel>> _livescoreMessageStream;
  bool hasMessage = false;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0);
    String uid = roomUID();
    _livescoreMessageStream = _livescoresChatService.getLiveScoreMessages(uid);
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    hasMessage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<LivescoresModel>>(
            stream: _livescoreMessageStream,
            initialData: [],
            builder: (context, snapshot) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                if (snapshot.data!.isNotEmpty) {
                  setState(() {
                    hasMessage = true;
                  });
                }
              });
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: EdgeInsets.only(left: 10),
                  child: FollowersSkeleton(),
                );
              } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    hasMessage = true;
                  });
                });
                return Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Center(
                    child: showEmptyState(
                      'No conversations yet.',
                      'All conversations will show up here',
                    ),
                  ),
                );
              } else {
                _scrollController = ScrollController(initialScrollOffset: 50.0);
                return ListView.builder(
                  key: PageStorageKey(1),
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var chatMessages = snapshot.data!;
                    return Column(
                      children: [
                        CardChat(
                          name: chatMessages[index].username,
                          image: chatMessages[index].profilePicture,
                          message: chatMessages[index].lastMessage,
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
        hasMessage
            ? Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 25, right: 2),
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 14,
                              right: 14,
                              top: 5,
                              bottom: 5,
                            ),
                            decoration: ShapeDecoration(
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(360),
                                ),
                                borderSide: BorderSide(style: BorderStyle.none),
                              ),
                              color: Colors.grey.shade200,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: _messageController,
                                    style: TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 5,
                                      ),
                                      hintText: 'Start typing...',
                                      hintStyle: TextStyle(
                                        color: ColorPalette.grey,
                                        fontSize: 16,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(360),
                                        ),
                                        borderSide: BorderSide(
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(360),
                                        ),
                                        borderSide: BorderSide(
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                    maxLines: 3,
                                    minLines: 1,
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: ColorPalette.primary,
                        ),
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(_messageController.text);
                            _messageController.clear();
                            setState(() {
                              _scrollToBottom();
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  _scrollToBottom() async {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    await Future.delayed(const Duration(milliseconds: 300));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  _listenForMessageChanges(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _livescoresChatService.getLiveScoreMessages(uid).listen((event) {
      _scrollToBottom();
    });
  }

  String roomUID() {
    String homeTeam = widget.matchDetails['teams']['home']['name'].replaceAll(' ', '');
    String awayTeam = widget.matchDetails['teams']['away']['name'].replaceAll(' ', '');
    return homeTeam.toLowerCase() + awayTeam.toLowerCase();
  }

  _sendMessage(String message) async {
    User user = MyAppState.currentUser!;
    LivescoresModel conversation = LivescoresModel(
      id: roomUID(),
      lastMessageDate: Timestamp.now(),
      lastMessage: _messageController.text,
      senderId: user.userID,
      username: user.username,
      profilePicture: user.profilePictureURL,
    );
    bool isSuccessful = await _livescoresChatService.addLivescoresMessages(conversation);
    if (isSuccessful) {
      setState(() {
        String uid = roomUID();
        _listenForMessageChanges(uid);
      });
    }
    return isSuccessful;
  }
}
