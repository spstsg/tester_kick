import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/ui/polls/widgets/poll_display.dart';
import 'package:kick_chat/ui/polls/widgets/poll_question.dart';
import 'package:kick_chat/ui/polls/widgets/poll_vote_number.dart';

class AnswerPoll extends StatefulWidget {
  final PollModel poll;
  AnswerPoll({required this.poll});

  @override
  _AnswerPollState createState() => _AnswerPollState();
}

class _AnswerPollState extends State<AnswerPoll> {
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
            PollDisplay(answers: widget.poll.answers, poll: widget.poll),
            SizedBox(height: 5),
            PollVoteNumber(voteCount: widget.poll.totalVotes)
          ],
        ),
      ),
    );
  }
}
