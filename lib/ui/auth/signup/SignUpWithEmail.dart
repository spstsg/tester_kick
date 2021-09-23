import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/auth/dob/DateOfBirthScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpScreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignUpWithEmail extends StatefulWidget {
  final String email;
  const SignUpWithEmail([this.email = '']);

  @override
  _SignUpWithEmailState createState() => _SignUpWithEmailState();
}

class _SignUpWithEmailState extends State<SignUpWithEmail> {
  AuthService _authService = AuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool validEmail = false;
  bool validPassword = false;
  int passwordLength = 0;
  bool togglePassword = false;
  bool userEmailExist = false;
  String signupNextButton = 'Next';

  Future<void> checkIfEmailExist() async {
    setState(() {
      userEmailExist = false;
    });
    var emailExist = await _authService.checkIfEmailExist(
      _emailController.text.trim(),
    );
    if (!emailExist) {
      MyAppState.reduxStore!.dispatch(CreateUserAction(
        User(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ));
      pushAndRemoveUntil(
        context,
        DateOfBirthScreen('signup', 'email', ''),
        false,
        true,
        'Please wait...',
      );
    } else {
      setState(() {
        userEmailExist = true;
        signupNextButton = 'Next';
      });
    }
  }

  @override
  void initState() {
    if (widget.email != '') {
      _emailController.text = widget.email;
      setState(() {
        validEmail = true;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          onPressed: () => pushAndRemoveUntil(context, SignUpScreen(), false, false),
        ),
      ),
      body: Form(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 16),
              child: Text(
                'Sign up',
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  right: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      controller: _emailController,
                      onChanged: (text) {
                        var isEmailValid = validateEmail(text);
                        if (isEmailValid)
                          setState(() {
                            validEmail = true;
                          });
                        else
                          setState(() {
                            validEmail = false;
                          });

                        if (text.length == 0)
                          setState(() {
                            validEmail = false;
                          });
                      },
                      style: TextStyle(fontSize: 17),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: ColorPalette.primary,
                      decoration: InputDecoration(
                        suffixIcon: !validEmail
                            ? null
                            : Icon(
                                Icons.check,
                                color: ColorPalette.primary,
                              ),
                        contentPadding: new EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        hintText: 'Email',
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
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
                child: userEmailExist
                    ? Text(
                        'Email is already in use',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      )
                    : Text(''),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (text) {
                        setState(() {
                          passwordLength = text.length;
                          validPassword = false;
                        });
                        var isValidPassword = validatePassword(text);
                        if (isValidPassword == true)
                          setState(() {
                            validPassword = true;
                          });
                        if (text.length == 0)
                          setState(() {
                            validPassword = false;
                          });
                        if (text.length < 8)
                          setState(() {
                            validPassword = false;
                          });
                      },
                      obscureText: !togglePassword,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 17),
                      cursorColor: ColorPalette.primary,
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          icon: Icon(
                            !togglePassword ? MdiIcons.eyeOffOutline : MdiIcons.eyeOutline,
                            color: ColorPalette.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              togglePassword = !togglePassword;
                            });
                          },
                        ),
                        hintText: 'Password',
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 6),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: EdgeInsets.only(
                  right: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your password must have:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: passwordLength < 8 ? ColorPalette.grey : Colors.green,
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
                          color: validPassword ? Colors.green : ColorPalette.grey,
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
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:
                        (!validEmail && !validPassword) ? ColorPalette.grey : ColorPalette.primary,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  onPressed: validEmail && validPassword ? () => checkIfEmailExist() : null,
                  child: Text(
                    signupNextButton,
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
