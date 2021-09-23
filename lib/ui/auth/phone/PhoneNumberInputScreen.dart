import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/dob/DateOfBirthScreen.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpScreen.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum AppVerificationState {
  SHOW_PHONE_NUMBER_STATE,
  SHOW_OTP_STATE,
}

class PhoneNumberInputScreen extends StatefulWidget {
  final String type;
  PhoneNumberInputScreen({Key? key, required this.type}) : super(key: key);

  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  TextEditingController _otpController = TextEditingController();
  AppVerificationState currentState = AppVerificationState.SHOW_PHONE_NUMBER_STATE;
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  AuthService _authService = AuthService();
  UserService _userService = UserService();
  String _phoneNumber = '';
  String buttonName = 'Send code';
  String verificationID = '';
  String resendToken = '';
  int phoneNumberLength = 0;
  User? userData;
  String deviceCountry = '';

  @override
  void initState() {
    userData = MyAppState.reduxStore!.state.user;
    getUserIPInfo();
    super.initState();
  }

  Future<void> getUserIPInfo() async {
    var userIPInfo = await AuthService.getUserIpInfo();
    if (userIPInfo != null) {
      deviceCountry = userIPInfo['countryCode'];
    } else {
      deviceCountry = 'US';
    }
  }

  Future<bool> setFinishedOnBoarding() async {
    return _sharedPreferences.setSharedPreferencesBool(FINISHED_ON_BOARDING, true);
  }

  /// sends a request to firebase to create a new user using phone number and
  /// navigate to [ContainerScreen] after wards
  phoneAuth() async {
    await _authService.firebaseSubmitPhoneNumber(
      _phoneNumber,
      (String verificationId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code verification timeout, request new code.'),
          ),
        );
        setState(() {
          verificationID = verificationId;
          buttonName = 'Send code';
        });
      },
      (String verificationId, int? forceResendingToken) {
        setState(() {
          verificationID = verificationId;
          currentState = AppVerificationState.SHOW_OTP_STATE;
        });
      },
      (auth.FirebaseAuthException error) {
        String message = 'An error has occurred, please try again.';
        print(error);
        switch (error.code) {
          case 'invalid-verification-code':
            message = 'Invalid code or has been expired.';
            break;
          case 'user-disabled':
            message = 'This user has been disabled.';
            break;
          default:
            message = 'An error has occurred, please try again.';
            break;
        }
        setState(() {
          phoneNumberLength = 0;
          buttonName = 'Send code';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      (auth.PhoneAuthCredential credential) async {},
    );
  }

  /// submits the code to firebase to be validated, then get get the user
  /// object from firebase database
  void _submitCode() async {
    try {
      if (verificationID != '') {
        dynamic result = await _authService.firebaseSubmitPhoneNumberCode(
          verificationID,
          _otpController.text.trim(),
          _phoneNumber,
        );
        if (result != null && result is User) {
          result.active = true;
          result.lastOnlineTimestamp = Timestamp.now();
          _userService.updateCurrentUser(result);
          MyAppState.currentUser = result;
          MyAppState.reduxStore!.dispatch(CreateUserAction(result));
          setFinishedOnBoarding();
          pushAndRemoveUntil(
            context,
            NavScreen(),
            false,
            true,
            'Please wait...',
          );
        } else {
          MyAppState.reduxStore!.dispatch(
            CreateUserAction(
              User(
                email: userData!.email,
                password: userData!.password,
                dob: userData!.dob,
                phoneNumber: _phoneNumber,
              ),
            ),
          );
          pushAndRemoveUntil(
            context,
            DateOfBirthScreen(
              widget.type == 'login' ? "login" : 'signup',
              'phone',
              result,
            ),
            false,
            true,
            'Please wait...',
          );
        }
      } else {
        setState(() {
          currentState = AppVerificationState.SHOW_OTP_STATE;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Couldn\'t get verification ID'),
          duration: Duration(seconds: 6),
        ));
      }
    } on auth.FirebaseAuthException catch (exception) {
      String message = 'An error has occurred, please try again.';
      switch (exception.code) {
        case 'invalid-verification-code':
          message = 'Invalid code or has been expired.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        default:
          message = 'An error has occurred, please try again.';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e, s) {
      print('_PhoneNumberInputScreenState._submitCode $e $s');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error has occurred, please try again.'),
        ),
      );
    }
  }

  Widget phoneNumberWidget(String deviceCountry) {
    return Container(
      margin: new EdgeInsets.only(left: 25, right: 25, bottom: 16),
      child: new Form(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      _phoneNumber = number.phoneNumber.toString();
                      phoneNumberLength = number.phoneNumber!.length;
                    });
                  },
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  inputDecoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(
                      fontSize: 17,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  initialValue: PhoneNumber(isoCode: deviceCountry),
                  keyboardType: TextInputType.phone,
                  autoFocus: true,
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: phoneNumberLength < 8 ? ColorPalette.grey : ColorPalette.primary,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  // onPressed: wait
                  //     ? null
                  //     : () {
                  //         startTimer();
                  //         setState(
                  //           () {
                  //             start = 30;
                  //             wait = true;
                  //             buttonName = 'Resend code';
                  //           },
                  //         );
                  //       },
                  onPressed: phoneNumberLength > 8 ? () => phoneAuth() : null,
                  child: Text(
                    buttonName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget otpWidget() {
    return Container(
      margin: new EdgeInsets.only(left: 25, right: 25, bottom: 16),
      child: new Form(
        child: Column(
          children: [
            new Align(
              alignment: Directionality.of(context) == TextDirection.ltr
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: Text(
                'Verify your phone number',
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            new Align(
              alignment: Directionality.of(context) == TextDirection.ltr
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: Text(
                'We have sent an sms code to $_phoneNumber',
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: PinCodeTextField(
                length: 6,
                appContext: context,
                keyboardType: TextInputType.phone,
                backgroundColor: Colors.transparent,
                textStyle: TextStyle(fontSize: 22),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                controller: _otpController,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeColor: ColorPalette.primary,
                  activeFillColor: Colors.grey.shade100,
                  selectedFillColor: Colors.transparent,
                  selectedColor: ColorPalette.primary,
                  inactiveColor: Colors.grey.shade600,
                  inactiveFillColor: Colors.transparent,
                ),
                enableActiveFill: true,
                onCompleted: (v) {},
                onChanged: (value) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  onPressed: () {
                    _submitCode();
                  },
                  child: Text(
                    'Verify',
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

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: ColorPalette.white),
        title: Text(
          widget.type == 'login' ? "Sign in" : 'Sign up',
          style: TextStyle(
            color: ColorPalette.black,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            MdiIcons.chevronLeft,
            size: 30,
            color: ColorPalette.primary,
          ),
          onPressed: () => pushAndRemoveUntil(
            context,
            widget.type == 'login' ? LoginScreen() : SignUpScreen(),
            false,
            false,
          ),
        ),
      ),
      body: SafeArea(
        child: currentState == AppVerificationState.SHOW_PHONE_NUMBER_STATE
            ? phoneNumberWidget(deviceCountry)
            : otpWidget(),
      ),
    );
  }
}
