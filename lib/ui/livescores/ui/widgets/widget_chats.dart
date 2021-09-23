import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:readmore/readmore.dart';

class CardChat extends StatelessWidget {
  final image;
  final String name;
  final String message;

  CardChat({
    required this.image,
    required this.name,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            maxRadius: 20.0,
            backgroundImage: NetworkImage(image),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
                ReadMoreText(
                  message,
                  trimLines: 2,
                  colorClickableText: theme.primaryColor,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' More',
                  trimExpandedText: ' Less',
                  style: TextStyle(
                    color: ColorPalette.black,
                  ),
                  moreStyle: TextStyle(
                    fontSize: 12,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
