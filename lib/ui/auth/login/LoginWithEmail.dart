import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:kick_chat/ui/auth/password/RequestPasswordResetToken.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';

class LoginWithEmail extends StatefulWidget {
  const LoginWithEmail({Key? key}) : super(key: key);

  @override
  _LoginWithEmailState createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  AuthService _authService = AuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();

  bool validEmail = false;
  bool validPassword = false;
  int passwordLength = 0;
  bool togglePassword = false;
  bool userEmailDoesNotExist = false;
  bool userPasswordDoesNotExist = false;
  int usernameLength = 0;
  String loginButtonText = 'Log in';

  Future<bool> setFinishedOnBoarding() async {
    return _sharedPreferences.setSharedPreferencesBool(FINISHED_ON_BOARDING, true);
  }

  Future<void> checkIfEmailExist(callback) async {
    setState(() {
      userEmailDoesNotExist = false;
    });
    bool emailExist = await _authService.checkIfEmailExist(
      _emailController.text.trim(),
    );
    if (emailExist) {
      _loginWithEmail(callback);
    } else {
      setState(() {
        userEmailDoesNotExist = true;
        loginButtonText = 'Log in';
      });
    }
  }

  Future _loginWithEmail(callback) async {
    setState(() {
      userPasswordDoesNotExist = false;
    });
    try {
      auth.UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User user = await _authService.loginWithEmailAndPassword(
        result.user?.uid ?? '',
      );
      if (user is User) {
        callback(user); // add user to redux store
        MyAppState.currentUser = user;
        setFinishedOnBoarding();
        pushAndRemoveUntil(
          context,
          NavScreen(),
          false,
          true,
          'Please wait...',
        );
      } else if (user is String) {
        setState(() {
          loginButtonText = 'Log in';
        });
        final snackBar = SnackBar(content: Text(user.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on auth.FirebaseAuthException catch (error) {
      setState(() {
        loginButtonText = 'Log in';
      });
      switch (error.code) {
        case "invalid-email":
          return 'Email address is malformed.';
        case "wrong-password":
          setState(() {
            userPasswordDoesNotExist = true;
          });
          return 'Wrong password.';
        case "user-not-found":
          return 'No user corresponding to the given email address.';
        case "user-disabled":
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.';
      }
      // to be removed
      final snackBar = SnackBar(content: Text('Login failed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
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
          onPressed: () => pushAndRemoveUntil(context, LoginScreen(), false, false),
        ),
      ),
      body: StoreConnector<AppState, Function(User)>(
        converter: (Store<AppState> store) => (user) => store.dispatch(CreateUserAction(user)),
        builder: (context, callback) => Form(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 16),
                child: Text(
                  'Log in',
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
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.next,
                    controller: _emailController,
                    onChanged: (text) {
                      bool isEmailValid = validateEmail(text);
                      if (isEmailValid) {
                        setState(() {
                          validEmail = true;
                        });
                      } else {
                        setState(() {
                          validEmail = false;
                        });
                      }

                      if (text.length == 0) {
                        setState(() {
                          validEmail = false;
                        });
                      }
                    },
                    style: TextStyle(fontSize: 17),
                    keyboardType: TextInputType.text,
                    cursorColor: ColorPalette.primary,
                    decoration: InputDecoration(
                      contentPadding: new EdgeInsets.only(left: 16, right: 16),
                      suffixIcon: !validEmail
                          ? null
                          : Icon(
                              Icons.check,
                              color: ColorPalette.primary,
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
                  child: userEmailDoesNotExist
                      ? Text(
                          'Email does not exist',
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
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    obscureText: !togglePassword,
                    controller: _passwordController,
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
                    onFieldSubmitted: (password) {},
                    textInputAction: TextInputAction.done,
                    style: TextStyle(fontSize: 17),
                    cursorColor: ColorPalette.primary,
                    decoration: InputDecoration(
                      contentPadding: new EdgeInsets.only(left: 16, right: 16),
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
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding: EdgeInsets.only(top: 4.0, right: 24.0, left: 24.0),
                  child: userPasswordDoesNotExist
                      ? Text(
                          'Password is invalid',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        )
                      : Text(''),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RequestPasswordResetToken()),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: (!validEmail && !validPassword)
                          ? ColorPalette.grey
                          : ColorPalette.primary,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    onPressed:
                        validEmail && validPassword ? () => checkIfEmailExist(callback) : null,
                    child: Text(
                      loginButtonText,
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
}
