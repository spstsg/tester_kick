import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/models/message_data_model.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/full_screen_image_viewer.dart';
import 'package:kick_chat/ui/widgets/multi_chat_photo_display.dart';

class SenderWidget extends StatelessWidget {
  final HomeConversationModel homeConversationModel;
  final MessageData messageData;

  SenderWidget({
    required this.homeConversationModel,
    required this.messageData,
  });

  @override
  Widget build(BuildContext context) {
    return senderMessageWidget(context, messageData);
  }

  Widget senderMessageWidget(BuildContext context, MessageData messageData) {
    ChatService _chatService = ChatService();
    if (messageData.chatImages.isNotEmpty) {
      return GestureDetector(
        onLongPress: () async {
          if (messageData.messageDeleted) return;
          var dialogResponse = await showCupertinoAlert(
            context,
            'Delete',
            'Are you sure you want to delete this image?',
            'Delete',
            'Cancel',
            true,
          );
          if (dialogResponse) {
            try {
              await _chatService.deleteChatMessage(
                homeConversationModel.conversationModel!,
                messageData.messageID,
              );
            } catch (e) {
              showSnackBar(
                  context, 'Error deleting the image. Try again later');
            }
          } else {
            return;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: 200,
                maxHeight: 200,
              ),
              child: !messageData.messageDeleted
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                push(
                                  context,
                                  FullScreenImageViewer(
                                    imageUrl: '',
                                    imageStringFiles: messageData.chatImages,
                                    imageFiles: [],
                                  ),
                                );
                              },
                              child: messageData.chatImages.length <= 1
                                  ? Hero(
                                      tag: getRandomString(20),
                                      child: CachedNetworkImage(
                                        imageUrl: messageData.chatImages[0],
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          'assets/images/img_placeholder'
                                          '.png',
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/error_image'
                                          '.png',
                                        ),
                                      ),
                                    )
                                  : ChatPhotoGrid(
                                      type: 'string',
                                      imageUrls: messageData.chatImages,
                                      onImageClicked: (i) => {},
                                      onExpandClicked: (int index) =>
                                          _viewImage(context,
                                              messageData.chatImages, index),
                                      maxImages: 1,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 150, maxWidth: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 10,
                            left: 4,
                            right: 4,
                          ),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 6, left: 6),
                                    child: Text(
                                      'message deleted',
                                      textAlign: TextAlign.start,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: ColorPalette.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 3),
              child: Text(
                timeFromDate(messageData.created),
                textAlign: TextAlign.end,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            )
          ],
        ),
      );
    } else if (messageData.chatImages.isEmpty &&
        messageData.content.isEmpty &&
        messageData.gifUrl.isNotEmpty) {
      return GestureDetector(
        onLongPress: () async {
          if (messageData.messageDeleted) return;
          var dialogResponse = await showCupertinoAlert(
            context,
            'Delete',
            'Are you sure you want to delete this gif?',
            'Delete',
            'Cancel',
            true,
          );
          if (dialogResponse) {
            try {
              await _chatService.deleteChatMessage(
                homeConversationModel.conversationModel!,
                messageData.messageID,
              );
            } catch (e) {
              showSnackBar(context, 'Error deleting the gif. Try again later');
            }
          } else {
            return;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: 200,
              ),
              child: !messageData.messageDeleted
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              push(
                                context,
                                FullScreenImageViewer(
                                  imageUrl: '',
                                  imageStringFiles: [messageData.gifUrl],
                                  imageFiles: [],
                                ),
                              );
                            },
                            child: Hero(
                              tag: getRandomString(20),
                              child: CachedNetworkImage(
                                imageUrl: messageData.gifUrl,
                                placeholder: (context, url) =>
                                    Image.asset('assets/images/img_placeholder'
                                        '.png'),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/error_image'
                                        '.png'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 150, maxWidth: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 10,
                            left: 4,
                            right: 4,
                          ),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 6, left: 6),
                                    child: Text(
                                      'message deleted',
                                      textAlign: TextAlign.start,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: ColorPalette.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 3),
              child: Text(
                timeFromDate(messageData.created),
                textAlign: TextAlign.end,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            )
          ],
        ),
      );
    } else if (messageData.chatImages.isEmpty &&
        messageData.content.isNotEmpty &&
        messageData.gifUrl.isEmpty) {
      return GestureDetector(
        onLongPress: () async {
          if (messageData.messageDeleted) return;
          var dialogResponse = await showCupertinoAlert(
            context,
            'Delete',
            'Are you sure you want to delete this message?',
            'Delete',
            'Cancel',
            true,
          );
          if (dialogResponse) {
            try {
              await _chatService.deleteChatMessage(
                homeConversationModel.conversationModel!,
                messageData.messageID,
              );
            } catch (e) {
              showSnackBar(
                  context, 'Error deleting the message. Try again later');
            }
          } else {
            return;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Directionality.of(context) == TextDirection.ltr
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              children: <Widget>[
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  end: -8,
                  bottom: 0,
                  child: Image.asset(
                    Directionality.of(context) == TextDirection.ltr
                        ? 'assets/images/chat_arrow_right.png'
                        : 'assets/images/chat_arrow_left.png',
                    color: ColorPalette.primary,
                    height: 12,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 150,
                    maxWidth: 300,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !messageData.messageDeleted
                          ? ColorPalette.primary
                          : Colors.blue.shade300,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 4, bottom: 10, left: 4, right: 4),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 6),
                                child: Text(
                                  !messageData.messageDeleted
                                      ? messageData.content
                                      : 'message deleted',
                                  textAlign: TextAlign.start,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                    color: ColorPalette.white,
                                    fontSize: 16,
                                    fontStyle: !messageData.messageDeleted
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(right: 3),
              child: Text(
                timeFromDate(messageData.created),
                textAlign: TextAlign.end,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

void _viewImage(BuildContext context, List<dynamic> mediaEntry, int index) {
  final action = CupertinoActionSheet(
    actions: <Widget>[
      CupertinoActionSheetAction(
        onPressed: () async {
          Navigator.pop(context);
          await push(
            context,
            FullScreenImageViewer(
              imageUrl: '',
              imageStringFiles: mediaEntry,
              imageFiles: [],
            ),
          );
        },
        isDefaultAction: true,
        child: Text('View Media'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
  showCupertinoModalPopup(context: context, builder: (context) => action);
}
