import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/poll/poll_service.dart';
import 'package:kick_chat/ui/polls/result_poll.dart';
import 'package:kick_chat/ui/polls/widgets/poll_button.dart';

class PollDisplay extends StatefulWidget {
  final List answers;
  final PollModel poll;
  const PollDisplay({Key? key, required this.answers, required this.poll}) : super(key: key);

  @override
  _PollDisplayState createState() => _PollDisplayState();
}

class _PollDisplayState extends State<PollDisplay> {
  PollService _pollService = PollService();
  bool userVoted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!mounted) return;
      MyAppState.reduxStore!.onChange.listen((event) {
        setState(() {
          userVoted = findPollID(widget.poll.pollId);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ...List.generate(
            widget.answers.length,
            (index) {
              return PollButtonWidget(
                answer: widget.answers[index],
                onPressed: () async {
                  _pollService.updatePollAnswer(widget.poll.pollId, widget.answers[index]);
                  PollModel poll = await _pollService.getPoll(widget.poll.pollId);
                  push(context, ResultPoll(poll: poll));
                },
                poll: widget.poll,
                disable: userVoted,
              );
            },
          ),
        ],
      ),
    );
  }

  bool findPollID(String pollId) {
    var pollData = MyAppState.currentUser!.polls;
    List poll = pollData.where((element) => element['poll'] == pollId).toList();
    return poll.isNotEmpty;
  }
}
