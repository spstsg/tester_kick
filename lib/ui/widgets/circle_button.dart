import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:badges/badges.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final bool showBadge;
  final int badgeNumber;
  final VoidCallback onPressed;

  const CircleButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.showBadge = false,
    this.badgeNumber = 0,
  });

  @override
  Widget build(BuildContext context) {
    return showBadge && badgeNumber > 0
        ? Container(
            margin: const EdgeInsets.all(6.0),
            child: Badge(
              toAnimate: false,
              shape: badgeNumber >= 1 && badgeNumber <= 99 ? BadgeShape.circle : BadgeShape.square,
              position: BadgePosition.topEnd(
                top: -3,
                end: badgeNumber >= 1 && badgeNumber <= 9
                    ? 1
                    : badgeNumber >= 10 && badgeNumber <= 99
                        ? -1
                        : -8,
              ),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              badgeContent: Text(
                NumberFormat.compact().format(badgeNumber),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: IconButton(
                icon: Icon(icon),
                iconSize: iconSize,
                color: ColorPalette.primary,
                onPressed: onPressed,
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(icon),
              iconSize: iconSize,
              color: ColorPalette.primary,
              onPressed: onPressed,
            ),
          );
  }
}
