import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/ui/posts/widgets/post_helper_widgets.dart';
import 'package:kick_chat/ui/posts/widgets/shared_post_container.dart';
import 'package:kick_chat/ui/posts/widgets/video_display_widget.dart';
import 'package:kick_chat/ui/widgets/full_screen_image_viewer.dart';
import 'package:kick_chat/ui/widgets/expanded_text.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// this widget is used for when notification for shared post is clicked.
class NotificationPost extends StatefulWidget {
  final Post post;
  final String username;
  final String imageUrl;
  final String reaction;

  const NotificationPost({
    Key? key,
    required this.post,
    this.username = '',
    this.imageUrl = '',
    this.reaction = '',
  }) : super(key: key);

  @override
  NotificationPostState createState() => NotificationPostState();
}

class NotificationPostState extends State<NotificationPost> {
  PostService _postService = PostService();
  int displayedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.greyWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Your post',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: ColorPalette.greyWhite),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4),
              physics: ScrollPhysics(),
              itemCount: 1,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildPostWidget(widget.post);
              },
            ),
          ),
          SizedBox(height: 20),
          widget.reaction != '' && widget.username != '' ? _buildReactionWIdget() : SizedBox.shrink(),
        ],
      ),
    );
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

  _buildReactionWIdget() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: displayCircleImage(widget.imageUrl, 40, true),
        title: Row(
          children: [
            Text(
              '${widget.username} reacted on your post with',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 4),
            Image.asset(
              'assets/images/${widget.reaction}.png',
              height: 19,
              width: 19,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
