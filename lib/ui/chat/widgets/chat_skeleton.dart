import 'package:flutter/material.dart';

class ChatSkeleton extends StatefulWidget {
  final double height;
  final double width;

  ChatSkeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => ChatSkeletonState();
}

class ChatSkeletonState extends State<ChatSkeleton> with SingleTickerProviderStateMixin {
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
      itemCount: 5,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildSkeletonChatWidget();
      },
    );
  }

  _buildSkeletonChatWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Directionality.of(context) == TextDirection.ltr
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      children: <Widget>[
                        Container(
                          width: 200,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            gradient: LinearGradient(
                              begin: Alignment(gradientPosition.value, 0),
                              end: Alignment(-1, 0),
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                                Colors.grey.shade200
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 10, left: 4, right: 4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Directionality.of(context) == TextDirection.ltr
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      children: <Widget>[
                        Container(
                          width: 200,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            gradient: LinearGradient(
                              begin: Alignment(gradientPosition.value, 0),
                              end: Alignment(-1, 0),
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                                Colors.grey.shade200
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 10, left: 4, right: 4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
