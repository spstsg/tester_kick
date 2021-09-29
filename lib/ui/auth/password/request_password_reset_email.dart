import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RequestPasswordResetEmail extends StatefulWidget {
  const RequestPasswordResetEmail({Key? key}) : super(key: key);

  @override
  _RequestPasswordResetEmailState createState() => _RequestPasswordResetEmailState();
}

class _RequestPasswordResetEmailState extends State<RequestPasswordResetEmail> {
  final _auth = FirebaseAuth.instance;
  AuthService _authService = AuthService();
  TextEditingController _emailController = TextEditingController();

  bool userEmailExist = false;
  bool validEmail = false;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            MdiIcons.chevronLeft,
            size: 30,
            color: ColorPalette.primary,
          ),
          onPressed: () => pushAndRemoveUntil(context, LoginScreen(), false, false),
        ),
      ),
      body: Form(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 16),
              child: Text(
                'Request password reset email',
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 24,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  controller: _emailController,
                  style: TextStyle(fontSize: 17),
                  onChanged: (text) {
                    bool isEmailValid = validateEmail(text);
                    setState(() {
                      validEmail = isEmailValid;
                      userEmailExist = true;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    contentPadding: new EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      fontSize: 17,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).errorColor),
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
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
                child: !userEmailExist && validEmail
                    ? Text(
                        'Email is invalid',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      )
                    : Text(''),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  onPressed: validEmail ? () => checkIfEmailExist() : null,
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
                          'Send email',
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

  Future<void> checkIfEmailExist() async {
    setState(() {
      userEmailExist = true;
      isLoading = true;
    });
    var emailExist = await _authService.checkIfEmailExist(
      _emailController.text.trim(),
    );
    if (emailExist) {
      _passwordResetEmail();
    } else {
      setState(() {
        userEmailExist = false;
        isLoading = false;
      });
    }
  }

  Future<void> _passwordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() => isLoading = false);
      _emailController.text = '';
      showCupertinoAlert(
        context,
        'Email sent',
        'An email has been sent to you, Click the link provided to complete password reset',
        'OK',
        '',
        '',
        false,
      );
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      showCupertinoAlert(
        context,
        'Error',
        'An error occured. Please try again later.',
        'OK',
        '',
        '',
        false,
      );
    }
  }
}
