import 'dart:async';

import 'package:flutter/material.dart';

class BlinkingIcon extends StatefulWidget {
  // BlinkingText();
  @override
  BlinkingIconState createState() => BlinkingIconState();
}

class BlinkingIconState extends State<BlinkingIcon> {
  bool _show = true;
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds: 700), (_) {
      setState(() => _show = !_show);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _show
      ? Icon(
          Icons.circle,
          color: Colors.green,
          size: 10,
        )
      : Icon(
          Icons.circle,
          color: Colors.white,
          size: 10,
        );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
