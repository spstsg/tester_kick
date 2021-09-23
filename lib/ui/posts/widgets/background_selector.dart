import 'package:flutter/material.dart';

typedef void StringCallback(Color val);

class BackgroundSelector extends StatelessWidget {
  final List<Color> bgColors = [
    Color(0xffffffff),
    Color(0xfff44336),
    Color(0xffe91e63),
    Color(0xff2196f3),
    Color(0xff3f51b5),
    Color(0xff00bcd4),
    Color(0xff4caf50),
    Color(0xffff9800),
    Color(0xff009688),
    Color(0xffcddc39),
    Color(0xff2962ff),
    Color(0xffd32f2f),
    Color(0xffd84315),
    Color(0xff84ffff),
  ];

  final StringCallback callback;
  BackgroundSelector({required this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 4.0,
        ),
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: bgColors.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    callback(bgColors[index]);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            bgColors[index] == Color(0xffffffff) ? Colors.grey : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: bgColors[index],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
