import 'package:flutter/material.dart';

class ConversationFollowersSkeleton extends StatefulWidget {
  final double height;
  final double width;

  ConversationFollowersSkeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => ConversationFollowersSkeletonState();
}

class ConversationFollowersSkeletonState extends State<ConversationFollowersSkeleton>
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
    return SizedBox(
      height: 75,
      child: ListView.builder(
        itemCount: 8,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _buildSkeletonConversationFollowersWidget();
        },
      ),
    );
  }

  _buildSkeletonConversationFollowersWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8, right: 4),
      child: Column(
        children: <Widget>[
          Container(
            width: 50.0,
            height: 50.0,
            decoration: new BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
    );
  }
}
