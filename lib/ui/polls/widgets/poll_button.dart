import 'package:flutter/material.dart';
import 'package:kick_chat/models/poll_model.dart';

class PollButtonWidget extends StatelessWidget {
  final String answer;
  final bool disable;
  final PollModel poll;
  final VoidCallback onPressed;

  const PollButtonWidget({
    Key? key,
    required this.disable,
    required this.answer,
    required this.poll,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !disable ? onPressed : null,
      child: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: !disable ? Colors.blue : Colors.blue.shade200,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          answer,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
