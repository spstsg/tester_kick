import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  UserService _userService = UserService();
  TextEditingController _currentPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  bool currentPasswordNotValid = false;
  bool newPasswordNotValid = false;
  bool confirmPasswordNotValid = false;
  int newPasswordLength = 0;
  bool toggleCurrentPassword = false;
  bool toggleNewPassword = false;
  bool toggleConfirmPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0.0,
        title: Text('Change password'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          currentPassword(),
          newPassword(),
          confirmPassword(),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: !isLoading ? ColorPalette.primary : Colors.grey.shade200,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                onPressed: !currentPasswordNotValid &&
                        _currentPassword.text.isNotEmpty &&
                        newPasswordNotValid &&
                        newPasswordLength >= 8 &&
                        !confirmPasswordNotValid &&
                        _confirmPassword.text.isNotEmpty
                    ? () => !isLoading ? _changePassword(context) : null
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
                        'Change password',
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
    );
  }

  Widget currentPassword() {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              obscureText: !toggleCurrentPassword,
              controller: _currentPassword,
              onChanged: (text) {
                var isValidPassword = validatePassword(text);
                if (isValidPassword == true)
                  setState(() {
                    currentPasswordNotValid = false;
                  });
              },
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 17),
              cursorColor: ColorPalette.primary,
              decoration: InputDecoration(
                contentPadding: new EdgeInsets.only(left: 16, right: 16),
                suffixIcon: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    !toggleCurrentPassword ? MdiIcons.eyeOffOutline : MdiIcons.eyeOutline,
                    color: ColorPalette.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      toggleCurrentPassword = !toggleCurrentPassword;
                    });
                  },
                ),
                hintText: 'Current password',
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
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
            child: Text(
              currentPasswordNotValid ? 'Current password is invalid' : '',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget newPassword() {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              obscureText: !toggleNewPassword,
              controller: _newPassword,
              onChanged: (text) {
                setState(() {
                  newPasswordLength = text.length;
                });
                bool isValidPassword = validatePassword(text);
                setState(() {
                  newPasswordNotValid = isValidPassword;
                });
                if (text.length == 0)
                  setState(() {
                    newPasswordNotValid = true;
                  });
                if (text.length < 8)
                  setState(() {
                    newPasswordNotValid = true;
                  });
              },
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 17),
              cursorColor: ColorPalette.primary,
              decoration: InputDecoration(
                contentPadding: new EdgeInsets.only(left: 16, right: 16),
                suffixIcon: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    !toggleNewPassword ? MdiIcons.eyeOffOutline : MdiIcons.eyeOutline,
                    color: ColorPalette.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      toggleNewPassword = !toggleNewPassword;
                    });
                  },
                ),
                hintText: 'New password',
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
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: EdgeInsets.only(right: 24.0, left: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your password must have:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: ColorPalette.black),
                ),
                SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: newPasswordLength < 8 ? ColorPalette.grey : Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '8 to 20 characers',
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: newPasswordNotValid && newPasswordLength >= 8 ? Colors.green : ColorPalette.grey,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Numbers, letters, and special characters',
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget confirmPassword() {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              obscureText: !toggleConfirmPassword,
              controller: _confirmPassword,
              onChanged: (text) {
                if (_newPassword.text.trim() == _confirmPassword.text.trim()) {
                  setState(() {
                    confirmPasswordNotValid = false;
                  });
                } else {
                  setState(() {
                    confirmPasswordNotValid = true;
                  });
                }
              },
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 17),
              cursorColor: ColorPalette.primary,
              decoration: InputDecoration(
                contentPadding: new EdgeInsets.only(left: 16, right: 16),
                suffixIcon: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    !toggleConfirmPassword ? MdiIcons.eyeOffOutline : MdiIcons.eyeOutline,
                    color: ColorPalette.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      toggleConfirmPassword = !toggleConfirmPassword;
                    });
                  },
                ),
                hintText: 'Confirm password',
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
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
            child: Text(
              confirmPasswordNotValid ? 'Confirm password does not match' : '',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    setState(() => isLoading = true);
    auth.User? user = auth.FirebaseAuth.instance.currentUser;
    bool isValid = await validateCurrentPassword(user);

    if (isValid) {
      try {
        await user!.updatePassword(_newPassword.text.trim());
        setState(() => isLoading = false);
        var dialogResponse = await showCupertinoAlert(
          context,
          'Password changed successfully',
          'You will be logged out so you can login with your new password.',
          'OK',
          '',
          '',
          false,
        );
        _currentPassword.text = '';
        _newPassword.text = '';
        _confirmPassword.text = '';
        if (dialogResponse) {
          await logout(context);
        }
      } on FirebaseAuthException catch (e) {
        setState(() => isLoading = false);
        if (e.code == 'user-not-found') {
          showCupertinoAlert(
            context,
            'Error',
            'No user found for that email.',
            'OK',
            '',
            '',
            false,
          );
        } else if (e.code == 'wrong-password') {
          showCupertinoAlert(
            context,
            'Error',
            'Wrong password provided for user.',
            'OK',
            '',
            '',
            false,
          );
        }
      }
    }
  }

  Future<bool> validateCurrentPassword(auth.User? user) async {
    try {
      final credentials = EmailAuthProvider.credential(
        email: MyAppState.currentUser!.email,
        password: _currentPassword.text,
      );
      await user!.reauthenticateWithCredential(credentials);
      setState(() {
        currentPasswordNotValid = false;
      });
      return true;
    } catch (e) {
      setState(() {
        currentPasswordNotValid = true;
        isLoading = false;
      });
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    MyAppState.currentUser!.active = false;
    MyAppState.currentUser!.emailPasswordLogin = false;
    MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
    _userService.updateCurrentUser(MyAppState.currentUser!);
    await FirebaseAuth.instance.signOut();
    MyAppState.currentUser = null;
    pushAndRemoveUntil(context, LoginScreen(), false, false);
  }
}
