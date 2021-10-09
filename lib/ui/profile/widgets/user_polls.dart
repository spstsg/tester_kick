import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/poll/poll_service.dart';
import 'package:kick_chat/ui/polls/widgets/poll_percentage.dart';
import 'package:kick_chat/ui/polls/widgets/poll_question.dart';
import 'package:kick_chat/ui/posts/widgets/post_skeleton.dart';

class UserPolls extends StatefulWidget {
  final User user;
  UserPolls({required this.user});

  @override
  _UserPollsState createState() => _UserPollsState();
}

class _UserPollsState extends State<UserPolls> {
  PollService _pollService = PollService();

  @override
  void dispose() {
    _pollService.disposeUserPollStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PollModel>>(
      stream: _pollService.getUserPolls(widget.user),
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PostSkeleton();
        } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
          return Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: showEmptyState(
                'No poll yet.',
                'All polls you partcipate in will show up here.',
              ),
            ),
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            physics: ScrollPhysics(),
            itemCount: snapshot.data!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                child: Column(
                  children: [
                    for (var item in snapshot.data!) ...[
                      SizedBox(height: 15),
                      PollQuestion(question: item.question, paddingHeader: true),
                      SizedBox(height: 20),
                      PollPercentage(
                        pollID: item.pollId,
                        totalVotes: item.totalVotes,
                        pollResultPercentage: item.pollResultPercentage,
                      ),
                      SizedBox(height: 5),
                    ],
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  bool findPollID(String pollId) {
    var pollData = MyAppState.currentUser!.polls;
    List poll = pollData.where((element) => element['poll'] == pollId).toList();
    return poll.isNotEmpty;
  }
}
