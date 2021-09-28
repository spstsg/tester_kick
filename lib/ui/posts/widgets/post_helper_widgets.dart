import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/posts/edit_post_screen.dart';
import 'package:kick_chat/ui/posts/post_comments_screen.dart';
import 'package:kick_chat/ui/posts/share_create_post_screen.dart';
import 'package:kick_chat/ui/posts/widgets/reactions_widget.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:kick_chat/ui/widgets/share_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ReactionDisplay {
  final String name;
  final int size;

  ReactionDisplay(this.name, this.size);
}

class PostHeader extends StatelessWidget {
  final Post post;
  final displayedImageIndex;
  final screenshotController;
  final bool showElements;

  PostHeader({
    required this.post,
    this.displayedImageIndex,
    this.screenshotController,
    this.showElements = false,
  });

  @override
  Widget build(BuildContext context) {
    PostService postService = PostService();
    UserService _userService = UserService();

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: post.profilePicture,
            username: post.username,
            avatarColor: post.avatarColor,
            radius: post.profilePicture != '' ? 20 : 45.0,
            fontSize: 20,
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (post.author.userID != MyAppState.currentUser!.userID) {
                      User? user = await _userService.getCurrentUser(post.author.userID);
                      MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
                      push(context, ProfileScreen(user: user));
                    }
                  },
                  child: Text(
                    post.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: ColorPalette.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: Icon(
                        MdiIcons.clockOutline,
                        color: ColorPalette.grey,
                        size: 14.0,
                      ),
                    ),
                    Text(
                      dateTimeAgo(post.createdAt),
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          showElements
              ? Expanded(
                  child: PostSharePopMenu(
                    post: post,
                    displayedImageIndex: displayedImageIndex,
                    screenshotController: screenshotController,
                  ),
                )
              : post.username == MyAppState.currentUser!.username
                  ? Container(
                      child: Row(
                        children: [
                          IconButton(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(top: 8),
                            onPressed: () {
                              Navigator.of(context).push(
                                new MaterialPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return EditPostScreen(post: post);
                                  },
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            icon: Icon(MdiIcons.pencil, color: ColorPalette.primary),
                          ),
                          IconButton(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(top: 8),
                            onPressed: () async {
                              bool proceed = await showCupertinoAlert(
                                context,
                                'Delete Post',
                                'Are you sure you want to delete this post?',
                                'Delete',
                                'Cancel',
                                true,
                              );
                              if (!proceed) {
                                return;
                              } else {
                                try {
                                  await postService.deletePost(post);
                                } on Exception catch (e) {
                                  print(e);
                                }
                              }
                            },
                            icon: Icon(MdiIcons.trashCan, color: Colors.red),
                          ),
                        ],
                      ),
                    )
                  : Container(),
        ],
      ),
    );
  }
}

class PostStats extends StatefulWidget {
  final Post post;

  PostStats({required this.post});

  @override
  PostStatsState createState() => PostStatsState();
}

class PostStatsState extends State<PostStats> {
  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    List reactionsData = widget.post.reactions.entries.map((entry) => ReactionDisplay(entry.key, entry.value)).toList();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                children: List.generate(reactionsData.length, (index) {
                  return ReactionsWidget(reactions: reactionsData[index], post: widget.post);
                }),
              ),
            ),
            SizedBox(height: 30.0),
          ],
        ),
        Divider(),
        Row(
          children: [
            widget.post.postVideo.isNotEmpty && widget.post.postVideo[0]['count'] > 0
                ? Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(NumberFormat.compact().format(widget.post.postVideo[0]['count'])),
                        SizedBox(width: 20),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  onTap: () {
                    Navigator.of(context).push(
                      new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return PostCommentsScreen(post: widget.post);
                        },
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Add comment here...',
                    hintStyle: TextStyle(
                      color: ColorPalette.grey,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
            widget.post.commentsCount > 0
                ? Container(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return PostCommentsScreen(post: widget.post);
                            },
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(
                              MdiIcons.commentOutline,
                              color: ColorPalette.primary,
                              size: 22.0,
                            ),
                          ),
                          Text(
                            NumberFormat.compact().format(widget.post.commentsCount),
                            style: TextStyle(
                              color: ColorPalette.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ],
    );
  }
}

class PostSharePopMenu extends StatefulWidget {
  final Post post;
  final displayedImageIndex;
  final screenshotController;

  PostSharePopMenu({required this.post, this.displayedImageIndex, this.screenshotController});

  @override
  PostSharePopMenuState createState() => PostSharePopMenuState();
}

class PostSharePopMenuState extends State<PostSharePopMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton(
        shape: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        onSelected: (result) async {
          if (result == 2) {
            if (widget.post.bgColor != '#ffffff') {
              final image = await widget.screenshotController.capture();
              if (image == null) return;
              final isSaved = await saveImageToGallery(image);
              if (isSaved) {
                Navigator.of(context).push(
                  new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return ShareOutsideWidget(post: widget.post, screenshot: image);
                    },
                    fullscreenDialog: true,
                  ),
                );
              }
            } else {
              Navigator.of(context).push(
                new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return ShareOutsideWidget(
                      post: widget.post,
                      displayedImageIndex: widget.displayedImageIndex,
                    );
                  },
                  fullscreenDialog: true,
                ),
              );
            }
          } else {
            Navigator.of(context).push(
              new MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return SharePostWithinAppScreen(post: widget.post);
                },
                fullscreenDialog: true,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
                children: [
                  WidgetSpan(
                    child: Icon(
                      MdiIcons.shareOutline,
                      size: 20,
                      color: ColorPalette.primary,
                    ),
                  ),
                  TextSpan(
                    text: 'Share',
                    style: TextStyle(
                      color: ColorPalette.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.post.shareCount > 0
                    ? Text(
                        widget.post.shareCount == 1
                            ? '${widget.post.shareCount} Share'
                            : '${widget.post.shareCount} Shares',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      )
                    : Text(''),
              ],
            ),
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          const PopupMenuItem(
            value: 1,
            child: Text('Share within app'),
          ),
          const PopupMenuItem(
            value: 2,
            child: Text('Share outside app'),
          ),
        ],
      ),
    );
  }
}
