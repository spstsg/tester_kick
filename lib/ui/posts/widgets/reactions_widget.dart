import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/services/reactions/reactions_service.dart';
import 'package:kick_chat/ui/posts/widgets/post_helper_widgets.dart';

class ReactionsWidget extends StatefulWidget {
  final ReactionDisplay reactions;
  final Post post;
  ReactionsWidget({required this.reactions, required this.post});

  @override
  _ReactionsWidgetState createState() => _ReactionsWidgetState();
}

class _ReactionsWidgetState extends State<ReactionsWidget> {
  ReactionService _reactionService = ReactionService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () async {
          addReaction();
        },
        child: Row(
          children: <Widget>[
            Image.asset(
              'assets/images/${widget.reactions.name}.png',
              height: 15,
              width: 15,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                NumberFormat.compact().format(widget.reactions.size),
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addReaction() async {
    Map postReactions = widget.post.reactions;
    dynamic myReactions = await _reactionService.getMyReactions(widget.post.id);
    var reactionKey = myReactions.keys.firstWhere((k) => myReactions[k] == 1, orElse: () => null);
    if (reactionKey != null && reactionKey == widget.reactions.name) {
      myReactions['${reactionKey}'] -= 1;
      _reactionService.removeReaction(widget.post, reactionKey);
    }
    if (reactionKey == null) {
      postReactions['${widget.reactions.name}'] += 1;
      _reactionService.postReaction(
        postReactions,
        widget.reactions.name,
        widget.post,
      );
    } else if (reactionKey != null && reactionKey != widget.reactions.name) {
      myReactions['${reactionKey}'] -= 1;
      myReactions['${widget.reactions.name}'] += 1;
      _reactionService.updateReaction(myReactions, widget.post, widget.reactions.name, reactionKey);
    }
  }
}
