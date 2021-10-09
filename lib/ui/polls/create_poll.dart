import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/poll_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/poll/poll_service.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class CreatePoll extends StatefulWidget {
  const CreatePoll({Key? key}) : super(key: key);

  @override
  _CreatePollState createState() => _CreatePollState();
}

class _CreatePollState extends State<CreatePoll> {
  PollService _pollService = PollService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _answersController = TextEditingController();
  TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _answersController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Create poll',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        actions: [],
      ),
      body: Container(
        child: Form(
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
                        'Question',
                        style: TextStyle(
                          color: ColorPalette.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.next,
                        controller: _titleController,
                        style: TextStyle(fontSize: 17),
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
                        'Answers',
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
                        controller: _answersController,
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
                        'Duration in hours (1 - 168)',
                        style: TextStyle(
                          color: ColorPalette.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.next,
                        controller: _durationController,
                        style: TextStyle(fontSize: 17),
                        keyboardType: TextInputType.text,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
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
                        createPoll(
                          _titleController.text.trim(),
                          _answersController.text.trim(),
                          _durationController.text,
                        );
                      }
                    },
                    child: Text(
                      'Create',
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
      ),
    );
  }

  validateFields(String question, String answers, String duration) {
    if (question.isEmpty) {
      return 'Please add a question';
    }

    if (answers.isEmpty) {
      return 'Add at least one tag';
    }

    if (duration.isEmpty || int.parse(duration) <= 0) {
      return 'Add a duration';
    }
    return '';
  }

  Future createPoll(String question, String answers, String duration) async {
    String result = validateFields(question, answers, duration);
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
      var today = new DateTime.now();
      var pollDuration = today.add(new Duration(minutes: int.parse(duration) * 60));
      SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(
        context: context,
        barrierDimisable: false,
      );
      try {
        progressDialog(
          context,
          _dialog,
          SimpleFontelicoProgressDialogType.normal,
          'Creating poll...',
        );
        await Future.delayed(Duration(seconds: 1));
        PollModel room = PollModel(
          pollId: getRandomString(20),
          question: question,
          answers: answers.split(','),
          pollEnd: pollDuration.toString(),
        );

        await _pollService.createPoll(room);
        _dialog.hide();
        push(context, NavScreen(tabIndex: 0));
      } catch (e) {
        print(e);
        _dialog.hide();
        final snackBar = SnackBar(content: Text('Error creating poll. Try again'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
