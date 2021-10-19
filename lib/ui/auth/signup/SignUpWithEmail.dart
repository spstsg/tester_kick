import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  String emailErrorMessage = '';
  bool isLoading = false;

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
                'signupText'.tr(),
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
                        bool isEmailValid = validateEmail(text);
                        setState(() {
                          validEmail = isEmailValid;
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
                        hintText: 'emailText'.tr(),
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
                        emailErrorMessage,
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
                      textInputAction: TextInputAction.next,
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
                        hintText: 'passwordText'.tr(),
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
                padding: EdgeInsets.only(right: 24.0, left: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'yourPasswordMustHave'.tr(),
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
                          'eightToTwentyCharacters'.tr(),
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
                          'numbersLettersAndSpecialCharacters'.tr(),
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
                    shadowColor: Colors.transparent,
                    onPrimary: Colors.grey.shade200,
                    primary: (!validEmail && !validPassword)
                        ? Colors.grey.shade200
                        : !isLoading
                            ? ColorPalette.primary
                            : Colors.grey.shade200,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                  ),
                  onPressed: validEmail && validPassword ? () => !isLoading ? checkIfEmailExist() : null : null,
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(color: Colors.blue),
                            ),
                          ],
                        )
                      : Text(
                          'nextText'.tr(),
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
      userEmailExist = false;
      isLoading = true;
    });
    // whenever you are testing, you can comment this part
    var validateEmail = await _authService.validateEmail(_emailController.text.trim());
    if (!validateEmail['validators']['mx']['valid'] &&
        !validateEmail['validators']['smtp']['valid'] &&
        !validateEmail['valid']) {
      setState(() {
        emailErrorMessage = 'emailInvalid'.tr();
        userEmailExist = true;
        isLoading = false;
      });
      return;
    }

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
      push(context, DateOfBirthScreen('signup', 'email', ''));
    } else {
      setState(() {
        emailErrorMessage = 'emailAlreadyInUse'.tr();
        userEmailExist = true;
        isLoading = false;
      });
    }
  }
}
