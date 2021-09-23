import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';

class CustomTabBar extends StatelessWidget {
  final List icons;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isBottomIndicator;

  const CustomTabBar({
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
    this.isBottomIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          border: Border(top: BorderSide(color: ColorPalette.primary)),
        ),
        tabs: icons
            .asMap()
            .map((i, item) => MapEntry(
                  i,
                  Tab(
                    icon: Icon(
                      item['icon'],
                      color: i == selectedIndex ? ColorPalette.primary : ColorPalette.grey,
                      size: 20.0,
                    ),
                    child: Text(
                      '${item['name']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: i == selectedIndex ? ColorPalette.primary : ColorPalette.grey,
                      ),
                    ),
                  ),
                ))
            .values
            .toList(),
        onTap: onTap,
      ),
    );
  }
}
