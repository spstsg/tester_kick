import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/comment_model.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';
import 'package:kick_chat/ui/posts/widgets/post_comments_skeleton.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

class PostCommentsScreen extends StatefulWidget {
  final Post post;
  final String commentId;

  const PostCommentsScreen({Key? key, required this.post, this.commentId = ''}) : super(key: key);

  @override
  _PostCommentsScreenState createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  PostService _postService = PostService();
  late Future<List<Comment>> _commentsFuture;
  List<Comment> newlyAddedComment = [];
  TextEditingController _commentController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0);
    _commentsFuture = _postService.getPostComments(widget.post);
    addComments();
    if (mounted) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
    newlyAddedComment = [];
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: _buildComment(),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 80.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: TextField(
                onChanged: (s) {
                  setState(() {});
                },
                controller: _commentController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 20),
                  hintText: 'Add a comment',
                  suffixIcon: Container(
                    margin: EdgeInsets.only(right: 15.0),
                    width: 35.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        primary: Colors.transparent,
                      ),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          _postComment(_commentController.text, widget.post);
                          _commentController.clear();
                        }
                      },
                      child: Icon(
                        Icons.send,
                        size: 25.0,
                        color: _commentController.text.length == 0
                            ? ColorPalette.primary.withOpacity(.5)
                            : ColorPalette.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComment() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: FutureBuilder<List<Comment>>(
        future: _commentsFuture,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && newlyAddedComment.length == 0) {
            return PostCommentsSkeleton();
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: showEmptyState('No comments yet', 'Add a new comment now!')),
              ),
            );
          } else {
            snapshot.data!.sort((a, b) => a.createdAt.compareTo(b.createdAt));

            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Comment comment = snapshot.data![index];
                return Column(
                  children: [
                    ListTile(
                      tileColor:
                          widget.commentId != '' && comment.commentId == widget.commentId ? Colors.blue.shade100 : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      leading: Container(
                        width: 40,
                        child: ProfileAvatar(
                          imageUrl: comment.author!.profilePictureURL,
                          username: comment.author!.username,
                          avatarColor: comment.author!.avatarColor,
                          radius: comment.author!.profilePictureURL != '' ? 20 : 45.0,
                          fontSize: 20,
                        ),
                      ),
                      title: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          comment.author!.username,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      subtitle: Text(comment.commentText, style: TextStyle(fontSize: 15)),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  void addComments() async {
    newlyAddedComment = await _postService.getPostComments(widget.post);
  }

  void _scrollToBottom() async {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    await Future.delayed(Duration(milliseconds: 200));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _postComment(String comment, Post post) async {
    String uid = getRandomString(28);
    Comment newComment = Comment(
      authorId: MyAppState.currentUser!.userID,
      createdAt: Timestamp.now(),
      commentText: comment,
      postId: post.id,
      id: uid,
      commentId: uid,
    );
    _commentsFuture = Future.delayed(Duration(milliseconds: 200), () {
      _scrollToBottom();
      newComment.author = MyAppState.currentUser!;
      return addedComment(newComment);
    });
    await _postService.postComment(uid, newComment, post);
    FocusScope.of(context).unfocus();
  }

  List<Comment> addedComment(Comment newComment) {
    newlyAddedComment.add(newComment);
    return newlyAddedComment;
  }
}
