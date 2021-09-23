import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String? title, descriptions, okay;
  final String? cancel;
  final Image? img;
  final bool showCancel;

  const CustomDialogBox({
    this.title,
    this.descriptions,
    this.okay,
    this.cancel = '',
    this.img,
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
        title: Text(
          widget.title as String,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        content: Text(
          widget.descriptions as String,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: widget.showCancel && widget.cancel!.isNotEmpty
            ? [
                Visibility(
                  visible: widget.showCancel && widget.cancel!.isNotEmpty,
                  child: CupertinoDialogAction(
                    child: Text(
                      widget.cancel as String,
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
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

  // contentBox(context) {
  //   return Stack(
  //     children: <Widget>[
  //       Container(
  //         padding: EdgeInsets.only(left: 20, top: 45 + 20, right: 20, bottom: 20),
  //         margin: EdgeInsets.only(top: 45),
  // decoration: BoxDecoration(
  //   shape: BoxShape.rectangle,
  //   color: Colors.white,
  //   borderRadius: BorderRadius.circular(20),
  //   boxShadow: [
  //     BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
  //   ],
  // ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Text(
  //               widget.title as String,
  //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
  //             ),
  //             SizedBox(
  //               height: 15,
  //             ),
  //             Text(
  //               widget.descriptions as String,
  //               // style: TextStyle(fontSize: 14),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(
  //               height: 22,
  //             ),
  //             Align(
  //               alignment: Alignment.bottomRight,
  //               child: TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text(
  //                   widget.text as String,
  //                   style: TextStyle(fontSize: 18),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       Positioned(
  //         left: 20,
  //         right: 20,
  //         child: CircleAvatar(
  //           backgroundColor: Colors.transparent,
  //           radius: 45,
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.all(Radius.circular(45)),
  //             child: Image.asset("assets/images/icon.png"),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
