import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/services/auth/facebook_auth_service.dart';
import 'package:kick_chat/services/auth/google_auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/dob/DateOfBirthScreen.dart';
import 'package:kick_chat/ui/auth/login/LoginWithEmail.dart';
import 'package:kick_chat/ui/auth/phone/PhoneNumberInputScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpScreen.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:redux/redux.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  UserService _userService = UserService();
  FacebookAuthService _facebookAuthService = FacebookAuthService();
  GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, Function(User)>(
        converter: (Store<AppState> store) => (user) => store.dispatch(CreateUserAction(user)),
        builder: (context, callback) => Container(
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
                    'Log in to KickChat',
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
                          PhoneNumberInputScreen(type: 'login'),
                          false,
                          false,
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
                          Icon(Icons.phone_outlined, color: Colors.blue),
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
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginWithEmail(),
                          ),
                        ),
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shadowColor: Colors.transparent,
                        primary: Colors.white,
                        textStyle: TextStyle(color: Colors.blue),
                        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          side: BorderSide(color: ColorPalette.primary),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          Icon(Icons.email_outlined, color: Colors.blue),
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
                        textStyle: TextStyle(color: Colors.blue),
                        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          side: BorderSide(color: ColorPalette.primary),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          Icon(
                            Icons.facebook_outlined,
                            color: ColorPalette.primary,
                          ),
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
                        textStyle: TextStyle(color: Colors.blue),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
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
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 17,
                              color: ColorPalette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> setFinishedOnBoarding() async {
    return _sharedPreferences.setSharedPreferencesBool(FINISHED_ON_BOARDING, true);
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
        result.active = true;
        result.lastOnlineTimestamp = Timestamp.now();
        result.emailPasswordLogin = false;
        _userService.updateCurrentUser(result);
        MyAppState.currentUser = result;
        MyAppState.reduxStore!.dispatch(CreateUserAction(result));
        setFinishedOnBoarding();
        pushAndRemoveUntil(
          context,
          NavScreen(),
          false,
          true,
          'Logging in, Please wait...',
        );
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
          DateOfBirthScreen('login', 'facebook', result),
          false,
          true,
          'Please wait...',
        );
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('Error authenticating. Please try again later.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> googleAuth(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      dynamic result = await _googleAuthService.signInWithGoogle(googleUser);

      if (result != null && result is User) {
        result.active = true;
        result.lastOnlineTimestamp = Timestamp.now();
        result.emailPasswordLogin = false;
        _userService.updateCurrentUser(result);
        MyAppState.currentUser = result;
        MyAppState.reduxStore!.dispatch(CreateUserAction(result));
        setFinishedOnBoarding();
        pushAndRemoveUntil(
          context,
          NavScreen(),
          false,
          true,
          'Logging in, Please wait...',
        );
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
          DateOfBirthScreen('login', 'google', result),
          false,
          true,
          'Please wait...',
        );
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('Error authenticating. Please try again later.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
