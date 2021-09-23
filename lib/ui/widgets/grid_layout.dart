import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';

class GridLayout {
  final String title;
  final String image;

  GridLayout({required this.title, required this.image});
}

class GridOptions extends StatelessWidget {
  final GridLayout layout;

  GridOptions({required this.layout});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorPalette.greyWhite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              layout.image,
              width: 40,
              height: 40,
            ),
            Text(
              layout.title,
              style: TextStyle(
                fontSize: 18,
                color: ColorPalette.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
