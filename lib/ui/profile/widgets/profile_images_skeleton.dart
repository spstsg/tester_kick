import 'package:flutter/material.dart';

class ProfileImagesSkeleton extends StatefulWidget {
  final double height;
  final double width;

  ProfileImagesSkeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => ProfileImagesSkeletonState();
}

class ProfileImagesSkeletonState extends State<ProfileImagesSkeleton>
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
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 12,
      physics: ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return _buildSkeletonProfileImagesWidget();
      },
    );
  }

  _buildSkeletonProfileImagesWidget() {
    return Container(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(gradientPosition.value, 0),
                end: Alignment(-1, 0),
                colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
              ),
            ),
          )
        ],
      ),
    );
  }
}
