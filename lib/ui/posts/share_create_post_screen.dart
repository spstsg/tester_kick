import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/ui/posts/widgets/shared_post_container.dart';
import 'package:kick_chat/ui/widgets/loading_overlay.dart';

class SharePostWithinAppScreen extends StatefulWidget {
  final Post post;
  SharePostWithinAppScreen({required this.post});

  @override
  SharePostWithinAppScreenState createState() => SharePostWithinAppScreenState();
}

class SharePostWithinAppScreenState extends State<SharePostWithinAppScreen> {
  TextEditingController _postController = TextEditingController();

  PostService _postService = PostService();

  @override
  void initState() {
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
      backgroundColor: ColorPalette.greyWhite,
      appBar: AppBar(
        title: Text(
          'Share Post',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _sharePost(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  'Post',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: ColorPalette.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Card(
              elevation: 0.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: new BoxConstraints(maxHeight: 200.0),
                      child: Container(
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 10,
                          controller: _postController,
                          // onChanged: (text) {
                          //   setState(() {
                          //     postNotEmpty = text.length > 0 ? true : false;
                          //   });
                          // },
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[900],
                          ),
                          decoration: new InputDecoration(
                            filled: true,
                            isDense: true,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 20,
                            ),
                            hintText: "Say something about this post...",
                            fillColor: ColorPalette.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          SharedPostContainer(post: widget.post)
        ],
      ),
    );
  }

  Future<void> _sharePost(BuildContext context) async {
    LoadingOverlay.of(context).show();
    try {
      SharedPost sharedPost = SharedPost(
        id: widget.post.id,
        authorId: widget.post.authorId,
        bgColor: widget.post.bgColor,
        createdAt: widget.post.createdAt,
        post: widget.post.post,
        gifUrl: widget.post.gifUrl,
        postMedia: widget.post.postMedia,
        postVideo: widget.post.postVideo,
        reactions: widget.post.reactions,
      );

      Post post = Post(
        authorId: MyAppState.currentUser!.userID,
        bgColor: '#ffffff',
        post: _postController.text.trim(),
        gifUrl: '',
        privacy: 'Public',
        postMedia: [],
        postVideo: [],
        sharedPost: sharedPost,
      );
      String? errorMessage = await _postService.publishPost(post);
      LoadingOverlay.of(context).hide();
      if (errorMessage == null) {
        _postController.clear();
        Navigator.pop(context);
      }
    } catch (e) {
      LoadingOverlay.of(context).hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating post. Try again.'),
        ),
      );
    }
  }
}
