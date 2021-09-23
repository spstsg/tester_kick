import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_chat_model.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/chat/audio_room_chat.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/audio/widgets/audio_room_single_skeleton.dart';

class RoomDiscussion extends StatefulWidget {
  final Room room;
  RoomDiscussion({Key? key, required this.room}) : super(key: key);

  @override
  _RoomDiscussionState createState() => _RoomDiscussionState();
}

class _RoomDiscussionState extends State<RoomDiscussion> {
  AudioRoomChatService _audioChatRoomService = AudioRoomChatService();
  TextEditingController _messageController = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  late Stream<List<AudioRoomModel>> _audioChatMessageStream;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0);
    _audioChatMessageStream = _audioChatRoomService.getAudioRoomMessages(widget.room.id);
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioChatRoomService.disposeAudioRoomMessageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorPalette.white,
        centerTitle: true,
        title: Text(
          'Live discussions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.only(right: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(height: 30),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                        'Leave',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: _buildConversation()),
            messageInput(),
          ],
        ),
      ),
    );
  }

  Widget messageInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: Container(
                padding: EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
                decoration: ShapeDecoration(
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(360)),
                    borderSide: BorderSide(style: BorderStyle.none),
                  ),
                  color: Colors.grey.shade200,
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _messageController,
                  style: TextStyle(
                    color: ColorPalette.black,
                    fontSize: 16,
                  ),
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
                  maxLines: 2,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: ColorPalette.primary,
              size: 30,
            ),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                _sendMessage(widget.room.id, _messageController.text);
                _messageController.clear();
                setState(() {
                  _scrollToBottom();
                });
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildConversation() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder<List>(
        stream: _audioChatMessageStream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AudioRoomSingleSkeleton(amount: 10);
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
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
            return ListView.builder(
              physics: ScrollPhysics(),
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 10),
                      leading: Stack(
                        children: <Widget>[
                          CircleAvatar(
                            child: ClipOval(
                              child: Image(
                                height: 40.0,
                                width: 40.0,
                                image: NetworkImage(snapshot.data![index].profilePicture),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              snapshot.data![index].username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: ColorPalette.primary,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 15),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                Text(
                                  dateTimeAgo(snapshot.data![index].lastMessageDate),
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
                      subtitle: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0, right: 7),
                        child: Wrap(
                          children: [
                            Text(
                              truncateString(snapshot.data![index].lastMessage, 40),
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorPalette.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  _sendMessage(String roomId, String message) async {
    User user = MyAppState.currentUser!;
    AudioRoomModel conversation = AudioRoomModel(
      id: roomId,
      lastMessageDate: Timestamp.now(),
      lastMessage: _messageController.text,
      senderId: user.userID,
      username: user.username,
      profilePicture: user.profilePictureURL,
    );
    bool isSuccessful = await _audioChatRoomService.addAudioRoomMessage(conversation);
    if (isSuccessful) {
      setState(() {
        _listenForMessageChanges(roomId);
      });
    }
    return isSuccessful;
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
    _audioChatRoomService.getAudioRoomMessages(widget.room.id).listen((event) {
      _scrollToBottom();
    });
  }
}
