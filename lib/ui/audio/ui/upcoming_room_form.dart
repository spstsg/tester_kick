import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_upcoming_room_model.dart';
import 'package:kick_chat/services/audio/audio_upcoming_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class UpcomingRoomFormDialog extends StatefulWidget {
  const UpcomingRoomFormDialog({Key? key}) : super(key: key);

  @override
  _UpcomingRoomFormDialogState createState() => _UpcomingRoomFormDialogState();
}

class _UpcomingRoomFormDialogState extends State<UpcomingRoomFormDialog> {
  UpcomingAudioService _upcomingAudioService = UpcomingAudioService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  dynamic scheduledDate;
  String _enteredTitleText = '';
  String _enteredDescriptionText = '';
  final format = DateFormat("yyyy-MM-dd HH:mm");

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
        key: _formKey,
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
                      'Title',
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
                      controller: _titleController,
                      onChanged: (text) {
                        setState(() {
                          _enteredTitleText = text;
                        });
                      },
                      style: TextStyle(fontSize: 17),
                      keyboardType: TextInputType.text,
                      cursorColor: ColorPalette.primary,
                      autofocus: false,
                      maxLength: 60,
                      decoration: InputDecoration(
                        counterText: '${60 - _enteredTitleText.length} characters remaining',
                        counterStyle: TextStyle(fontSize: 14),
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
                      controller: _tagsController,
                      style: TextStyle(fontSize: 17),
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
                            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                          );
                          setState(() {
                            scheduledDate = DateTimeField.combine(date, time);
                          });
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
                      controller: _descriptionController,
                      maxLength: 100,
                      minLines: 1,
                      maxLines: 10,
                      onChanged: (text) {
                        setState(() {
                          _enteredDescriptionText = text;
                        });
                      },
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
                        counterText: '${100 - _enteredDescriptionText.length} characters remaining',
                        counterStyle: TextStyle(fontSize: 14),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await createUpcomingRoom(
                        _titleController.text.trim(),
                        _tagsController.text.trim(),
                        scheduledDate,
                        _descriptionController.text.trim(),
                      );
                    }
                  },
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

  validateFields(String title, String tags, dynamic scheduledDate, String description) {
    if (title.isEmpty) {
      return 'Please add a title';
    }

    if (tags.isEmpty) {
      return 'Add at least one tag';
    }

    List roomTags = tags.split(',');
    if (roomTags.length > 3) {
      return 'Tags must not exceed the maximum';
    }

    if (scheduledDate == null) {
      return 'Please add a date and time';
    }

    if (description.isEmpty) {
      return 'Please add a description';
    }

    return '';
  }

  Future createUpcomingRoom(
    String title,
    String tags,
    dynamic scheduledDate,
    String description,
  ) async {
    String result = validateFields(title, tags, scheduledDate, description);
    if (result.isNotEmpty) {
      final snackBar = SnackBar(
        content: Text(
          result,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(
        context: context,
        barrierDimisable: false,
      );
      try {
        progressDialog(
          context,
          _dialog,
          SimpleFontelicoProgressDialogType.normal,
          'Scheduling room...',
        );
        await Future.delayed(Duration(seconds: 1));
        UpcomingRoom room = UpcomingRoom(
          id: getRandomString(20),
          title: title,
          tags: tags.split(','),
          creator: MyAppState.currentUser!,
          scheduledDate: scheduledDate.toString(),
          description: description,
        );

        await _upcomingAudioService.createUpcomingRoom(room);
        _dialog.hide();
        push(context, NavScreen(tabIndex: 1));
      } catch (e) {
        print(e);
        _dialog.hide();
        final snackBar = SnackBar(content: Text('Error scheduling room. Try again'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
