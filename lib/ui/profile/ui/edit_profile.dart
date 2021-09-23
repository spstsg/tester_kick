import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/widgets/loading_overlay.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserService _userService = UserService();
  TextEditingController _bioContrl = TextEditingController();
  late User user;
  String _enteredBioText = '';
  @override
  void initState() {
    user = widget.user;
    _bioContrl.text = user.bio;
    super.initState();
  }

  @override
  void dispose() {
    _bioContrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit profile',
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
            SizedBox(height: 5),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 24.0, left: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio',
                      style: TextStyle(
                        color: ColorPalette.black,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _bioContrl,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 10,
                      maxLength: 80,
                      onChanged: (text) {
                        setState(() {
                          _enteredBioText = text;
                        });
                      },
                      style: TextStyle(color: Colors.grey[900]),
                      decoration: new InputDecoration(
                        filled: true,
                        isDense: true,
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        hintText: "Add a bio to your profile",
                        fillColor: ColorPalette.white,
                        counterText: '${80 - _enteredBioText.length} characters remaining',
                        counterStyle: TextStyle(fontSize: 14),
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
                    ),
                  ),
                  onPressed: () => updateUser(user),
                  child: Text(
                    'Save',
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

  Future<void> updateUser(User user) async {
    try {
      LoadingOverlay.of(context).show();
      user.bio = _bioContrl.text.trim();
      await _userService.updateCurrentUser(user);
      LoadingOverlay.of(context).hide();
      MyAppState.currentUser = user;
      MyAppState.reduxStore!.dispatch(CreateUserAction(user));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save details. Please try again.')),
      );
    }
  }
}
