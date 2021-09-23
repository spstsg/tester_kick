import 'package:flutter/material.dart';

class MatchesSkeleton extends StatefulWidget {
  final double height;
  final double width;

  MatchesSkeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => MatchesSkeletonState();
}

class MatchesSkeletonState extends State<MatchesSkeleton> with SingleTickerProviderStateMixin {
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
      itemCount: 3,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildSkeletonMatchesWidget();
      },
    );
  }

  _buildSkeletonMatchesWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            child: Container(
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
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment(0.0, 0.0),
                              width: 40.0,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 9.0),
                            Container(
                              width: MediaQuery.of(context).size.width - 110.0,
                              height: widget.height,
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
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment(0.0, 0.0),
                              width: 40.0,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 9.0),
                            Container(
                              width: MediaQuery.of(context).size.width - 110.0,
                              height: widget.height,
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
                            ),
                          ],
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
