import 'dart:async';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';

// NOT USED AT THE MOMENT

class DialogWithTextField extends StatefulWidget {
  final Room room;

  DialogWithTextField({Key? key, required this.room}) : super(key: key);

  @override
  DialogWithTextFieldState createState() => DialogWithTextFieldState();
}

class DialogWithTextFieldState extends State<DialogWithTextField> {
  AudoChatService _audioChatService = AudoChatService();
  final format = DateFormat("HH:mm");
  dynamic newEndTime;
  static StreamController<String> events = new StreamController<String>.broadcast();

  @override
  void dispose() {
    events.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () async {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 6,
                backgroundColor: Colors.transparent,
                child: _dialogWithTextField(context),
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: Colors.red,
          textStyle: TextStyle(color: Colors.red),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          'Add more',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _dialogWithTextField(BuildContext context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              "Extend the time",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
              child: DateTimeField(
                format: format,
                style: TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 16, right: 16),
                  hintText: 'Select',
                  hintStyle: TextStyle(fontSize: 17),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide: BorderSide(
                      color: ColorPalette.primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                onShowPicker: (context, currentValue) async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  setState(() {
                    newEndTime = DateTimeField.convert(time);
                  });
                  return DateTimeField.convert(time);
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: ColorPalette.white,
                    ),
                  ),
                  onPressed: () async {
                    if (newEndTime.toString().isNotEmpty || newEndTime != null) {
                      if (newEndTime.toString() == widget.room.endTime) {
                        return;
                      }
                      await _audioChatService.updateDate(
                        widget.room.id,
                        'newEndTime',
                        newEndTime.toString(),
                      );
                      _audioChatService.updateDate(
                        widget.room.id,
                        'newRoomStarted',
                        DateTime.now().toString(),
                      );
                      widget.room.newEndTime = newEndTime.toString();
                      widget.room.newRoomStarted = DateTime.now().toString();
                      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(widget.room));
                      events.sink.add('started');
                      // events.close();
                    }
                    return Navigator.of(context).pop(true);
                  },
                )
              ],
            ),
          ],
        ),
      );
}
