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
import 'package:kick_chat/ui/posts/create_post_screen.dart';
import 'package:kick_chat/ui/posts/widgets/post_helper_widgets.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';
import 'package:kick_chat/ui/posts/widgets/shared_post_container.dart';
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
  FollowService _followService = FollowService();
  BlockedUserService _blockedUserService = BlockedUserService();
  late Stream<List<Post>> _postsStream;
  late List<User> userFollowers = [];
  late List<User> blockedUsers = [];
  int displayedImageIndex = 0;
  bool noPosts = false;

  @override
  void initState() {
    super.initState();
    _postsStream = _postService.getPostsStream();
    _postService.getPosts()
      ..then((value) {
        noPosts = value.isEmpty;
      });

    _followService.getUserFollowings(MyAppState.currentUser!.userID).then((value) => {userFollowers = value});

    _blockedUserService.getBlockedByUsers(MyAppState.currentUser!.userID).then((value) => {blockedUsers = value});
  }

  @override
  void dispose() {
    _postService.disposePostsStream();
    super.dispose();
  }

  bool checkFollowing(String username) {
    var followers = userFollowers.firstWhere((element) => element.username == username, orElse: () => User());
    return followers.username.isNotEmpty;
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            noPosts = true;
            return Center(
              child: showEmptyState(
                'No Posts Found',
                'All posts will show up here',
                buttonTitle: 'Create new post',
                action: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new CreatePostScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            );
          } else {
            noPosts = false;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4),
              physics: NeverScrollableScrollPhysics(),
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

  _buildWidget(Post post) {
    if (post.username == MyAppState.currentUser!.username) {
      return _buildPostWidget(post);
    } else {
      if (blockedUsers.isEmpty) {
        if (post.privacy == 'Public') {
          return _buildPostWidget(post);
        }

        bool checkUserFollowing = checkFollowing(post.username);
        if (post.privacy == 'Followers' && checkUserFollowing) {
          return _buildPostWidget(post);
        }
      }
    }

    return SizedBox.shrink();
  }

  _buildPostWidget(Post post) {
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
}
