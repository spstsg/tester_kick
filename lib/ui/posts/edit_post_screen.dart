import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/ui/posts/widgets/shared_post_container.dart';
import 'package:kick_chat/ui/widgets/full_screen_image_viewer.dart';
import 'package:kick_chat/ui/widgets/fullscreen_carousel.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/ui/posts/widgets/background_selector.dart';
import 'package:kick_chat/ui/widgets/fullscreen_video_viewer.dart';
import 'package:kick_chat/ui/widgets/grid_layout.dart';
import 'package:kick_chat/ui/widgets/loading_overlay.dart';
import 'package:kick_chat/ui/widgets/multi_photo_display.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  EditPostScreen({required this.post});

  @override
  EditPostScreenState createState() => EditPostScreenState();
}

class EditPostScreenState extends State<EditPostScreen> {
  TextEditingController _editPostController = TextEditingController();

  PostService _postService = PostService();
  FileService _fileService = FileService();
  Map<String, File> mediaFiles = Map.fromEntries([MapEntry('null', File(''))]);
  List<File> imageFileList = [];
  List<String> imageStringList = [];
  var selectedColor = Color(0xFFFFFFFF);
  bool hasPhotos = false;
  String _bgColor = '#ffffff';
  bool postNotEmpty = false;
  List<String> urlPhotos = [];
  String currentGif = '';
  GiphyClient? client;
  String giphyApiKey = dotenv.get('GIPHY_API_KEY');
  bool hasGifSelected = false;
  bool hasVideos = false;
  bool removeSharedPost = true;
  List postVideo = [];
  List<GridLayout> options = [
    GridLayout(
      title: 'Image',
      image: 'assets/images/image-icon.png',
    ),
    GridLayout(
      title: 'Gif',
      image: 'assets/images/gif.png',
    ),
    GridLayout(
      title: 'Video',
      image: 'assets/images/video-upload.png',
    ),
  ];

