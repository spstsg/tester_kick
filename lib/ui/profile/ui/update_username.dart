import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';

class UpdateUsername extends StatefulWidget {
  const UpdateUsername({Key? key}) : super(key: key);

  @override
  _UpdateUsernameState createState() => _UpdateUsernameState();
}

class _UpdateUsernameState extends State<UpdateUsername> {
  AuthService _authService = AuthService();
  UserService _userService = UserService();
  TextEditingController _currentUsernameController = TextEditingController();
  TextEditingController _newUsernameController = TextEditingController();

  int usernameLength = 0;
  int newUsernameLength = 0;
  bool usernameExist = true;
  bool newUsernameExist = false;
  bool isLoading = false;

  @override
  void dispose() {
    _currentUsernameController.dispose();
    _newUsernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0.0,
        title: Text('Change username'),
        centerTitle: true,
      ),
      body: Container(
        margin: new EdgeInsets.only(left: 25, right: 25),
        child: ListView(
          children: [
            currentUsername(),
            newUsername(),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    primary: !isLoading ? ColorPalette.primary : Colors.grey.shade200,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  onPressed: newUsernameLength > 3 && newUsernameLength < 10
                      ? () => !isLoading ? _updateUsername() : null
                      : null,
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                            SizedBox(width: 24),
                            Text(
                              'Please wait...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.white,
                              ),
                            )
                          ],
                        )
                      : Text(
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

  Widget currentUsername() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: TextFormField(
                      controller: _currentUsernameController,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 17),
                      keyboardType: TextInputType.text,
                      cursorColor: ColorPalette.primary,
                      onChanged: (text) {
                        setState(() {
                          usernameLength = text.length;
                          newUsernameExist = false;
                          usernameExist = true;
                          isLoading = false;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        hintText: 'Enter your username',
                        hintStyle: TextStyle(fontSize: 17),
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
                  ),
                ),
              ],
            )
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25, top: 5),
            child: Text(
              !usernameExist ? 'Username does not exists' : '',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget newUsername() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      controller: _newUsernameController,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 17),
                      keyboardType: TextInputType.text,
                      cursorColor: ColorPalette.primary,
                      onChanged: (text) {
                        setState(() {
                          newUsernameLength = text.length;
                          newUsernameExist = false;
                          usernameExist = true;
                          isLoading = false;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.only(left: 16, right: 16),
                        hintText: 'Enter your new username',
                        hintStyle: TextStyle(fontSize: 17),
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
                  ),
                ),
              ],
            )
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25, top: 5),
            child: Text(
              newUsernameExist ? 'Username already exists' : '',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<bool> _checkIfUsernameExist(String username) async {
    var userExist = await _authService.checkIfUsernameExist(capitalizeFirstLetter(username));
    if (userExist) {
      setState(() {
        usernameExist = true;
      });
      return true;
    } else {
      setState(() {
        usernameExist = false;
        isLoading = false;
      });
      return false;
    }
  }

  Future _updateUsername() async {
    try {
      setState(() => isLoading = true);
      bool currentUsernameExist = await _checkIfUsernameExist(
        capitalizeFirstLetter(_currentUsernameController.text.trim()),
      );
      if (currentUsernameExist) {
        var newUserExist = await _authService.checkIfUsernameExist(
          capitalizeFirstLetter(_newUsernameController.text.trim()),
        );

        if (!newUserExist) {
          await _userService.updateCurrentUsername(capitalizeFirstLetter(_newUsernameController.text.trim()));
          User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
          MyAppState.currentUser = user;
          var dialogResponse = await showCupertinoAlert(
            context,
            'Username changed successfully',
            'You will be logged out so you can login again.',
            'OK',
            '',
            '',
            false,
          );
          _currentUsernameController.text = '';
          _newUsernameController.text = '';
          if (dialogResponse) {
            await logout(context);
          }
        } else {
          setState(() {
            newUsernameExist = true;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(
          'Error updating username. Try again later.',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
