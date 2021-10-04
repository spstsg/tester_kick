import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kick_chat/models/conversation_model.dart';
import 'package:kick_chat/models/home_conversation_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/blocked/blocked_service.dart';
import 'package:kick_chat/services/chat/chat_service.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/chat/chat_screen.dart';
import 'package:kick_chat/ui/friends/friends_tab_screen.dart';
import 'package:kick_chat/ui/profile/ui/edit_profile.dart';
import 'package:kick_chat/ui/profile/ui/settings_screen.dart';
import 'package:kick_chat/ui/profile/widgets/profile_videos.dart';
import 'package:kick_chat/ui/widgets/loading_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/image_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/profile/widgets/profile_images.dart';
import 'package:kick_chat/ui/profile/widgets/profile_post.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ProfileScreen extends StatefulWidget {
  late final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserService _userService = UserService();
  FileService _fileService = FileService();
  FollowService _followService = FollowService();
  BlockedUserService _blockedUserService = BlockedUserService();
  ChatService _chatService = ChatService();
  late User user;
  late StreamController<bool> userExistStream;
  late Stream<User> _userDataStream;
  List<File> imageFileList = [];
  List<String> urlPhotos = [];
  String cloudinaryAppEndpoint = dotenv.get('CLOUDINARY_APP_ENDPOINT');
  bool _isFollowing = false;
  bool _isBlocked = false;
  int _followersCount = 0;
  int _followingCount = 0;

  Stream<bool> checkIfUserIsFollowed() async* {
    userExistStream = new StreamController<bool>();
    bool isFollowingThisUser = await _followService.isFollowingUser(MyAppState.currentUser!.userID, widget.user.userID);
    if (!userExistStream.isClosed) {
      userExistStream.sink.add(isFollowingThisUser);
    }
    yield* userExistStream.stream;
  }

  userIsFollowed() async {
    bool isFollowingThisUser = await _followService.isFollowingUser(MyAppState.currentUser!.userID, widget.user.userID);
    setState(() {
      _isFollowing = isFollowingThisUser;
    });
  }

  userIsBlocked() async {
    bool isUserBlocked = await _blockedUserService.validateIfUserBlocked(widget.user.userID);
    setState(() {
      _isBlocked = isUserBlocked;
    });
  }

  @override
  void initState() {
    user = widget.user;
    _userDataStream = _userService.getCurrentUserStream(widget.user.userID);
    _followersCount = user.followersCount;
    _followingCount = user.followingCount;
    userIsFollowed();
    userIsBlocked();
    super.initState();
  }

  @override
  void dispose() {
    userExistStream.close();
    _userService.disposeCurrentUserStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        toolbarHeight: 50,
        elevation: 0.0,
        leading: widget.user.username != MyAppState.currentUser!.username
            ? IconButton(
                icon: Icon(
                  MdiIcons.chevronLeft,
                  size: 30,
                  color: ColorPalette.primary,
                ),
                onPressed: () {
                  MyAppState.reduxStore!.dispatch(CreateUserAction(MyAppState.currentUser!));
                  Navigator.pop(context);
                },
              )
            : Text(''),
        actions: [
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width / 8),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: ColorPalette.primary),
                    ),
                  ),
                  child: Text("View Best Eleven"),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new SettingScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Visibility(
                  visible: widget.user.username == MyAppState.currentUser!.username,
                  child: Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.settings,
                      color: ColorPalette.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StoreConnector<AppState, User>(
        converter: (store) => store.state.user,
        builder: (context, storeUser) {
          if (storeUser.userID == widget.user.userID) {
            widget.user.postCount = storeUser.postCount;
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: widget.user.bio.isNotEmpty ? 240 : 210,
                  child: Column(
                    children: <Widget>[
                      imageFileList.isNotEmpty ? profileImageSaveBtns() : SizedBox.shrink(),
                      SizedBox(height: imageFileList.isNotEmpty ? 0 : 10),
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 70,
                              width: 70,
                              child: ProfileAvatar(
                                imageUrl: imageFileList.isEmpty ? widget.user.profilePictureURL : imageFileList[0],
                                username: widget.user.username,
                                avatarColor: widget.user.avatarColor,
                                showIcon:
                                    widget.user.username == MyAppState.currentUser!.username && imageFileList.isEmpty,
                                radius: 70,
                                fontSize: 30,
                                onPressed: () => selectImage(),
                              ),
                            ),
                            SizedBox(width: 15),
                            StreamBuilder<bool>(
                              stream: checkIfUserIsFollowed(),
                              initialData: _isFollowing,
                              builder: (context, snapshot) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.user.username,
                                    style: TextStyle(
                                      color: ColorPalette.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  widget.user.username == MyAppState.currentUser!.username
                                      ? currentUserProfileBtns()
                                      : viewedUserProfileBtns(snapshot.data!)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: imageFileList.isNotEmpty ? 0 : 10),
                      Divider(),
                      widget.user.bio.isNotEmpty
                          ? ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 300),
                              child: Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                  widget.user.bio,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: ColorPalette.grey,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                      widget.user.bio.isNotEmpty ? Divider() : SizedBox.shrink(),
                      SizedBox(
                        height: widget.user.bio.isNotEmpty ? 5 : 0,
                      ),
                      StreamBuilder<User>(
                        stream: _userDataStream,
                        initialData: storeUser,
                        builder: (context, snapshot) {
                          _followersCount = snapshot.data!.followersCount;
                          _followingCount = snapshot.data!.followingCount;
                          return userProfileInfo(snapshot.data!.postCount);
                        },
                      ),
                      SizedBox(height: 10),
                      Divider(),
                    ],
                  ),
                ),
                Container(
                  child: DefaultTabController(
                    length: 3,
                    initialIndex: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          child: TabBar(
                            labelColor: ColorPalette.primary,
                            unselectedLabelColor: ColorPalette.grey,
                            tabs: [
                              Tab(icon: Icon(MdiIcons.grid)),
                              Tab(icon: Icon(MdiIcons.imageMultipleOutline)),
                              Tab(icon: Icon(MdiIcons.videoOutline)),
                            ],
                          ),
                        ),
                        Container(
                          height: 500,
                          child: TabBarView(
                            children: <Widget>[
                              storeUser.postCount > 0 || widget.user.postCount > 0
                                  ? ProfilePost(user: widget.user)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 150),
                                      child: Center(
                                        child: showEmptyState(
                                          'No posts found',
                                          'All posts will show up here',
                                        ),
                                      ),
                                    ),
                              ProfileImages(user: widget.user),
                              ProfileVideos(user: widget.user),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget profileImageSaveBtns() {
    return Row(
      children: [
        GestureDetector(
          onTap: imageFileList.isNotEmpty ? () => uploadFile(context) : null,
          child: Container(
            margin: EdgeInsets.only(left: 20, bottom: 5),
            child: Text(
              "SAVE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorPalette.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              imageFileList = [];
            });
          },
          child: Container(
            margin: EdgeInsets.only(left: 20, bottom: 5),
            child: Text(
              "CANCEL",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget currentUserProfileBtns() {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            push(
              context,
              EditProfileScreen(user: MyAppState.currentUser!),
            );
          },
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: ColorPalette.primary,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 10,
                right: 10,
              ),
              child: Text(
                "EDIT BIO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorPalette.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
        // Container(
        //   width: 120,
        //   decoration: BoxDecoration(
        //     color: Colors.red,
        //     borderRadius: BorderRadius.circular(10.0),
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.only(
        //       top: 5,
        //       bottom: 5,
        //       left: 10,
        //       right: 10,
        //     ),
        //     child: Text(
        //       "EDIT INTERESTS",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         color: ColorPalette.white,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 12,
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget viewedUserProfileBtns(bool snapshotData) {
    return Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              child: snapshotData
                  ? Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            User friend = widget.user;
                            ConversationModel? conversationModel = await _chatService.getSingleConversation(
                              MyAppState.currentUser!.userID,
                              friend.userID,
                            );
                            push(
                              context,
                              ChatScreen(
                                homeConversationModel: HomeConversationModel(
                                  members: [widget.user],
                                  conversationModel: conversationModel,
                                ),
                                user: widget.user,
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: !_isBlocked ? ColorPalette.primary : ColorPalette.greyWhite,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                                left: 10,
                                right: 10,
                              ),
                              child: Text(
                                "MESSAGE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorPalette.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 25,
                          margin: EdgeInsets.only(bottom: 4, left: 20),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                _followService.unFollowUser(MyAppState.currentUser!.userID, widget.user.userID);
                                MyAppState.reduxStore!.dispatch(CreateUserAction(widget.user));
                                setState(() {
                                  _followersCount--;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Cannot unfollow user. Try again later.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              MdiIcons.accountCheckOutline,
                              color: ColorPalette.primary,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () async {
                        if (!_isBlocked) {
                          try {
                            _followService.followUser(MyAppState.currentUser!, widget.user);
                            MyAppState.reduxStore!.dispatch(CreateUserAction(widget.user));
                            setState(() {
                              _followersCount++;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error following user. Try again later.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: !_isBlocked ? ColorPalette.primary : ColorPalette.greyWhite,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 10,
                            right: 10,
                          ),
                          child: Text(
                            "FOLLOW",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorPalette.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
        SizedBox(width: 5),
        blockAndUnblockButtons()
      ],
    );
  }

  Widget blockAndUnblockButtons() {
    return Row(
      children: <Widget>[
        !_isBlocked
            ? GestureDetector(
                onTap: () async {
                  if (widget.user.userID != MyAppState.currentUser!.userID) {
                    bool isSuccessful = await _blockedUserService.blockUser(MyAppState.currentUser!, widget.user);
                    if (!isSuccessful) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Couldn\'t block ${widget.user.username}. Try again later.',
                          ),
                        ),
                      );
                    } else {
                      MyAppState.reduxStore!.dispatch(CreateUserAction(widget.user));
                      setState(() {
                        _isBlocked = !_isBlocked;
                      });
                    }
                  }
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(color: Colors.red),
                  margin: EdgeInsets.only(left: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 10,
                      right: 10,
                    ),
                    child: Text(
                      "BLOCK",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorPalette.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () async {
                  try {
                    _blockedUserService.unblockUser(MyAppState.currentUser!, widget.user);
                    MyAppState.reduxStore!.dispatch(CreateUserAction(widget.user));
                    setState(() {
                      _isBlocked = !_isBlocked;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Couldn\'t unblock ${widget.user.username}. Try again later.',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 25,
                  margin: EdgeInsets.only(bottom: 4, left: 10),
                  child: Icon(
                    MdiIcons.accountOffOutline,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
      ],
    );
  }

  Widget userProfileInfo(int postCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              NumberFormat.compact().format(postCount),
              style: TextStyle(
                color: ColorPalette.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Posts",
              style: TextStyle(
                color: ColorPalette.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            push(
              context,
              FriendsTabScreen(
                tabIndex: 0,
                user: widget.user.userID == MyAppState.currentUser!.userID ? MyAppState.currentUser! : widget.user,
              ),
            );
          },
          child: Column(
            children: <Widget>[
              Text(
                NumberFormat.compact().format(_followingCount),
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Following",
                style: TextStyle(
                  color: ColorPalette.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            push(context, FriendsTabScreen(tabIndex: 1, user: widget.user));
          },
          child: Column(
            children: <Widget>[
              Text(
                NumberFormat.compact().format(_followersCount),
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Followers",
                style: TextStyle(
                  color: ColorPalette.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void selectImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        imageFileList.add(File(file.path as String));
      }
      setState(() {});
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(BuildContext context) async {
    LoadingOverlay.of(context).show();
    try {
      final profileUrlImage = await convertSocialProfileUrlToImage(widget.user.profilePictureURL);
      var uploadResponse = await _fileService.uploadSingleFile(
        profileUrlImage.path,
        getRandomString(20).toLowerCase(),
      );
      if (uploadResponse.isSuccessful && uploadResponse.secureUrl!.isNotEmpty) {
        var response = await _fileService.uploadSingleFile(
          imageFileList[0].path,
          MyAppState.currentUser!.username.toLowerCase(),
          true,
          true,
        );

        if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
          ImageModel userImage = ImageModel(
            userId: MyAppState.currentUser!.userID,
            profilePicture: '$cloudinaryAppEndpoint/${response.publicId}',
          );
          await _fileService.addUserImageFile(userImage, uploadResponse.secureUrl!);
          if (MyAppState.currentUser!.defaultImage) {
            _userService.updateDefaultImageProp(false);
          }

          LoadingOverlay.of(context).hide();
          setState(() {
            imageFileList = [];
          });
          await showCupertinoAlert(
            context,
            'Alert',
            'The added profile picture will take some time to propagate. You can continue using the app.',
            'OK',
            '',
            '',
            false,
          );
        }
      }
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
}
