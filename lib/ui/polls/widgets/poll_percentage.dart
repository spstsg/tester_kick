import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';

class PollPercentageDisplay {
  final String name;
  final int size;

  PollPercentageDisplay(this.name, this.size);
}

class PollPercentage extends StatefulWidget {
  final String pollID;
  final int totalVotes;
  final Map pollResultPercentage;

  const PollPercentage({
    Key? key,
    required this.pollID,
    required this.totalVotes,
    required this.pollResultPercentage,
  }) : super(key: key);

  @override
  _PollPercentageState createState() => _PollPercentageState();
}

class _PollPercentageState extends State<PollPercentage> {
  @override
  Widget build(BuildContext context) {
    List<PollPercentageDisplay> percentData =
        widget.pollResultPercentage.entries.map((entry) => PollPercentageDisplay(entry.key, entry.value)).toList();
    return Column(
      children: [
        ...List.generate(
          percentData.length,
          (index) {
            var answerVoteCount = percentData[index].size;
            double percentage = (answerVoteCount / widget.totalVotes) * 100;
            return percentageButton(percentData[index].name, percentage.toInt());
          },
        ),
      ],
    );
  }

  Widget percentageButton(String answer, int percentage) {
    return Container(
      margin: EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: findPollID(widget.pollID, answer) ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: findPollID(widget.pollID, answer)
            ? Border.all(color: Colors.blue)
            : Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: findPollID(widget.pollID, answer) ? Colors.white : Colors.grey.shade700,
              fontSize: 15,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: findPollID(widget.pollID, answer) ? Colors.white : Colors.grey.shade700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  bool findPollID(String pollId, String answer) {
    var pollData = MyAppState.currentUser!.polls;
    List poll = pollData.where((element) => element['poll'] == pollId && element['answer'] == answer).toList();
    return poll.isNotEmpty;
  }
}
