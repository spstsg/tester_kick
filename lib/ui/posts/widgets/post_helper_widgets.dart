import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
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
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:kick_chat/ui/widgets/share_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

  PostStats({
    required this.post,
  });

  @override
  PostStatsState createState() => PostStatsState();
}

class PostStatsState extends State<PostStats> {
  // ReactionService _reactionService = ReactionService();
  String postTypeReaction = '';
  String previousReaction = '';

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();

    var addedPostReactions = getAddedPostReactions(widget.post.reactions);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.post.reactionsCount > 0
                ? Container(
                    child: Row(
                      children: List.generate(addedPostReactions.length, (index) {
                        return buildReactionsIconDisplay(addedPostReactions[index]);
                      }),
                    ),
                  )
                : Text(''),
            SizedBox(width: 4.0, height: 30.0),
            Expanded(
              child: widget.post.reactionsCount > 0
                  ? Text(
                      NumberFormat.compact().format(widget.post.reactionsCount),
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontSize: 16,
                      ),
                    )
                  : Text(''),
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
                : Container(),
          ],
        ),
        widget.post.reactionsCount > 0 || widget.post.commentsCount > 0 ? Divider() : Container(),
        // Row(
        //   children: [
        //     Container(
        //       padding: EdgeInsets.symmetric(horizontal: 1.0),
        //       height: 25.0,
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: skipNulls([
        //           SizedBox(
        //             width: MediaQuery.of(context).size.width * .2,
        //             child: FutureBuilder<List<Reactions>>(
        //               future: PostContainerState.myReactions,
        //               builder: (context, snapshot) {
        //                 if (snapshot.hasData) {
        //                   Reactions _postReaction;
        //                   if (snapshot.data!.isNotEmpty) {
        //                     _postReaction = PostContainerState.reactionsList.firstWhere(
        //                         (element) => element.postId == widget.post.id, orElse: () {
        //                       return Reactions(
        //                           postId: '',
        //                           username: '',
        //                           type: '',
        //                           avatarColor: '',
        //                           profilePicture: '');
        //                     });

        //                     if (_postReaction.type != '') {
        //                       widget.post.myReaction = postReactionType(
        //                         _postReaction.type,
        //                       );
        //                     }
        //                   }
        //                   return FlutterReactionButtonCheck(
        //                     onReactionChanged: (reaction, index, isChecked) {
        //                       if (index > -1) {
        //                         String reactionString =
        //                             _reactionService.getReactionString(index + 1);

        //                         setState(() {
        //                           postTypeReaction = reactionString;
        //                           widget.post.myReaction = postReactionsList[index];
        //                         });
        //                       }
        //                       if (isChecked) {
        //                         bool isNewReaction = false;
        //                         Reactions postReaction =
        //                             PostContainerState.reactionsList.firstWhere(
        //                           (element) => element.postId == widget.post.id,
        //                           orElse: () {
        //                             isNewReaction = true;
        //                             String reactionString =
        //                                 _reactionService.getReactionString(index + 1);
        //                             setState(() {
        //                               postTypeReaction = reactionString;
        //                             });
        //                             Reactions newReaction = Reactions(
        //                               postId: widget.post.id,
        //                               createdAt: Timestamp.now(),
        //                               reactionAuthorId: MyAppState.currentUser!.userID,
        //                               type: reactionString,
        //                               username: MyAppState.currentUser!.username,
        //                               avatarColor: MyAppState.currentUser!.avatarColor,
        //                               profilePicture: MyAppState.currentUser!.profilePictureURL,
        //                             );
        //                             PostContainerState.reactionsList.add(newReaction);
        //                             return newReaction;
        //                           },
        //                         );
        //                         setState(() {
        //                           previousReaction = postReaction.type;
        //                         });
        //                         if (isNewReaction) {
        //                           setState(() {
        //                             widget.post.reactionsCount++;
        //                           });
        //                           _reactionService.postReaction(
        //                             postReaction,
        //                             widget.post,
        //                           );
        //                         } else {
        //                           postReaction.type = _reactionService.getReactionString(index + 1);
        //                           postReaction.createdAt = Timestamp.now();
        //                           _reactionService.updateReaction(
        //                             postReaction,
        //                             widget.post,
        //                             previousReaction,
        //                           );
        //                         }
        //                       } else {
        //                         var postReaction = PostContainerState.reactionsList
        //                             .firstWhere((element) => element.postId == widget.post.id);
        //                         PostContainerState.reactionsList.removeWhere(
        //                           (element) => element.postId == widget.post.id,
        //                         );
        //                         setState(() {
        //                           widget.post.reactionsCount--;
        //                         });
        //                         _reactionService.removeReaction(
        //                           widget.post,
        //                           postReaction.type,
        //                         );
        //                         setState(() {
        //                           widget.post.myReaction = postReactionsList[0];
        //                         });
        //                       }
        //                     },
        //                     isChecked: _reactionService.getReactionIndex(postTypeReaction) != 1,
        //                     reactions: postReactionsList,
        //                     initialReaction: widget.post.myReaction,
        //                     selectedReaction:
        //                         _reactionService.getReactionIndex(postTypeReaction) != 1
        //                             ? postReactionsList[
        //                                 _reactionService.getReactionIndex(postTypeReaction) - 1]
        //                             : postReactionsList[0],
        //                   );
        //                 } else {
        //                   return Container();
        //                 }
        //               },
        //             ),
        //           ),
        //         ]),
        //       ),
        //     ),
        //     VerticalDivider(width: 20.0),
        //     Flexible(
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 30),
        //         child: TextField(
        //           onTap: () {
        //             Navigator.of(context).push(
        //               new MaterialPageRoute<Null>(
        //                 builder: (BuildContext context) {
        //                   return PostCommentsScreen(post: widget.post);
        //                 },
        //                 fullscreenDialog: true,
        //               ),
        //             );
        //           },
        //           decoration: InputDecoration.collapsed(
        //             hintText: 'Add comment here...',
        //             hintStyle: TextStyle(
        //               color: ColorPalette.grey,
        //               fontSize: 17,
        //             ),
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      ],
    );
  }

  dynamic getAddedPostReactions(PostReactions reactions) {
    List reactionsList = [];
    reactions.toJson().forEach((k, v) {
      if (v > 0) {
        reactionsList.add(k);
      }
    });
    return reactionsList;
  }

  Reaction postReactionType(type) {
    switch (type) {
      case 'like':
        return Reaction(
          title: buildTitle('Like'),
          previewIcon: buildPreviewIcon('assets/images/likes.gif'),
          icon: buildReactionsIcon(
            'assets/images/likes_btn_1.png',
            Text(
              'Like',
              style: TextStyle(
                color: Color(0XFF50b5ff),
              ),
            ),
          ),
        );
      case 'love':
        return Reaction(
          title: buildTitle('Love'),
          previewIcon: buildPreviewIcon('assets/images/love.gif'),
          icon: buildReactionsIcon(
            'assets/images/love.png',
            Text(
              'Love',
              style: TextStyle(
                color: Color(0XFFf33e58),
              ),
            ),
          ),
        );
      case 'wow':
        return Reaction(
          title: buildTitle('Wow'),
          previewIcon: buildPreviewIcon('assets/images/wow.gif'),
          icon: buildReactionsIcon(
            'assets/images/wow.png',
            Text(
              'Wow',
              style: TextStyle(
                color: Color(0XFFf7b124),
              ),
            ),
          ),
        );
      case 'haha':
        return Reaction(
          title: buildTitle('Haha'),
          previewIcon: buildPreviewIcon('assets/images/haha.gif'),
          icon: buildReactionsIcon(
            'assets/images/haha.png',
            Text(
              'Haha',
              style: TextStyle(
                color: Color(0XFFf7b124),
              ),
            ),
          ),
        );
      case 'sad':
        return Reaction(
          title: buildTitle('Sad'),
          previewIcon: buildPreviewIcon('assets/images/sad.gif'),
          icon: buildReactionsIcon(
            'assets/images/sad.png',
            Text(
              'Sad',
              style: TextStyle(
                color: Color(0XFFffda6b),
              ),
            ),
          ),
        );
      case 'angry':
        return Reaction(
          title: buildTitle('Angry'),
          previewIcon: buildPreviewIcon('assets/images/angry.gif'),
          icon: buildReactionsIcon(
            'assets/images/angry.png',
            Text(
              'Angry',
              style: TextStyle(
                color: Color(0XFFe9710f),
              ),
            ),
          ),
        );
      default:
        return Reaction(
          title: buildTitle('Like'),
          previewIcon: buildPreviewIcon('assets/images/likes.gif'),
          icon: buildReactionsIcon(
            'assets/images/likes_btn_1.png',
            Text(
              'Like',
              style: TextStyle(
                color: Color(0XFF50b5ff),
              ),
            ),
          ),
        );
    }
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
