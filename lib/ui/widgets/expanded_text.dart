import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle itemStyle;
  final TextAlign itemTextAlign;
  final Color showColor;
  ExpandableText({
    Key? key,
    required this.text,
    required this.itemStyle,
    this.itemTextAlign: TextAlign.start,
    this.showColor: Colors.blue,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  String text = '';
  bool canExpand = false;
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    canExpand = widget.text != '' && widget.text.length >= 150;
    text = canExpand ? (isExpand ? widget.text : widget.text.substring(0, 150)) : (widget.text);

    return canExpand
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildTextWithLinks(text.trim(), widget.itemStyle),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpand = !isExpand;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    isExpand ? 'Show less' : 'Show more',
                    style: TextStyle(
                      color: widget.showColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        : Linkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: widget.text,
            style: widget.itemStyle,
            textAlign: widget.itemTextAlign,
            linkStyle: TextStyle(decoration: TextDecoration.none),
          );
  }
}

buildTextWithLinks(String textToLink, TextStyle style) => Linkify(
      onOpen: (link) async {
        if (await canLaunch(link.url)) {
          await launch(link.url);
        } else {
          throw 'Could not launch $link';
        }
      },
      text: '$textToLink...',
      style: style,
      linkStyle: TextStyle(decoration: TextDecoration.none),
    );
