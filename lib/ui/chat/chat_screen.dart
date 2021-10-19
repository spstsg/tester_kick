import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/chat_model.dart';
import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/message_data_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/chat_notification_service.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/chat/receiver_chat_widgets.dart';
import 'package:kick_chat/ui/chat/sender_chat_widgets.dart';
import 'package:kick_chat/ui/chat/widgets/chat_skeleton.dart';
import 'package:kick_chat/ui/widgets/loading_overlay.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChatScreen extends StatefulWidget {
  final HomeConversationModel homeConversationModel;
  final User user;
  const ChatScreen({required this.homeConversationModel, required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatService _chatService = ChatService();
  NotificationService _notificationService = NotificationService();
  UserService _userService = UserService();
  FileService _fileService = FileService();
  ChatNotificationService _chatNotificationService = ChatNotificationService();
  HomeConversationModel homeConversationModel = HomeConversationModel();
  TextEditingController _messageController = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  late Stream<ChatModel> chatStream;
  late Stream<User> _userDataStream;
  GiphyGif? currentGif;
  GiphyClient? client;
  String giphyApiKey = dotenv.get('GIPHY_API_KEY');
  List<File> imageFileList = [];
  List<String> urlPhotos = [];
  User? receiver = User();
  final direction = Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0);
    homeConversationModel = widget.homeConversationModel;
    _userDataStream = _userService.getCurrentUserStream(widget.user.userID);
    setupStream();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _chatService.disposeChatStream();
    _messageController.dispose();
    _userService.disposeCurrentUserStream();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (homeConversationModel.conversationModel != null &&
        homeConversationModel.conversationModel!.receiverId == MyAppState.currentUser!.userID &&
        context.widget.toStringShort() == 'ChatScreen') {
      _chatService.markConversationAsRead(homeConversationModel.conversationModel!);
      _chatService.markMessageAsRead(homeConversationModel.conversationModel!);
    }
    return Scaffold(
      appBar: AppBar(
        // actions: <Widget>[
        //   PopupMenuButton(
        //     itemBuilder: (BuildContext context) {
        //       return [
        //         PopupMenuItem(
        //           child: ListTile(
        //             dense: true,
        //             onTap: () {},
        //             contentPadding: const EdgeInsets.all(0),
        //             leading: Icon(
        //               Icons.settings,
        //               color: ColorPalette.grey,
        //             ),
        //             title: Text(
        //               'Settings',
        //               style: TextStyle(
        //                 fontSize: 18,
        //                 color: ColorPalette.black,
        //               ),
        //             ),
        //           ),
        //         )
        //       ];
        //     },
        //   ),
        // ],
        leadingWidth: 90,
        leading: Container(
          child: Row(
            children: [
              IconButton(
                icon: Icon(MdiIcons.chevronLeft, size: 30),
                onPressed: () {
                  _chatService.updateUserOneUserTwoChat('', '');
                  Navigator.pop(context);
                },
              ),
              ProfileAvatar(
                imageUrl: widget.user.profilePictureURL,
                username: widget.user.username,
                avatarColor: widget.user.avatarColor,
                radius: 20,
                fontSize: 30,
                showPlaceholderImage: widget.user.profilePictureURL.isNotEmpty && widget.user.defaultImage,
              )
            ],
          ),
        ),
        centerTitle: false,
        title: StreamBuilder<User>(
          stream: _userDataStream,
          initialData: widget.user,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  snapshot.data!.username,
                  style: TextStyle(
                    color: ColorPalette.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                snapshot.data!.active
                    ? Text(
                        'Onine',
                        style: TextStyle(
                          color: ColorPalette.white,
                          fontSize: 14,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<ChatModel>(
                  stream: homeConversationModel.conversationModel != null ? chatStream : null,
                  initialData: ChatModel(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ChatSkeleton();
                    } else {
                      if (snapshot.hasData && (snapshot.data?.message.isEmpty ?? true)) {
                        return Center(child: Text('No messages yet'));
                      } else {
                        _scrollController = ScrollController(initialScrollOffset: 50.0);
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: snapshot.data!.message.length,
                          padding: EdgeInsets.only(top: 0, bottom: 8),
                          itemBuilder: (BuildContext context, int index) {
                            var chatMessages = snapshot.data!.message.reversed.toList();
                            return buildMessage(
                              chatMessages[index],
                              snapshot.data!.members,
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: _onFileSelectClick,
                      icon: Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Container(
                          padding: EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
                          margin: EdgeInsets.symmetric(vertical: 20),
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
                                  onChanged: (s) {},
                                  textAlignVertical: TextAlignVertical.center,
                                  controller: _messageController,
                                  textInputAction: TextInputAction.next,
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
                                  maxLines: 3,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await _openGifWidget();
                                  _sendMessage('');
                                  setState(() {
                                    _scrollToBottom();
                                  });
                                },
                                child: Icon(
                                  Icons.sticky_note_2_outlined,
                                  color: ColorPalette.primary,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessage(MessageData messageData, List<User> members) {
    if (messageData.senderID == MyAppState.currentUser!.userID) {
      return senderMessageView(messageData);
    } else {
      return receiverMessageView(
        messageData,
        members[0],
      );
    }
  }

  Widget senderMessageView(MessageData messageData) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12.0),
            child: SenderWidget(
              homeConversationModel: homeConversationModel,
              messageData: messageData,
            ),
          ),
        ],
      ),
    );
  }

  Widget receiverMessageView(MessageData messageData, User sender) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12.0),
            child: ReceiverWidget(
              homeConversationModel: homeConversationModel,
              messageData: messageData,
            ),
          ),
        ],
      ),
    );
  }

  void _onFileSelectClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Send Media',
        style: TextStyle(
          fontSize: 15.0,
        ),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            'Choose image from gallery',
            style: TextStyle(),
          ),
          isDefaultAction: false,
          onPressed: () {
            Navigator.pop(context);
            selectImage();
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel',
          style: TextStyle(),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  void setupStream() {
    chatStream = _chatService.getChatMessages(homeConversationModel).asBroadcastStream();
    chatStream.listen((chatModel) {
      if (mounted) {
        homeConversationModel.members = chatModel.members;
        setState(() {});
      }
    });
  }

  Future<void> _openGifWidget() async {
    GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: giphyApiKey,
      lang: GiphyLanguage.english,
    );
    if (gif != null && mounted) {
      setState(() {
        currentGif = gif;
      });
    }
  }

  void selectImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        imageFileList = files;
        if (imageFileList.isNotEmpty && imageFileList.length <= 4) {
          await uploadFile(context);
        } else {
          showCupertinoAlert(
            context,
            'File selection',
            'Sorry, at this point you can only upload maximum of 4 files',
            'OK',
            '',
            '',
            false,
          );
        }
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(BuildContext context) async {
    LoadingOverlay.of(context).show();
    try {
      if (imageFileList.length == 1) {
        var response = await _fileService.uploadSingleFile(
          imageFileList[0].path,
          getRandomString(20).toLowerCase(),
        );
        if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
          urlPhotos.add(response.secureUrl!);
        } else {
          LoadingOverlay.of(context).hide();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading file. Try again.')),
          );
          return;
        }
      } else if (imageFileList.length > 1) {
        var responses = await _fileService.uploadMultipleFiles(imageFileList);
        responses.map((response) async {
          if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
            urlPhotos.add(response.secureUrl!);
          } else {
            LoadingOverlay.of(context).hide();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading files. Try again.'),
              ),
            );
            return;
          }
        }).toList();
      }
      LoadingOverlay.of(context).hide();
      _sendMessage(_messageController.text, urlPhotos);
      setState(() {
        imageFileList = [];
        _scrollToBottom();
      });
    } catch (e) {
      LoadingOverlay.of(context).hide();
      setState(() {
        imageFileList = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file. Try again.'),
        ),
      );
    }
  }

  Future<bool> _checkChannelNullability(ConversationModel? conversationModel) async {
    if (conversationModel != null) {
      return true;
    } else {
      String channelID;
      User friend = homeConversationModel.members.first;
      User user = MyAppState.currentUser!;
      if (friend.userID.compareTo(user.userID) < 0) {
        channelID = friend.userID + user.userID;
      } else {
        channelID = user.userID + friend.userID;
      }

      ConversationModel conversation = ConversationModel(
        creatorId: user.userID,
        id: channelID,
        lastMessageDate: Timestamp.now(),
        lastMessage: _messageController.text,
        senderId: user.userID,
        receiverId: friend.userID,
      );
      bool isSuccessful = await _chatService.createChatConversation(conversation);
      if (isSuccessful) {
        homeConversationModel.conversationModel = conversation;
        setupStream();
        setState(() {});
      }
      return isSuccessful;
    }
  }

  Future<void> _sendMessage(String content, [images = const []]) async {
    String uid = getRandomString(28);
    MessageData message;
    message = MessageData(
      messageID: uid,
      content: content,
      created: Timestamp.now(),
      recipientID: homeConversationModel.members.first.userID,
      senderID: MyAppState.currentUser!.userID,
      gifUrl: currentGif != null ? currentGif!.images!.original!.url : '',
      chatImages: images,
    );
    if (images.isNotEmpty) {
      message.content = '${MyAppState.currentUser!.username} sent an image';
    }
    if (message.gifUrl.isNotEmpty) {
      message.content = '${MyAppState.currentUser!.username} sent a gif';
    }
    if (await _checkChannelNullability(homeConversationModel.conversationModel)) {
      homeConversationModel.conversationModel!.lastMessageDate = Timestamp.now();
      homeConversationModel.conversationModel!.lastMessage = message.content;
      await _chatService.sendMessage(
        homeConversationModel.members,
        message,
        homeConversationModel.conversationModel!,
      );
      _listenForMessageChanges();
      sendMessageNotification(message);
    } else {
      // showAlertDialog(context, 'anErrorOccurred'.tr(), 'failedToSendMessage'.tr(), true);
    }
  }

  Future sendMessageNotification(MessageData message) async {
    if (homeConversationModel.members.isNotEmpty) {
      receiver = await _userService.getCurrentUser(homeConversationModel.members.first.userID);
      if (receiver!.chat['userTwo'] != MyAppState.currentUser!.username) {
        _chatNotificationService.saveChatNotification(
          'chat_message',
          '${truncateString(message.content, 40)}',
          homeConversationModel.members[0],
          MyAppState.currentUser!.username,
          {'outBound': MyAppState.currentUser!.toJson(), 'chat': message.toJson()},
        );

        if (receiver!.settings.notifications && receiver!.notifications['messages']) {
          await _notificationService.sendPushNotification(
            receiver!.fcmToken,
            MyAppState.currentUser!.username,
            '${truncateString(message.content, 40)}',
            {'type': 'chat', 'senderId': MyAppState.currentUser!.userID, 'receiverId': receiver!.userID},
          );
        }
      }
    }
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

  _listenForMessageChanges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _chatService.getChatMessages(homeConversationModel).listen((event) {
      _scrollToBottom();
    });
  }
}
