import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/ui/polls/widgets/poll_percentage.dart';
import 'package:kick_chat/ui/polls/widgets/poll_question.dart';
import 'package:kick_chat/ui/polls/widgets/poll_vote_number.dart';

class ResultPoll extends StatefulWidget {
  final PollModel poll;
  ResultPoll({required this.poll});

  @override
  _ResultPollState createState() => _ResultPollState();
}

class _ResultPollState extends State<ResultPoll> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) return;
      MyAppState.reduxStore!.onChange.listen((event) {
        setState(() {
          MyAppState.currentUser = event.user;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Poll',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        actions: [],
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            SizedBox(height: 15),
            PollQuestion(question: widget.poll.question),
            SizedBox(height: 30),
            PollPercentage(
              pollID: widget.poll.pollId,
              totalVotes: widget.poll.totalVotes,
              pollResultPercentage: widget.poll.pollResultPercentage,
            ),
            SizedBox(height: 5),
            PollVoteNumber(voteCount: widget.poll.totalVotes)
          ],
        ),
      ),
    );
  }

  bool findPollID(String pollId) {
    var pollData = MyAppState.currentUser!.polls;
    List poll = pollData.where((element) => element['poll'] == pollId).toList();
    return poll.isNotEmpty;
  }
}
