import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/blocked/blocked_service.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/posts/widgets/post_helper_widgets.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';
import 'package:kick_chat/ui/posts/widgets/shared_post_container.dart';
import 'package:kick_chat/ui/posts/widgets/video_display_widget.dart';
import 'package:kick_chat/ui/widgets/full_screen_image_viewer.dart';
import 'package:kick_chat/ui/widgets/expanded_text.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostContainer extends StatefulWidget {
  @override
  PostContainerState createState() => PostContainerState();
}

class PostContainerState extends State<PostContainer> {
  PostService _postService = PostService();
  UserService _userService = UserService();
  FollowService _followService = FollowService();
  BlockedUserService _blockedUserService = BlockedUserService();
  StreamController<List<Post>> usersPostStream = StreamController.broadcast();
  List<User> userFollowers = [];
  List<User> blockedUsers = [];
  int displayedImageIndex = 0;
  List<Post> updatedPostList = [];
  bool loading = false;
  bool isLoaded = false;
  List<Post> fetchedPosts = [];
  late Stream<List<Post>> _postsStream;

  @override
  void initState() {
    if (!mounted) return;

    getAllPosts();
    _postsStream = usersPostStream.stream;

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _postService.getPostsStream().listen((event) async {
        if (isLoaded) {
          addAuthorToPost(event);
        }
      });
      getBlockedUsersAndFollowers();
    });
    super.initState();
  }

  @override
  void dispose() {
    _postService.disposePostsStream();
    usersPostStream.close();
    super.dispose();
  }

  Future<void> getAllPosts() async {
    List<Post> allPosts = await _postService.getPosts(4);
    addAuthorToPost(allPosts);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorPalette.greyWhite),
      child: StreamBuilder<List<Post>>(
        stream: _postsStream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PostSkeleton();
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Center(
              child: Container(
                height: MediaQuery.of(context).size.height - 170,
                child: showEmptyState(
                  'No posts found',
                  'All posts will show up here',
                  buttonTitle: 'Create new post',
                ),
              ),
            );
          } else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                isLoaded = true;
              });
            });
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4),
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildWidget(snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildWidget(Post post) {
    if (post.author!.username == MyAppState.currentUser!.username) {
      return _buildPostWidget(post);
    } else {
      if (blockedUsers.isEmpty) {
        if (post.privacy == 'Public') {
          return _buildPostWidget(post);
        }

        bool checkUserFollowing = checkFollowing(post.author!.username);
        if (post.privacy == 'Followers' && checkUserFollowing) {
          return _buildPostWidget(post);
        }
      }
    }

    return SizedBox.shrink();
  }

  Widget _buildPostWidget(Post post) {
    ScreenshotController screenshotController = ScreenshotController();
    PageController _controller = PageController(initialPage: 0);
    return Card(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: ColorPalette.grey, width: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 10, left: 15, right: 15),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PostHeader(
                  post: post,
                  displayedImageIndex: displayedImageIndex,
                  screenshotController: screenshotController,
                  showElements: true,
                ),
                post.post != ''
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          hexStringToColor(post.bgColor) == Color(0xffffffff)
                              ? ExpandableText(
                                  text: post.post,
                                  itemStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              : Screenshot(
                                  controller: screenshotController,
                                  child: Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints: new BoxConstraints(
                                          minHeight: 200.0,
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          padding: EdgeInsets.all(20),
                                          color: hexStringToColor(post.bgColor),
                                          child: ExpandableText(
                                            text: post.post,
                                            itemTextAlign: TextAlign.center,
                                            showColor: Colors.white,
                                            itemStyle: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 10.0)
                        ],
                      )
                    : SizedBox(height: 0.0),
              ],
            ),
            post.sharedPost.authorId != '' ? SharedPostContainer(post: post.sharedPost) : SizedBox.shrink(),
            post.postMedia.isNotEmpty && post.gifUrl == ''
                ? Container(
                    height: 350,
                    margin: EdgeInsets.only(bottom: 5),
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _controller,
                          onPageChanged: (itemIndex) {
                            setState(() {
                              displayedImageIndex = itemIndex;
                            });
                          },
                          itemCount: post.postMedia.length,
                          itemBuilder: (context, index) {
                            var postMedia = post.postMedia[index];
                            return GestureDetector(
                              onTap: () => push(
                                context,
                                FullScreenImageViewer(imageUrl: postMedia),
                              ),
                              child: displayImage(postMedia, 300),
                            );
                          },
                        ),
                        post.postMedia.length > 1
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SmoothPageIndicator(
                                    controller: _controller,
                                    count: post.postMedia.length,
                                    effect: ScrollingDotsEffect(
                                      dotWidth: 6,
                                      dotHeight: 6,
                                      dotColor: ColorPalette.primary,
                                      activeDotColor: ColorPalette.white,
                                    ),
                                  ),
                                ),
                              )
                            : Padding(padding: EdgeInsets.zero)
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            post.postVideo.isNotEmpty
                ? videoDisplay(context, post, _postService.updateVideoViewCount)
                : SizedBox.shrink(),
            post.postMedia.isEmpty && post.gifUrl != ''
                ? Container(
                    height: 250,
                    margin: EdgeInsets.only(bottom: 5),
                    child: Stack(
                      children: [
                        Container(child: displayImage(post.gifUrl, 500)),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: PostStats(post: post),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getBlockedUsersAndFollowers() async {
    List<User> followings = await _followService.getUserFollowings(MyAppState.currentUser!.userID);
    List<User> blockedByUsers = await _blockedUserService.getBlockedByUsers(MyAppState.currentUser!.userID);
    setState(() {
      blockedUsers = blockedByUsers;
      userFollowers = followings;
    });
  }

  Future<void> addAuthorToPost(List<Post> postList) async {
    updatedPostList.clear();
    for (var item in postList) {
      if (item.authorId == MyAppState.currentUser!.userID) {
        item.author = MyAppState.currentUser!;
      } else {
        User? author = await _userService.getCurrentUser(item.authorId);
        item.author = author;
      }
      if (item.sharedPost.authorId.isNotEmpty) {
        User? sharedPostAuthor = await _userService.getCurrentUser(item.sharedPost.authorId);
        item.sharedPost.author = sharedPostAuthor!;
      }
      if (item.author != null && !item.author!.deleted) {
        updatedPostList.add(item);
      }
    }
    if (!usersPostStream.isClosed) {
      usersPostStream.sink.add(updatedPostList);
    }
  }

  bool checkFollowing(String username) {
    var followers = userFollowers.firstWhere((element) => element.username == username, orElse: () => User());
    return followers.username.isNotEmpty;
  }
}
