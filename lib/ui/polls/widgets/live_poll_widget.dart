import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/poll/poll_service.dart';
import 'package:kick_chat/ui/polls/answer_poll.dart';
import 'package:kick_chat/ui/polls/result_poll.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LivePollWidget extends StatefulWidget {
  final PollModel poll;

  const LivePollWidget({Key? key, required this.poll}) : super(key: key);
  @override
  _LivePollWidgetState createState() => _LivePollWidgetState();
}

class _LivePollWidgetState extends State<LivePollWidget> {
  PollService _pollService = PollService();

  @override
  Widget build(BuildContext context) {
    checkEventTime(widget.poll.pollEnd, widget.poll.pollId);
    return GestureDetector(
      onTap: () {
        if (findPollID(widget.poll.pollId)) {
          push(context, ResultPoll(poll: widget.poll));
        } else {
          push(context, AnswerPoll(poll: widget.poll));
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue.shade400,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.poll.question,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(MdiIcons.poll, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        widget.poll.totalVotes > 1
                            ? '${NumberFormat.compact().format(widget.poll.totalVotes)} votes'
                            : '${widget.poll.totalVotes} vote',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(width: 8),
                      findPollID(widget.poll.pollId)
                          ? Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'You already voted',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
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

  void checkEventTime(String dateString, String pollId) {
    var now = DateTime.now();
    var date = DateTime.parse(dateString);

    bool sameDate = isSameDate(now, date);

    Duration duration = date.difference(now);
    final hours = duration.inHours;
    final minutes = duration.inMinutes;

    if (sameDate && hours <= 0 && minutes <= 0) {
      _pollService.endPoll(pollId);
    }
  }

  bool isSameDate(DateTime current, DateTime other) {
    return current.year == other.year && current.month == other.month && current.day == other.day;
  }
}
