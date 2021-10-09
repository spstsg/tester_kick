import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PollVoteNumber extends StatelessWidget {
  final int voteCount;
  const PollVoteNumber({Key? key, required this.voteCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        voteCount > 1 ? '${NumberFormat.compact().format(voteCount)} votes' : '${voteCount} vote',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 16,
        ),
      ),
    );
  }
}
