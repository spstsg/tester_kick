import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/expanded_text.dart';
import 'package:kick_chat/ui/widgets/full_screen_image_viewer.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SharedPostContainer extends StatelessWidget {
  final SharedPost post;
  final VoidCallback? onDelete;

  SharedPostContainer({Key? key, required this.post, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildPostWidget(post),
    );
  }

  _buildPostWidget(dynamic post) {
    PageController _controller = PageController(
      initialPage: 0,
    );
    return Card(
      margin: post is Post ? EdgeInsets.only(top: 10, left: 10, right: 10) : EdgeInsets.zero,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: ColorPalette.grey, width: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: post is Post
            ? EdgeInsets.only(top: 12, bottom: 10, left: 15, right: 15)
            : EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PostHeader(post: post, onDelete: onDelete),
                SizedBox(height: 4.0),
                GestureDetector(
                  onTap: () {},
                  child: hexStringToColor(post.bgColor) == Color(0xffffffff)
                      ? ExpandableText(
                          text: post.post,
                          itemStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      : Column(
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
                SizedBox(height: 6.0)
              ],
            ),
            post.postMedia.isNotEmpty && post.gifUrl == ''
                ? Container(
                    height: 350,
                    margin: EdgeInsets.only(bottom: 5),
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _controller,
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
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final SharedPost post;
  final VoidCallback? onDelete;

  _PostHeader({
    required this.post,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: post.author != null ? post.author!.profilePictureURL : '',
            username: post.author != null ? post.author!.username : '',
            avatarColor: post.author != null ? post.author!.avatarColor : '',
            radius: post.author != null
                ? post.author!.profilePictureURL != ''
                    ? 20
                    : 45.0
                : 20.0,
            fontSize: 20,
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // 'Manny',
                  post.author != null ? post.author!.username : '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: ColorPalette.primary,
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
          onDelete != null
              ? Container(
                  child: Row(
                    children: [
                      IconButton(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(top: 8),
                        onPressed: onDelete,
                        icon: Icon(MdiIcons.trashCan, color: Colors.red),
                      ),
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
