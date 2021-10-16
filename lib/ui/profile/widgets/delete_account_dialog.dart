import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';

class DeleteAccount extends StatefulWidget {
  final String username;
  const DeleteAccount({Key? key, required this.username}) : super(key: key);

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  UserService _userService = UserService();
  TextEditingController _usernameController = TextEditingController();
  String username = '';
  bool isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.0),
      body: Align(
        alignment: Alignment(0.0, -0.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.38,
          padding: EdgeInsets.only(top: 25, bottom: 25, left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Delete account?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your account (${widget.username}) will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'If you\'re sure, type your username.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 10),
              inputTextField(context),
              SizedBox(height: 20),
              deleteButton(),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputTextField(BuildContext context) {
    return Card(
      child: TextField(
        controller: _usernameController,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.next,
        style: TextStyle(fontSize: 17),
        keyboardType: TextInputType.text,
        cursorColor: Colors.red,
        onChanged: (text) {
          setState(() {
            username = text;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: new EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          hintStyle: TextStyle(fontSize: 17),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0.0),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
      ),
    );
  }

  Widget deleteButton() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: double.infinity),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0.0,
            primary: widget.username.toLowerCase() == username.toLowerCase() ? Colors.red : Colors.grey.shade200,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
          ),
          onPressed: widget.username.toLowerCase() == username.toLowerCase()
              ? () => !isLoading ? deleteAccount() : null
              : null,
          child: Text(
            'Delete my account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorPalette.white,
            ),
          ),
        ),
      ),
    );
  }

  Future deleteAccount() async {
    setState(() => isLoading = true);
    await _userService.updateDeleteProp(true);
    _usernameController.text = '';
    var dialogResponse = await showCupertinoAlert(
      context,
      'Account deleted successfully',
      'Sorry to see you go. You can always create a new account at anytime.',
      'GOODBYE',
      '',
      '',
      false,
    );
    if (dialogResponse) {
      await logout(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    MyAppState.currentUser!.active = false;
    MyAppState.currentUser!.emailPasswordLogin = false;
    MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
    _userService.updateCurrentUser(MyAppState.currentUser!);
    await auth.FirebaseAuth.instance.signOut();
    MyAppState.currentUser = User();
    pushAndRemoveUntil(context, LoginScreen(), false, false);
  }
}
