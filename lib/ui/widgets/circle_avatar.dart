import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/helper.dart';

class CircleProfileAvatar extends StatelessWidget {
  final String username;
  final String avatarColor;
  final double radius;
  final double fontSize;

  const CircleProfileAvatar({
    this.username = '',
    this.avatarColor = '',
    this.radius = 45.0,
    this.fontSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            alignment: Alignment(0.0, 0.0),
            width: radius,
            height: radius,
            decoration: new BoxDecoration(
              color: hexStringToColor(avatarColor),
              shape: BoxShape.circle,
            ),
            child: Text(
              username.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: ColorPalette.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
