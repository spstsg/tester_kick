import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/created_post_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/ui/posts/create_post_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CreatePostContainer extends StatefulWidget {
  @override
  State<CreatePostContainer> createState() => _CreatePostContainerState();
}

class _CreatePostContainerState extends State<CreatePostContainer> {
  FileService _fileService = FileService();
  PostService _postService = PostService();
  Post postWithVideo = Post();
  List mediaFilesURLs = [];
  String uploadText = 'Uploading...';
  bool isCreated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      MyAppState.reduxStore!.onChange.listen((state) {
        if (state.createdPost.postVideo.isNotEmpty && !isCreated) {
          setState(() {
            postWithVideo = state.createdPost;
          });
          if (mounted) {
            uploadVideos(context);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      distinct: true,
      converter: (store) => store.state,
      builder: (context, state) {
        return Stack(
          children: [
            postContainer(state.user),
            state.createdPost.postVideo.isNotEmpty
                ? Container(
                    height: 150,
                    decoration: BoxDecoration(color: Color.fromRGBO(33, 150, 243, 0.8)),
                    child: Center(
                      child: ScalingText(
                        uploadText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Future uploadVideos(BuildContext context) async {
    try {
      File compressedVideo = await _fileService.compressVideo(
        context,
        postWithVideo.postVideo[0].entries.elementAt(0).value,
      );
      if (compressedVideo.path != '') {
        setState(() {
          uploadText = 'Finishing...';
        });
      }
      Map videoUrl = await _fileService.uploadPostVideo(
        context,
        getRandomString(28),
        postWithVideo.postVideo[0].entries.elementAt(0).value,
        File(postWithVideo.postVideo[0].entries.elementAt(0).key),
      );
      mediaFilesURLs.add(videoUrl);
      if (mediaFilesURLs.isEmpty) return;
      Post post = Post(
        authorId: MyAppState.currentUser!.userID,
        bgColor: '#ffffff',
        post: postWithVideo.post,
        gifUrl: '',
        privacy: PostAudienceDropdownState.chosenValue,
        postMedia: [],
        postVideo: mediaFilesURLs,
      );
      String? errorMessage = await _postService.publishPost(post);
      if (errorMessage == null) {
        dispatchEmptyPost(true);
      } else {
        dispatchEmptyPost(true);
        await showCupertinoAlert(
          context,
          'Error',
          'Creating post. Try again later.',
          'OK',
          '',
          '',
          false,
        );
      }
    } catch (e) {
      dispatchEmptyPost(true);
      await showCupertinoAlert(
        context,
        'Error',
        'Uploading video or creating post. Try again later.',
        'OK',
        '',
        '',
        false,
      );
    }
  }

  void dispatchEmptyPost(bool postCreated) {
    Post emptyPost = Post();
    mediaFilesURLs.clear();
    setState(() {
      uploadText = 'Uploading...';
      isCreated = postCreated;
      postWithVideo = Post();
      MyAppState.reduxStore!.dispatch(CreatedPostAction(emptyPost));
    });
  }

  Widget postContainer(User storeUser) {
    return Container(
      height: 150,
      child: Card(
        elevation: 0.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  dispatchEmptyPost(false);
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new CreatePostScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(top: 15, left: 10),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        imageUrl: storeUser.profilePictureURL.isNotEmpty
                            ? storeUser.profilePictureURL
                            : MyAppState.currentUser!.profilePictureURL,
                        username: MyAppState.currentUser!.username,
                        avatarColor: MyAppState.currentUser!.avatarColor,
                        radius: MyAppState.currentUser!.profilePictureURL != '' ? 20 : 45.0,
                        fontSize: 20,
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'What\'s on your mind?',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(height: 10.0, thickness: 0.5),
              SizedBox(height: 10),
              Container(
                height: 40.0,
                margin: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        dispatchEmptyPost(false);
                        Navigator.of(context).push(
                          new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return new CreatePostScreen(openImagePicker: true);
                            },
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      label: Text(
                        'Photo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          fontSize: 14,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue.shade100),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        dispatchEmptyPost(false);
                        Navigator.of(context).push(
                          new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return new CreatePostScreen(openGif: true);
                            },
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.gif,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ),
                      label: Text(
                        'Gif',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                          fontSize: 14,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.orange[100]),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.orange.shade100),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        dispatchEmptyPost(false);
                        Navigator.of(context).push(
                          new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return new CreatePostScreen(openVideoPicker: true);
                            },
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          MdiIcons.video,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                      label: Text(
                        'Video',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red[100]),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red.shade100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
