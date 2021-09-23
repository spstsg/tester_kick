import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/fullscreen_carousel.dart';
import 'package:kick_chat/ui/widgets/multi_photo_display.dart';

class ShareOutsideWidget extends StatefulWidget {
  final Post post;
  final Uint8List? screenshot;
  final displayedImageIndex;
  ShareOutsideWidget({
    required this.post,
    this.screenshot,
    this.displayedImageIndex,
  });

  @override
  ShareOutsideWidgetState createState() => ShareOutsideWidgetState();
}

class ShareOutsideWidgetState extends State<ShareOutsideWidget> {
  TextEditingController _postController = TextEditingController();

  List<String> imageStringList = [];
  bool postNotEmpty = false;
  bool hasGifSelected = false;
  bool hasPhotos = false;
  bool hasScreenshot = false;

  @override
  void initState() {
    if (widget.post.postMedia.isNotEmpty) {
      hasPhotos = true;
      imageStringList = [widget.post.postMedia[widget.displayedImageIndex]];
    } else if (widget.post.gifUrl != '') {
      hasGifSelected = true;
    }

    if (widget.post.post != '' && widget.post.bgColor == '#ffffff') {
      _postController.text = widget.post.post;
    }

    if (widget.screenshot != null) {
      hasScreenshot = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: widget.screenshot == null &&
                    widget.post.postMedia.isEmpty &&
                    _postController.text == ''
                ? null
                : () => shareContent(),
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'Share',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: widget.screenshot == null &&
                            widget.post.postMedia.isEmpty &&
                            _postController.text == ''
                        ? ColorPalette.lightBlue
                        : ColorPalette.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Card(
              elevation: 0.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        maxHeight: 200.0,
                      ),
                      child: Container(
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          controller: _postController,
                          onChanged: (text) {
                            setState(() {
                              // postNotEmpty = text.length > 0 ? true : false;
                            });
                          },
                          style: TextStyle(fontSize: 20, color: Colors.grey[900]),
                          decoration: new InputDecoration(
                            filled: true,
                            isDense: true,
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[700], fontSize: 20),
                            hintText: "Say something about this...",
                            fillColor: ColorPalette.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: Column(
              children: [
                hasPhotos
                    ? Flexible(
                        flex: 1,
                        child: PhotoGrid(
                          type: 'string',
                          imageUrls: imageStringList,
                          onImageClicked: (i) => {
                            _viewOrDeleteImage(imageStringList[i], i, 'single'),
                          },
                          onExpandClicked: (int i) => {
                            _viewOrDeleteImage(imageStringList[i], i, 'multiple'),
                          },
                          maxImages: 6,
                        ),
                      )
                    : Container(),
                hasGifSelected
                    ? Flexible(
                        flex: 1,
                        child: GridView(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 500,
                            crossAxisSpacing: 1,
                          ),
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Image.network(
                                widget.post.gifUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                hasScreenshot
                    ? Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {},
                          child: Image.memory(
                            widget.screenshot as Uint8List,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _viewOrDeleteImage(String mediaEntry, int index, String type) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        Column(
          children: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                imageStringList.removeWhere((key) => key == mediaEntry);
                setState(() {});
                if (imageStringList.length == 0) {
                  setState(() {
                    hasPhotos = !hasPhotos;
                  });
                }
              },
              child: Text("Remove Media"),
              isDestructiveAction: true,
            ),
          ],
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            push(
              context,
              FullScreen(
                imageUrl: '',
                imageFiles: [],
                imageStringFiles: imageStringList,
                index: index,
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

  void shareContent() async {
    try {
      if (widget.screenshot != null) {
        await shareScreenshot(
          context,
          widget.screenshot as Uint8List,
          _postController.text,
        );
      }

      if (widget.post.postMedia.isEmpty && widget.screenshot == null) {
        await shareText(context, _postController.text);
      }

      if (widget.post.postMedia.isNotEmpty && widget.screenshot == null) {
        await shareImage(
          context,
          _postController.text,
          widget.post.postMedia[widget.displayedImageIndex],
        );
      }
      Navigator.pop(context);
    } catch (e) {
      final snackBar = SnackBar(content: Text('Error sharing your content. Try again later.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
