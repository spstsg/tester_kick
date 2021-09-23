import 'dart:ui';
import 'package:flutter/material.dart';

// I got this from here: https://github.com/verygoodtechnologies/cupertino_timer

class CupertinoTimer extends StatefulWidget {
  final Duration duration;
  final bool startOnInit;
  final TextStyle timeStyle;
  final Alignment alignment;

  CupertinoTimer({
    Key? key,
    required this.duration,
    this.startOnInit = false,
    this.timeStyle = const TextStyle(),
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CupertinoTimerState();
  }
}

class CupertinoTimerState extends State<CupertinoTimer> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool running = false;

  @override
  void initState() {
    controller = AnimationController(vsync: this);

    controller.duration = widget.duration;
    controller.addStatusListener(_animationStatusListener);
    if (widget.startOnInit) {
      controller.forward();
      running = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: widget.alignment,
      child: Container(
        alignment: widget.alignment,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Text(
              _getText(),
              style: TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
                fontSize: MediaQuery.of(context).size.width * 100,
              ).merge(widget.timeStyle),
            );
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(CupertinoTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      running = true;
    } else if (status == AnimationStatus.dismissed) {
      running = false;
    }
  }

  String _getText() {
    Duration duration = controller.duration! * controller.value;
    duration = Duration(seconds: controller.duration!.inSeconds - duration.inSeconds);

    if (duration.inHours > 0) {
      return "${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, "0")}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
    } else {
      return "${duration.inMinutes.toString().padLeft(2, "0")}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
    }
  }

  @override
  void dispose() {
    controller.stop();
    controller.removeStatusListener(_animationStatusListener);
    controller.dispose();
    super.dispose();
  }
}
