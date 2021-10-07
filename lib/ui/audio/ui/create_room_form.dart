import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/audio/ui/audio_room.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class CreateRoomFormDialog extends StatefulWidget {
  const CreateRoomFormDialog({Key? key}) : super(key: key);

  @override
  _CreateRoomFormDialogState createState() => _CreateRoomFormDialogState();
}

class _CreateRoomFormDialogState extends State<CreateRoomFormDialog> {
  AudoChatService _audioChatService = AudoChatService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  dynamic startTime;
  dynamic endTime;
  String _enteredTitleText = '';
  final format = DateFormat("HH:mm");

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create a room',
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
            // ConstrainedBox(
            //   constraints: BoxConstraints(minWidth: double.infinity),
            //   child: Padding(
            //     padding: const EdgeInsets.only(
            //       top: 20.0,
            //       right: 24.0,
            //       left: 24.0,
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Add duration',
            //           style: TextStyle(
            //             color: ColorPalette.black,
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         SizedBox(height: 5),
            //         Text(
            //           'This will give participants a sense of how long the conversation will last. You will be able to increase the time within the room.',
            //           style: TextStyle(
            //             color: ColorPalette.grey,
            //           ),
            //         ),
            //         SizedBox(height: 10),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Container(
            //               width: MediaQuery.of(context).size.width * 0.40,
            //               child: TextField(
            //                 style: TextStyle(fontSize: 17),
            //                 readOnly: true,
            //                 decoration: InputDecoration(
            //                   contentPadding: EdgeInsets.only(left: 16, right: 16),
            //                   hintText: 'Starts now',
            //                   hintStyle: TextStyle(fontSize: 17),
            //                   focusedBorder: OutlineInputBorder(
            //                     borderRadius: BorderRadius.circular(0.0),
            //                     borderSide: BorderSide(
            //                       color: Colors.grey.shade200,
            //                       width: 2.0,
            //                     ),
            //                   ),
            //                   enabledBorder: OutlineInputBorder(
            //                     borderSide: BorderSide(color: Colors.grey.shade200),
            //                     borderRadius: BorderRadius.circular(0.0),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             Container(
            //               child: Text('—'),
            //             ),
            //             Container(
            //               width: MediaQuery.of(context).size.width * 0.40,
            //               child: DateTimeField(
            //                 format: format,
            //                 style: TextStyle(fontSize: 17),
            //                 decoration: InputDecoration(
            //                   contentPadding: EdgeInsets.only(left: 16, right: 16),
            //                   hintText: 'Select end time',
            //                   hintStyle: TextStyle(fontSize: 17),
            //                   focusedBorder: OutlineInputBorder(
            //                     borderRadius: BorderRadius.circular(0.0),
            //                     borderSide: BorderSide(
            //                       color: ColorPalette.primary,
            //                       width: 2.0,
            //                     ),
            //                   ),
            //                   enabledBorder: OutlineInputBorder(
            //                     borderSide: BorderSide(color: Colors.grey.shade200),
            //                     borderRadius: BorderRadius.circular(0.0),
            //                   ),
            //                 ),
            //                 onShowPicker: (context, currentValue) async {
            //                   final time = await showTimePicker(
            //                     context: context,
            //                     initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            //                   );
            //                   setState(() {
            //                     endTime = DateTimeField.convert(time);
            //                   });
            //                   return DateTimeField.convert(time);
            //                 },
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
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
                      await createLiveRoom(
                        _titleController.text.trim(),
                        _tagsController.text.trim().toLowerCase(),
                      );
                    }
                  },
                  child: Text(
                    'Go live',
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
      return 'Please add a title';
    }

    if (tags.isEmpty) {
      return 'Add at least one tag';
    }

    List roomTags = tags.split(',');
    if (roomTags.length > 3) {
      return 'Tags must not exceed the maximum';
    }
  }

  Future createLiveRoom(String title, String tags) async {
    String result = validateFields(title, tags);
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
      var timeOfDay = TimeOfDay.fromDateTime(DateTime.now());
      startTime = DateTimeField.convert(timeOfDay);
      try {
        progressDialog(
          context,
          _dialog,
          SimpleFontelicoProgressDialogType.normal,
          'Creating room...',
        );
        await Future.delayed(Duration(seconds: 1));
        Room room = Room(
          id: getRandomString(20),
          title: title,
          tags: tags.split(','),
          creator: MyAppState.currentUser!,
          status: 'live',
          channel: getRandomString(10),
          startTime: startTime.toString(),
          endTime: endTime.toString(),
          participants: [
            {
              'id': MyAppState.currentUser!.userID,
              'username': MyAppState.currentUser!.username,
              'avatarColor': MyAppState.currentUser!.avatarColor,
              'profilePictureURL': MyAppState.currentUser!.profilePictureURL,
            }
          ],
        );
        MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(room));

        var result = await _audioChatService.createLiveRoom(room);
        await Permission.microphone.request();
        if (result is Room) {
          _dialog.hide();
          pushAndRemoveUntil(
            context,
            AudioRoomScreen(room: result, role: ClientRole.Broadcaster),
            false,
            false,
            '',
          );
        }
      } catch (e) {
        _dialog.hide();
        final snackBar = SnackBar(content: Text('Error creating room. Try again'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
