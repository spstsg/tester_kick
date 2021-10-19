import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/auth/phone/PhoneNumberInputScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpWithEmail.dart';
import 'package:kick_chat/ui/auth/username/SetUsernameScreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DateOfBirthScreen extends StatefulWidget {
  final String type;
  final String pageType;
  final dynamic result;
  DateOfBirthScreen(
    this.type,
    this.pageType,
    this.result,
  );

  @override
  _DateOfBirthScreenState createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  TextEditingController _dobController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool isValidDate = false;
  bool eligibleDate = false;
  User? userData;
  bool isLoading = false;

  @override
  void initState() {
    userData = MyAppState.reduxStore!.state.user;
    if (userData!.dob != '') {
      final DateFormat format = DateFormat('d, MMMM yyyy');
      _dobController.text = format.format(DateTime.parse(userData!.dob.toString()));
      final DateTime dobDateTime = DateTime.parse(userData!.dob.toString());
      _selectedDate = dobDateTime;
    }
    super.initState();
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.type == 'login' ? 'signinText'.tr() : 'signupText'.tr(),
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
          onPressed: () => goBack(widget.pageType),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: new EdgeInsets.only(left: 25, right: 25, bottom: 16, top: 16),
          child: new Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'selectDOB'.tr(),
                      style: TextStyle(
                        color: ColorPalette.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'enterDOB'.tr(),
                      style: TextStyle(
                        color: ColorPalette.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 5),
                            child: TextFormField(
                              controller: _dobController,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 17),
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: ColorPalette.primary,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 16, right: 16),
                                suffixIcon: isValidDate
                                    ? Icon(
                                        Icons.check,
                                        color: ColorPalette.primary,
                                      )
                                    : Padding(padding: EdgeInsets.zero),
                                hintText: 'birthdayText'.tr(),
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
                eligibleDate
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Text(
                          'notEligibleError'.tr(),
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: Text(''),
                      ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        onPrimary: Colors.grey.shade200,
                        primary: !isLoading ? ColorPalette.primary : Colors.grey.shade200,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                      ),
                      onPressed: !isLoading ? addDateOfBirth : null,
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
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        backgroundColor: Colors.white,
        builder: (context) => Container(
          child: SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              initialDateTime: _selectedDate,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (DateTime dateTime) {
                setState(() {
                  _selectedDate = dateTime;
                  final DateFormat format = DateFormat('d, MMMM yyyy');
                  _dobController.text = format.format(_selectedDate);
                  var now = DateTime.now();
                  if (_selectedDate != DateTime.now() && (_selectedDate.year < now.year - 16))
                    setState(() {
                      isValidDate = true;
                    });
                  else
                    setState(() {
                      isValidDate = false;
                    });
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  void addDateOfBirth() {
    setState(() {
      eligibleDate = false;
      isLoading = true;
    });
    var now = DateTime.now();
    if (_selectedDate != DateTime.now() && (_selectedDate.year < now.year - 16)) {
      MyAppState.reduxStore!.dispatch(
        CreateUserAction(
          User(
            email: userData!.email,
            password: userData!.password,
            dob: _selectedDate.toString(),
            phoneNumber: userData!.phoneNumber,
            profilePictureURL: userData!.profilePictureURL,
          ),
        ),
      );
      push(context, SetUsernameScreen(widget.result, widget.type, widget.pageType));
    } else {
      setState(() {
        isLoading = false;
        eligibleDate = true;
      });
    }
  }

  void goBack(String pageType) {
    if (pageType == 'email') {
      push(context, SignUpWithEmail(userData!.email));
    } else if (pageType == 'phone') {
      push(
        context,
        PhoneNumberInputScreen(type: 'signup'),
      );
    } else {
      push(context, SignUpScreen());
    }
  }
}
