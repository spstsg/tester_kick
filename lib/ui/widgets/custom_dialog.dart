import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String? title, descriptions, okay;
  final String? cancel;
  final String? other;
  final bool showCancel;

  const CustomDialogBox({
    this.title,
    this.descriptions,
    this.okay,
    this.cancel = '',
    this.other = '',
    this.showCancel = false,
  });

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white.withOpacity(0.5),
      child: CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.title as String,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        content: Text(
          widget.descriptions as String,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: widget.showCancel && widget.cancel!.isNotEmpty && widget.other!.isNotEmpty && widget.okay!.isNotEmpty
            ? [
                CupertinoDialogAction(
                  child: Text(
                    widget.cancel as String,
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    widget.okay as String,
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    widget.other as String,
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop([true]);
                  },
                ),
              ]
            : widget.other!.isNotEmpty && widget.okay!.isNotEmpty && widget.cancel!.isEmpty
                ? [
                    CupertinoDialogAction(
                      child: Text(
                        widget.okay as String,
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text(
                        widget.other as String,
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop([true]);
                      },
                    ),
                  ]
                : widget.other!.isEmpty && widget.okay!.isNotEmpty && widget.cancel!.isNotEmpty
                    ? [
                        CupertinoDialogAction(
                          child: Text(
                            widget.cancel as String,
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text(
                            widget.okay as String,
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ]
                    : [
                        CupertinoDialogAction(
                          child: Text(
                            widget.okay as String,
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
      ),
    );
  }
}
