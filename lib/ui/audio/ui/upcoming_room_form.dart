import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class UpcomingRoomFormDialog extends StatefulWidget {
  const UpcomingRoomFormDialog({Key? key}) : super(key: key);

  @override
  _UpcomingRoomFormDialogState createState() => _UpcomingRoomFormDialogState();
}

class _UpcomingRoomFormDialogState extends State<UpcomingRoomFormDialog> {
  final format = DateFormat("yyyy-MM-dd HH:mm");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule a room',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Form(
        child: ListView(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name of room',
                      style: TextStyle(
                        color: ColorPalette.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'What do you want to talk about?',
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: null,
                      onSaved: (val) {},
                      style: TextStyle(
                        fontSize: 17,
                      ),
                      keyboardType: TextInputType.text,
                      cursorColor: ColorPalette.primary,
                      autofocus: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, right: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: BorderSide(
                            color: ColorPalette.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add tags (Max. 3)',
                      style: TextStyle(
                        color: ColorPalette.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Separated by comma',
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: null,
                      onSaved: (val) {},
                      style: TextStyle(
                        fontSize: 17,
                      ),
                      keyboardType: TextInputType.text,
                      cursorColor: ColorPalette.primary,
                      autofocus: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, right: 16),
                        hintText: 'chelsea, arsenal, champions league',
                        hintStyle: TextStyle(
                          color: ColorPalette.grey,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: BorderSide(
                            color: ColorPalette.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled date and time',
                      style: TextStyle(
                        color: ColorPalette.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    DateTimeField(
                      format: format,
                      style: TextStyle(fontSize: 17),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16, right: 16),
                        hintText: 'Select date & time',
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
                        final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                currentValue ?? DateTime.now()),
                          );
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brief description',
                      style: TextStyle(
                        color: ColorPalette.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 20,
                        color: ColorPalette.black,
                      ),
                      decoration: new InputDecoration(
                        filled: false,
                        isDense: true,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: ColorPalette.white,
                          fontSize: 20,
                        ),
                        hintText: "What's on your mind?",
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
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '1/60',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 25, right: 25),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: ColorPalette.primary,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: ColorPalette.primary,
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
