import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/auth/facebook_auth_service.dart';
import 'package:kick_chat/services/auth/google_auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/dob/DateOfBirthScreen.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:kick_chat/ui/auth/phone/PhoneNumberInputScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpWithEmail.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';

class SignUpScreen extends StatelessWidget {
  final UserService _userService = UserService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  top: 32,
                  right: 16,
                  bottom: 8,
                ),
                child: Text(
                  'Sign up for KickChat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorPalette.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 40.0,
                  left: 40.0,
                  top: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      pushAndRemoveUntil(
                        context,
                        PhoneNumberInputScreen(type: 'signup'),
                        false,
                        false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      primary: ColorPalette.white,
                      textStyle: TextStyle(color: ColorPalette.primary),
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: ColorPalette.primary),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Icon(Icons.phone_outlined, color: ColorPalette.primary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Phone number',
                              style: TextStyle(
                                color: ColorPalette.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 40.0,
                  left: 40.0,
                  top: 15,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpWithEmail(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      primary: Colors.white,
                      textStyle: TextStyle(color: ColorPalette.primary),
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: ColorPalette.primary),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Icon(Icons.email_outlined, color: ColorPalette.primary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Email/password',
                              style: TextStyle(
                                color: ColorPalette.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 40.0,
                  left: 40.0,
                  top: 15,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: ElevatedButton(
                    onPressed: () => facebookAuth(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      primary: Colors.white,
                      textStyle: TextStyle(color: ColorPalette.primary),
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: ColorPalette.primary),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Icon(Icons.facebook_outlined, color: ColorPalette.primary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Facebook',
                              style: TextStyle(
                                color: ColorPalette.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 40.0,
                  left: 40.0,
                  top: 15,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: ElevatedButton(
                    onPressed: () => googleAuth(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      primary: Colors.white,
                      textStyle: TextStyle(color: ColorPalette.primary),
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: ColorPalette.primary),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        Icon(Icons.phone_outlined, color: ColorPalette.primary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Google',
                              style: TextStyle(
                                color: ColorPalette.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, _createRoute());
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Log in",
                            style: TextStyle(
                              fontSize: 17,
                              color: ColorPalette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'By using this app, you agree to our Privacy Policy and Terms of Service, available',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: ' Here',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.black,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print('clicking...');
                      },
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> facebookAuth(BuildContext context) async {
    try {
      final LoginResult fbResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      var userData = await FacebookAuth.instance.getUserData();
      dynamic result = await _facebookAuthService.loginWithFacebook(
        userData,
        fbResult,
      );

      if (result != null && result is User) {
        if (!result.deleted) {
          result.active = true;
          result.lastOnlineTimestamp = Timestamp.now();
          result.emailPasswordLogin = false;
          _userService.updateCurrentUser(result);
          MyAppState.currentUser = result;
          MyAppState.reduxStore!.dispatch(CreateUserAction(result));
          pushAndRemoveUntil(
            context,
            NavScreen(),
            false,
            true,
            'Signing up, Please wait...',
          );
        } else {
          final snackBar = SnackBar(
            content: Text('Sorry, account does not exist.'),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else if (result != null && result is auth.UserCredential) {
        MyAppState.reduxStore!.dispatch(
          CreateUserAction(
            User(
              email: result.user?.email ?? '',
              password: '',
              profilePictureURL: userData['picture']['data']['url'],
            ),
          ),
        );
        pushAndRemoveUntil(
          context,
          DateOfBirthScreen('signup', 'facebook', result),
          false,
          true,
          'Please wait...',
        );
      }
    } catch (error) {
      final snackBar = SnackBar(
        content: Text('Error authenticating. Please try again later.'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> googleAuth(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      dynamic result = await _googleAuthService.signInWithGoogle(googleUser);

      if (result != null && result is User) {
        if (!result.deleted) {
          result.active = true;
          result.lastOnlineTimestamp = Timestamp.now();
          result.emailPasswordLogin = false;
          _userService.updateCurrentUser(result);
          MyAppState.currentUser = result;
          MyAppState.reduxStore!.dispatch(CreateUserAction(result));
          pushAndRemoveUntil(
            context,
            NavScreen(),
            false,
            true,
            'Signing up, Please wait...',
          );
        } else {
          final snackBar = SnackBar(
            content: Text('Sorry, account does not exist.'),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else if (result != null && result is auth.UserCredential) {
        MyAppState.reduxStore!.dispatch(
          CreateUserAction(
            User(
              email: result.user?.email ?? '',
              password: '',
              profilePictureURL: googleUser!.photoUrl!,
            ),
          ),
        );
        pushAndRemoveUntil(
          context,
          DateOfBirthScreen('signup', 'google', result),
          false,
          true,
          'Please wait...',
        );
      }
    } catch (error) {
      final snackBar = SnackBar(
        content: Text('Error authenticating. Please try again later.'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
