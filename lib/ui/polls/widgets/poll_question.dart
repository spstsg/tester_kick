import 'package:flutter/material.dart';

class PollQuestion extends StatelessWidget {
  final String question;
  final bool paddingHeader;
  const PollQuestion({Key? key, required this.question, this.paddingHeader = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingHeader
          ? EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10)
          : EdgeInsets.only(left: 5, right: 5),
      margin: paddingHeader ? EdgeInsets.only(left: 0, right: 0) : EdgeInsets.only(left: 15, right: 15),
      color: paddingHeader ? Colors.blue.shade200 : Colors.transparent,
      alignment: Alignment.centerLeft,
      child: Text(
        question,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
