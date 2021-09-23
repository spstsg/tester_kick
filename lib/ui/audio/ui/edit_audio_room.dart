import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_chat_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class EditRoomFormDialog extends StatefulWidget {
  final Room room;
  EditRoomFormDialog({required this.room});

  @override
  _EditRoomFormDialogState createState() => _EditRoomFormDialogState();
}

class _EditRoomFormDialogState extends State<EditRoomFormDialog> {
  AudoChatService _audioChatService = AudoChatService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  dynamic startTime;
  dynamic endTime;
  String _enteredTitleText = '';
  List roomParticipants = [];
  List roomSpeakers = [];
  List raisedHands = [];

  @override
  void initState() {
    _titleController.text = widget.room.title;
    _tagsController.text = widget.room.tags.join(',');
    _enteredTitleText = widget.room.title;
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _audioChatService.getLiveRoom(widget.room.id).listen((event) {
        roomParticipants = [...event.participants];
        roomSpeakers = [...event.speakers];
        raisedHands = [...event.raisedHands];
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _audioChatService.disposeLiveRoomsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit room',
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
                padding: const EdgeInsets.only(top: 20.0, right: 24.0, left: 24.0),
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
                      style: TextStyle(
                        fontSize: 17,
                      ),
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
                      await updateLiveRoom(
                        _titleController.text.trim(),
                        _tagsController.text.trim().toLowerCase(),
                      );
                    }
                  },
                  child: Text(
                    'Update',
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

  validateFields(String title, String tags) {
    if (title.isEmpty) {
      final snackBar = SnackBar(
        content: Text(
          'Please add a title',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (tags.isEmpty) {
      final snackBar = SnackBar(
        content: Text(
          'Add at least one tag',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    List roomTags = tags.split(',');
    if (roomTags.length > 3) {
      final snackBar = SnackBar(
        content: Text(
          'Tags must not exceed the maximum',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
  }

  Future updateLiveRoom(String title, String tags) async {
    validateFields(title, tags);
    SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(
      context: context,
      barrierDimisable: false,
    );
    var timeOfDay = TimeOfDay.fromDateTime(DateTime.now());
    startTime = DateTimeField.convert(timeOfDay);
    try {
      progressDialog(
        context,
        _dialog,
        SimpleFontelicoProgressDialogType.normal,
        'Updating room...',
      );
      Room room = Room(
        id: widget.room.id,
        title: title,
        tags: tags.split(','),
        creator: widget.room.creator,
        status: 'live',
        channel: widget.room.channel,
        startTime: '',
        endTime: '',
        participants:
            roomParticipants.isNotEmpty ? [...roomParticipants] : [...widget.room.participants],
        speakers: roomSpeakers.isNotEmpty ? [...roomSpeakers] : [...widget.room.speakers],
        raisedHands: raisedHands.isNotEmpty ? [...raisedHands] : [...widget.room.raisedHands],
      );
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));

      var result = await _audioChatService.updateLiveRoom(room);
      if (result == null) {
        _dialog.hide();
        Navigator.of(context).pop();
      }
    } catch (e) {
      _dialog.hide();
      final snackBar = SnackBar(content: Text('Error updating room. Try again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
