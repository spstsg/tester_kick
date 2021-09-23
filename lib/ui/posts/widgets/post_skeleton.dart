import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';

class PostSkeleton extends StatefulWidget {
  final double height;
  final double width;

  PostSkeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => PostSkeletonState();
}

class PostSkeletonState extends State<PostSkeleton> with SingleTickerProviderStateMixin {
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
        return _buildSkeletonPostWidget();
      },
    );
  }

  _buildSkeletonPostWidget() {
    return Card(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: ColorPalette.grey, width: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 10, left: 15, right: 15),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
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
                      width: MediaQuery.of(context).size.width - 110.0,
                      height: widget.height,
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
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
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: widget.height * 2,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(gradientPosition.value, 0),
                    end: Alignment(-1, 0),
                    colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