  @override
  void initState() {
    client = GiphyClient(apiKey: giphyApiKey, randomId: '');
    _editPostController.text = widget.post.post;
    selectedColor = hexStringToColor(widget.post.bgColor);
    _bgColor = widget.post.bgColor;
    if (widget.post.gifUrl != '') {
      hasGifSelected = true;
      currentGif = widget.post.gifUrl;
    }
    if (widget.post.postMedia.isNotEmpty) {
      hasPhotos = true;
      imageStringList = [...widget.post.postMedia];
    }
    if (widget.post.sharedPost.authorId != '') {
      removeSharedPost = false;
    }

    if (widget.post.postVideo.isNotEmpty) {
      hasVideos = true;
      hasPhotos = true;
      postVideo = [...widget.post.postVideo];
      imageStringList = [widget.post.postVideo[0]['videoThumbnail']];
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.post.postMedia.isNotEmpty || widget.post.gifUrl != '' || widget.post.post != '') {
        setState(() {
          postNotEmpty = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _editPostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: postNotEmpty ? () => _editPost(context, widget.post) : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: postNotEmpty ? ColorPalette.white : ColorPalette.lightBlue,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: PostAudienceDropdown(postAudienceValue: widget.post.privacy),
          ),
          Container(
            child: Card(
              elevation: 0.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
                child: Column(
                  children: [
                    selectedColor != Color(0xffffffff)
                        ? Container(
                            height: 200,
                            color: selectedColor,
                            child: Center(
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.next,
                                minLines: 1,
                                maxLines: 10,
                                controller: _editPostController,
                                onChanged: (text) {
                                  setState(() {
                                    postNotEmpty = text.length > 0 ||
                                            currentGif != '' ||
                                            imageFileList.length > 0 ||
                                            imageStringList.length > 0
                                        ? true
                                        : false;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: ColorPalette.white,
                                ),
                                decoration: new InputDecoration(
                                  filled: false,
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: ColorPalette.white,
                                    fontSize: 27,
                                  ),
                                  hintText: "What's on your mind?",
                                  contentPadding: EdgeInsets.all(30.0),
                                ),
                              ),
                            ),
                          )
                        : ConstrainedBox(
                            constraints: new BoxConstraints(
                              maxHeight: 200.0,
                            ),
                            child: Container(
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.next,
                                minLines: 1,
                                maxLines: 10,
                                controller: _editPostController,
                                onChanged: (text) {
                                  setState(() {
                                    postNotEmpty = text.length > 0 ||
                                            currentGif != '' ||
                                            imageFileList.length > 0 ||
                                            imageStringList.length > 0
                                        ? true
                                        : false;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[900],
                                ),
                                decoration: new InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 20,
                                  ),
                                  hintText: "What's on your mind?",
                                  fillColor: ColorPalette.white,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.zero,
                      child: !hasPhotos && !hasGifSelected && removeSharedPost
                          ? BackgroundSelector(
                              callback: (color) => setState(
                                () => {
                                  selectedColor = color,
                                  _bgColor = '#${color.value.toRadixString(16).substring(2, 8)}'
                                },
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          !removeSharedPost
              ? Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: SharedPostContainer(
                      post: widget.post.sharedPost,
                      onDelete: () {
                        setState(() {
                          removeSharedPost = true;
                          _editPostController.text = '';
                        });
                      }),
                )
              : Container(),
          removeSharedPost
              ? Expanded(
                  child: Column(
                    children: [
                      Visibility(
                        visible: hasPhotos && imageFileList.length > 0,
                        child: Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 400,
                            ),
                            child: Container(
                              height: 1000,
                              child: PhotoGrid(
                                type: 'file',
                                imageUrls: imageFileList,
                                onImageClicked: (i) => {
                                  _viewOrDeleteImage(mediaFiles.entries.elementAt(i), i),
                                },
                                onExpandClicked: (int index) => {
                                  _viewOrDeleteImage(
                                    mediaFiles.entries.elementAt(index),
                                    index,
                                  )
                                },
                                maxImages: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: hasPhotos && imageStringList.isNotEmpty,
                        child: Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 400,
                            ),
                            child: Container(
                              height: 1000,
                              child: PhotoGrid(
                                type: 'string',
                                imageUrls: imageStringList,
                                onImageClicked: (i) => {
                                  _viewOrDeleteImage(imageStringList[i], i),
                                },
                                onExpandClicked: (int index) => {
                                  _viewOrDeleteImage(
                                    imageStringList[index],
                                    index,
                                  )
                                },
                                maxImages: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: hasGifSelected,
                        child: Expanded(
                          child: GridView(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 500,
                              crossAxisSpacing: 1,
                            ),
                            children: [
                              currentGif != ''
                                  ? GestureDetector(
                                      onTap: () {
                                        if (currentGif != '') {
                                          _viewGif(currentGif);
                                        }
                                      },
                                      child: Image.network(
                                        currentGif,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text('')
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: hasVideos || hasPhotos || hasGifSelected,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: smallGridElements(),
                        ),
                      ),
                      Visibility(
                        visible: !hasPhotos && !hasGifSelected && !hasVideos,
                        child: Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 5.0,
                                crossAxisSpacing: 5.0,
                              ),
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () async {
                                  if (options[index].title == 'Image') {
                                    _pickImage();
                                  }

                                  if (options[index].title == 'Gif') {
                                    await _openGifWidget();
                                  }

                                  if (options[index].title == 'Video') {
                                    await showCupertinoAlert(
                                      context,
                                      'Alert',
                                      'You cannot add a new video. You can only edit its post. Please delete the complete post and then create a new post with video.',
                                      'OK',
                                      '',
                                      '',
                                      false,
                                    );
                                  }
                                },
                                child: GridOptions(
                                  layout: options[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  Widget smallGridElements() {
    List items = [
      {'title': 'Image', 'image': 'assets/images/image-icon.png'},
      {'title': 'Gif', 'image': 'assets/images/gif.png'},
      {'title': 'Video', 'image': 'assets/images/video-upload.png'},
    ];
    return Container(
      height: 90.0,
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (items[index]['title'] == 'Image') {
                      _pickImage();
                    }

                    if (items[index]['title'] == 'Gif') {
                      await _openGifWidget();
                    }

                    if (items[index]['title'] == 'Video') {
                      await showCupertinoAlert(
                        context,
                        'Alert',
                        'You cannot add a new video. Please delete the post and then create a new post with video.',
                        'OK',
                        '',
                        '',
                        false,
                      );
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.only(right: 30, left: 30, bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: AssetImage(items[index]['image']),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openGifWidget() async {
    GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: giphyApiKey,
      lang: GiphyLanguage.english,
    );
    if (gif != null && mounted) {
      setState(() {
        currentGif = gif.images!.original!.url;
        hasGifSelected = true;
        hasPhotos = false;
        hasVideos = false;
        postVideo = [];
        selectedColor = Color(0xFFFFFFFF);
        postNotEmpty = true;
      });
    }
  }

  Future<void> _editPost(BuildContext context, Post currentPost) async {
    LoadingOverlay.of(context).show();
    try {
      if (imageFileList.length == 1 && hasPhotos) {
        var response = await _fileService.uploadSingleFile(
          imageFileList[0].path,
          getRandomString(20).toLowerCase(),
        );
        if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
          urlPhotos.add(response.secureUrl!);
        } else {
          LoadingOverlay.of(context).hide();
          setState(() {
            postNotEmpty = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading files. Try again.'),
            ),
          );
          return;
        }
      } else if (imageFileList.length > 1 && hasPhotos) {
        var responses = await _fileService.uploadMultipleFiles(imageFileList);
        responses.map((response) async {
          if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
            urlPhotos.add(response.secureUrl!);
          } else {
            LoadingOverlay.of(context).hide();
            setState(() {
              postNotEmpty = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading files. Try again.'),
              ),
            );
            return;
          }
        }).toList();
      }

      if (removeSharedPost) {
        currentPost.sharedPost.authorId = '';
      }

      if (imageFileList.isEmpty && imageStringList.isEmpty) {
        currentPost.postMedia = [];
      }

      Post updatedPost = Post(
        id: currentPost.id,
        authorId: MyAppState.currentUser!.userID,
        bgColor: _bgColor,
        reactions: currentPost.reactions,
        post: _editPostController.text.trim(),
        gifUrl: currentGif,
        privacy: PostAudienceDropdownState.chosenValue,
        postMedia: imageFileList.length > 0 ? urlPhotos : currentPost.postMedia,
        postVideo: currentPost.postVideo,
        commentsCount: currentPost.commentsCount,
        reactionsCount: currentPost.reactionsCount,
        createdAt: currentPost.createdAt,
        shareCount: currentPost.shareCount,
        sharedPost: currentPost.sharedPost,
      );

      String? errorMessage = await _postService.updatePost(updatedPost);
      LoadingOverlay.of(context).hide();
      if (errorMessage == null) {
        _editPostController.clear();
        Navigator.pop(context);
      } else {
        setState(() {
          postNotEmpty = false;
        });
      }
    } catch (e) {
      LoadingOverlay.of(context).hide();
      setState(() {
        postNotEmpty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating post. Try again.'),
        ),
      );
    }
  }

  void _viewOrDeleteImage(dynamic mediaEntry, int index) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        Column(
          children: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                if (mediaEntry is MapEntry) {
                  mediaFiles.removeWhere((key, value) => value == mediaEntry.value);
                  imageFileList.removeAt(index);
                  setState(() {});
                  if (imageFileList.length == 0) {
                    setState(() {
                      hasPhotos = false;
                      hasGifSelected = false;
                      hasVideos = false;
                      if (_editPostController.text == '') {
                        postNotEmpty = false;
                      }
                    });
                  }
                } else {
                  if (hasPhotos && hasVideos) {
                    await showCupertinoAlert(
                      context,
                      'Alert',
                      'You cannot remove this video. In other to do so, delete the complete post.',
                      'OK',
                      '',
                      '',
                      false,
                    );
                    return;
                  }
                  imageStringList.removeAt(index);
                  setState(() {});
                  if (imageStringList.length == 0) {
                    setState(() {
                      hasPhotos = false;
                      hasGifSelected = false;
                      hasVideos = false;
                      if (_editPostController.text == '') {
                        postNotEmpty = false;
                      }
                    });
                  }
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
            if (postVideo.isEmpty) {
              mediaEntry.key.startsWith('image')
                  ? push(
                      context,
                      FullScreen(
                        imageUrl: 'preview',
                        imageFiles: imageFileList,
                        index: index,
                      ),
                    )
                  : push(
                      context,
                      FullScreenVideoViewer(
                        videoUrl: mediaEntry.key,
                        heroTag: 'videoPreview',
                        videoFile: mediaEntry.value,
                      ),
                    );
            }
            if (postVideo.isNotEmpty) {
              push(
                context,
                FullScreenVideoViewer(
                  videoUrl: postVideo[0]['url'],
                  heroTag: 'videoPreview',
                  videoFile: null,
                ),
              );
            }
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

  void _viewGif(String gif) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              currentGif = '';
              hasGifSelected = false;
              hasPhotos = false;
              hasVideos = false;
              if (_editPostController.text == '') {
                postNotEmpty = false;
              }
            });
          },
          child: Text("Remove Media"),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            push(
              context,
              FullScreenImageViewer(
                imageUrl: '',
                imageStringFiles: [gif],
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

  void _pickImage() {
    final action = CupertinoActionSheet(
      message: Text("Add image to post", style: TextStyle(fontSize: 16.0)),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Choose from gallery"),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            try {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: true,
              );
              bool proceed = true;
              if (imageStringList.length > 0) {
                proceed = await showCupertinoAlert(
                  context,
                  'Alert',
                  'Adding new file(s) will remove the previous ones. Would you like to proceed?',
                  'OK',
                  'Cancel',
                  '',
                  true,
                );
              }

              if (!proceed) {
                return;
              } else {
                setState(() {
                  imageStringList = [];
                });
                if (result != null && result.files.isNotEmpty) {
                  List<File> files = result.paths.map((path) => File(path!)).toList();
                  imageFileList = files;
                  for (int i = 0; i < files.length; i++) {
                    mediaFiles.remove('null');
                    mediaFiles['image ${files[i].path}'] = File(files[i].path);
                  }
                }

                setState(() {
                  hasPhotos = true;
                  selectedColor = Color(0xFFFFFFFF);
                  postNotEmpty = true;
                });
              }
            } catch (e) {
              setState(() {
                hasPhotos = false;
                postNotEmpty = postNotEmpty ? true : false;
                hasVideos = false;
                hasGifSelected = false;
                selectedColor = Color(0xFFFFFFFF);
              });
            }
          },
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
}

class PostAudienceDropdown extends StatefulWidget {
  final String postAudienceValue;

  const PostAudienceDropdown({required this.postAudienceValue});
  @override
  PostAudienceDropdownState createState() => PostAudienceDropdownState();
}

class PostAudienceDropdownState extends State<PostAudienceDropdown> {
  static String chosenValue = '';
  List<String> _listItems = [
    'Public',
    'Followers',
    'Private',
  ];

  @override
  void initState() {
    chosenValue = widget.postAudienceValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        margin: EdgeInsets.only(left: 10.0, top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: ColorPalette.white,
          border: Border.all(color: ColorPalette.primary),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              value: chosenValue,
              items: _listItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: ColorPalette.primary,
                      fontSize: 18,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  chosenValue = newValue!;
                });
              }),
        ),
      ),
    );
  }
}
