import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String pollID;

  const LivePollWidget({Key? key, required this.pollID}) : super(key: key);
  @override
  _LivePollWidgetState createState() => _LivePollWidgetState();
}

class _LivePollWidgetState extends State<LivePollWidget> {
  PollService _pollService = PollService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _pollService.getPollStream(widget.pollID),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return SizedBox.shrink();
        }
        PollModel poll = PollModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
        checkEventTime(poll.pollEnd, widget.pollID);
        return GestureDetector(
          onTap: () {
            if (findPollID(widget.pollID)) {
              push(context, ResultPoll(poll: poll));
            } else {
              push(context, AnswerPoll(poll: poll));
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
                        poll.question,
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
                            poll.totalVotes > 1
                                ? '${NumberFormat.compact().format(poll.totalVotes)} votes'
                                : '${poll.totalVotes} vote',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(width: 8),
                          findPollID(widget.pollID)
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
      },
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
