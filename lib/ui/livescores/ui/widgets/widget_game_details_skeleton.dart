import 'package:flutter/material.dart';

class GameDetailsSkeleton extends StatefulWidget {
  final double height;
  final double width;

  GameDetailsSkeleton({Key? key, this.height = 20, this.width = 200}) : super(key: key);

  createState() => GameDetailsSkeletonState();
}

class GameDetailsSkeletonState extends State<GameDetailsSkeleton>
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
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildSkeletonGameDetailsWidget();
      },
    );
  }

  _buildSkeletonGameDetailsWidget() {
    return Column(
      children: [
        SizedBox(height: 70),
        Container(
          margin: EdgeInsets.only(left: 25),
          child: Row(
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
                height: widget.height * 2,
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
        ),
        SizedBox(height: 40),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                margin: EdgeInsets.only(left: 30),
                decoration: new BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Text(
                      '- : -',
                      style: TextStyle(
                        fontSize: 60.0,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 30),
                width: 60.0,
                height: 60.0,
                decoration: new BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.0),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            physics: NeverScrollableScrollPhysics(),
            itemCount: 9,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Container(
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
                  SizedBox(height: 10.0),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
