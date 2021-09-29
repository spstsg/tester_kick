import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/fullscreen_video_viewer.dart';

Widget videoDisplay(BuildContext context, Post post, Function updateVideoViewCount) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.25,
    decoration: BoxDecoration(
      color: Colors.black,
      image: post.postVideo[0]['videoThumbnail'] != null && post.postVideo[0]['videoThumbnail']!.isNotEmpty
          ? DecorationImage(
              fit: BoxFit.fill,
              image: Image.network(
                post.postVideo[0]['videoThumbnail']!,
              ).image)
          : null,
    ),
    child: Center(
      child: FloatingActionButton(
        child: Icon(CupertinoIcons.play_arrow_solid),
        backgroundColor: Colors.white54,
        heroTag: getRandomString(10),
        onPressed: () {
          if (post.authorId != MyAppState.currentUser!.userID) {
            updateVideoViewCount(post);
          }
          push(
            context,
            FullScreenVideoViewer(
              videoUrl: post.postVideo[0]['url'],
              heroTag: getRandomString(10),
            ),
          );
        },
      ),
    ),
  );
}
