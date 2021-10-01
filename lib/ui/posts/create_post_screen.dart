import 'dart:async';
import 'dart:io';

import 'package:kick_chat/redux/actions/created_post_action.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:kick_chat/models/image_model.dart';
import 'package:kick_chat/services/files/file_service.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreatePostScreen extends StatefulWidget {
  final bool openGif;
  final bool openImagePicker;
  final bool openVideoPicker;
  CreatePostScreen({
    this.openGif: false,
    this.openImagePicker: false,
    this.openVideoPicker: false,
  });

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController _postController = TextEditingController();
  PostService _postService = PostService();
  FileService _fileService = FileService();
  Map<String, File> mediaFiles = Map.fromEntries([MapEntry('null', File(''))]);
  List<File> imageFileList = [];
  var selectedColor = Color(0xFFFFFFFF);
  bool hasPhotos = false;
  String _bgColor = '#ffffff';
  bool postNotEmpty = false;
  List<String> urlPhotos = [];
  List mediaFilesURLs = [];
  GiphyGif? currentGif;
  GiphyClient? client;
  String giphyApiKey = dotenv.get('GIPHY_API_KEY');
  bool hasGifSelected = false;
  bool hasVideos = false;
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.openGif && mounted) {
        _openGifWidget();
      }

      if (widget.openImagePicker && mounted) {
        _pickImage();
      }

      if (widget.openVideoPicker && mounted) {
        _pickVideo();
      }
    });
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
        title: Text(
          'Create Post',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: (postNotEmpty || hasPhotos || hasGifSelected) && !hasVideos
                ? () => _publishPost(context)
                : (postNotEmpty || hasVideos)
                    ? () => _publishPostWithVideo(context)
                    : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'Post',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: postNotEmpty || hasPhotos || hasGifSelected || hasVideos
                        ? ColorPalette.white
                        : ColorPalette.lightBlue,
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
            child: PostAudienceDropdown(),
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
                                minLines: 1,
                                maxLines: 10,
                                controller: _postController,
                                onChanged: (text) {
                                  setState(() {
                                    postNotEmpty = text.length > 0 ? true : false;
                                    if (currentGif != null && text.length == 0) {
                                      hasGifSelected = true;
                                    }
                                    if (imageFileList.isNotEmpty && text.length == 0) {
                                      hasPhotos = true;
                                    }
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
                            constraints: new BoxConstraints(maxHeight: 200.0),
                            child: Container(
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 10,
                                controller: _postController,
                                onChanged: (text) {
                                  setState(() {
                                    postNotEmpty = text.length > 0 ? true : false;
                                    if (currentGif != null && text.length == 0) {
                                      hasGifSelected = true;
                                    }
                                    if (imageFileList.isNotEmpty && text.length == 0) {
                                      hasPhotos = true;
                                    }
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
                                  hintStyle: TextStyle(color: Colors.grey[700], fontSize: 20),
                                  hintText: "What's on your mind?",
                                  fillColor: ColorPalette.white,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.zero,
                      child: !hasPhotos && !hasGifSelected
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
          Expanded(
            child: Column(
              children: [
                Visibility(
                  visible: hasPhotos,
                  child: Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 400,
                      ),
                      child: Container(
                        height: 1000,
                        child: PhotoGrid(
                          type: 'file',
                          imageUrls: imageFileList,
                          onImageClicked: (i) => {
                            _viewOrDeleteImage(
                              mediaFiles.entries.elementAt(i),
                              i,
                            ),
                          },
                          onExpandClicked: (int index) =>
                              {_viewOrDeleteImage(mediaFiles.entries.elementAt(index), index)},
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
                        currentGif != null
                            ? GestureDetector(
                                onTap: () {
                                  if (currentGif != null) {
                                    _viewGif(
                                      currentGif!.images!.original!.url,
                                    );
                                  }
                                },
                                child: Image.network(
                                  currentGif!.images!.original!.url,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text('')
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: imageFileList.isNotEmpty,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: smallGridElements(),
                  ),
                ),
                Visibility(
                  visible: imageFileList.isEmpty,
                  child: Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
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
                              _pickVideo();
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
                      _pickVideo();
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
        currentGif = gif;
        hasGifSelected = true;
        hasPhotos = false;
        postNotEmpty = false;
        hasVideos = false;
        selectedColor = Color(0xFFFFFFFF);
        imageFileList = [new File(currentGif!.images!.original!.url)];
      });
    }
  }

  Future uploadImages() async {
    if (imageFileList.length == 1 && hasPhotos) {
      var response = await _fileService.uploadSingleFile(
        imageFileList[0].path,
        getRandomString(20).toLowerCase(),
      );
      if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
        urlPhotos.add(response.secureUrl!);
        ImageModel userImage = ImageModel(
          userId: MyAppState.currentUser!.userID,
          profilePicture: '',
        );
        await _fileService.addUserImageFile(userImage, response.secureUrl!);
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
          ImageModel userImage = ImageModel(
            userId: MyAppState.currentUser!.userID,
            profilePicture: '',
          );
          await _fileService.addUserImageFile(userImage, response.secureUrl!);
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
  }

  Future _publishPostWithVideo(BuildContext context) async {
    Post post = Post(
      author: MyAppState.currentUser,
      authorId: MyAppState.currentUser!.userID,
      username: MyAppState.currentUser!.username,
      email: MyAppState.currentUser!.email,
      avatarColor: MyAppState.currentUser!.avatarColor,
      profilePicture: MyAppState.currentUser!.profilePictureURL,
      bgColor: _bgColor,
      post: _postController.text.trim(),
      gifUrl: '',
      privacy: PostAudienceDropdownState.chosenValue,
      postMedia: [],
      postVideo: [mediaFiles],
    );
    MyAppState.reduxStore!.dispatch(CreatedPostAction(post));
    Navigator.pop(context);
  }

  Future<void> _publishPost(BuildContext context) async {
    setState(() {
      postNotEmpty = true;
    });
    LoadingOverlay.of(context).show();
    try {
      await uploadImages();

      Post post = Post(
        author: MyAppState.currentUser,
        authorId: MyAppState.currentUser!.userID,
        username: MyAppState.currentUser!.username,
        email: MyAppState.currentUser!.email,
        avatarColor: MyAppState.currentUser!.avatarColor,
        profilePicture: MyAppState.currentUser!.profilePictureURL,
        bgColor: _bgColor,
        post: _postController.text.trim(),
        gifUrl: currentGif != null ? currentGif!.images!.original!.url : '',
        privacy: PostAudienceDropdownState.chosenValue,
        postMedia: urlPhotos,
        postVideo: [],
      );

      String? errorMessage = await _postService.publishPost(post);
      LoadingOverlay.of(context).hide();
      if (errorMessage == null) {
        _postController.clear();
        Navigator.pop(context);
      } else {
        setState(() {
          postNotEmpty = false;
        });
      }
    } catch (e) {
      print(e);
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

  void _viewOrDeleteImage(MapEntry<String, File> mediaEntry, int index) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        Column(
          children: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                mediaFiles.removeWhere((key, value) => value == mediaEntry.value);
                imageFileList.removeAt(index);
                setState(() {});
                if (imageFileList.length == 0) {
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
              currentGif = null;
              hasGifSelected = false;
              imageFileList = [];
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
                imageUrl: 'preview',
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
      message: Text(
        "Add image to post",
        style: TextStyle(fontSize: 16.0),
      ),
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

              if (result != null && result.files.isNotEmpty) {
                List<File> files = result.paths.map((path) => File(path!)).toList();
                imageFileList = files;
                for (int i = 0; i < files.length; i++) {
                  mediaFiles.remove('null');
                  mediaFiles['image ${files[i].path}'] = File(files[i].path);
                }
                setState(() {
                  hasPhotos = true;
                  postNotEmpty = true;
                  hasVideos = false;
                  selectedColor = Color(0xFFFFFFFF);
                });
              } else {
                setState(() {
                  hasPhotos = false;
                  postNotEmpty = postNotEmpty ? true : false;
                  hasVideos = false;
                  hasGifSelected = false;
                  selectedColor = Color(0xFFFFFFFF);
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

  void _pickVideo() {
    final action = CupertinoActionSheet(
      message: Text(
        "Add video to post",
        style: TextStyle(fontSize: 16.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Choose from gallery"),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            try {
              imageFileList.clear();
              mediaFiles.clear();
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.video,
                allowMultiple: false,
              );

              if (result != null && result.files.isNotEmpty) {
                List<File> files = result.paths.map((path) => File(path!)).toList();
                if (files.isEmpty) return;
                var newFilePath = await changeFileNameOnly(
                  File(files[0].path),
                  getRandomString(20).toLowerCase(),
                );
                String? videoThumbnail = await VideoThumbnail.thumbnailFile(
                  video: newFilePath.path,
                  thumbnailPath: (await getTemporaryDirectory()).path,
                  imageFormat: ImageFormat.PNG,
                );
                imageFileList.add(File(videoThumbnail!));
                mediaFiles.remove('null');
                mediaFiles[videoThumbnail] = File(newFilePath.path);
                setState(() {
                  hasPhotos = true;
                  postNotEmpty = true;
                  hasVideos = true;
                  selectedColor = Color(0xFFFFFFFF);
                });
              } else {
                setState(() {
                  hasPhotos = false;
                  postNotEmpty = postNotEmpty ? true : false;
                  hasVideos = false;
                  hasGifSelected = false;
                  selectedColor = Color(0xFFFFFFFF);
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
  @override
  PostAudienceDropdownState createState() => PostAudienceDropdownState();
}

class PostAudienceDropdownState extends State<PostAudienceDropdown> {
  static String chosenValue = 'Public';
  List<String> _listItems = [
    'Public',
    'Followers',
    'Private',
  ];

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
