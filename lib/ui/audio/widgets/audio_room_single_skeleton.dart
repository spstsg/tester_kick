import 'package:flutter/material.dart';

class AudioRoomSingleSkeleton extends StatefulWidget {
  final double height;
  final double width;
  final int amount;

  AudioRoomSingleSkeleton({Key? key, this.height = 20, this.width = 200, this.amount = 1})
      : super(key: key);

  createState() => AudioRoomSingleSkeletonState();
}

class AudioRoomSingleSkeletonState extends State<AudioRoomSingleSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation gradientPosition;

  @override
  void initState() {
    _controller = AnimationController(duration: Duration(milliseconds: 1500), vsync: this);

    gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4),
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.amount,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildSkeletonConversationWidget();
      },
    );
  }

  _buildSkeletonConversationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10.0),
        Row(
          children: [
            SizedBox(width: 9.0),
            Container(
              alignment: Alignment(0.0, 0.0),
              width: 50.0,
              height: 50.0,
              decoration: new BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 9.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(gradientPosition.value, 0),
                  end: Alignment(-1, 0),
                  colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
}
