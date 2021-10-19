import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/auth/dob/DateOfBirthScreen.dart';
import 'package:kick_chat/ui/auth/team/set_team_name.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SetUsernameScreen extends StatefulWidget {
  final String type;
  final String pageType;
  final dynamic result;
  SetUsernameScreen(this.result, [this.type = '', this.pageType = '']);

  @override
  _SetUsernameScreenState createState() => _SetUsernameScreenState();
}

class _SetUsernameScreenState extends State<SetUsernameScreen> {
  AuthService _authService = AuthService();
  TextEditingController _usernameController = TextEditingController();
  User? userData;
  int usernameLength = 0;
  bool usernameExist = false;
  String usernameSignupButton = 'Sign up';
  bool isLoading = false;

  @override
  void initState() {
    userData = MyAppState.reduxStore!.state.user;
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.type == 'login' ? 'Sign in' : 'Sign up',
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
          onPressed: () => push(context, DateOfBirthScreen(widget.type, widget.pageType, '')),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: new EdgeInsets.only(left: 25, right: 25, bottom: 16),
          child: new Form(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Create username',
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
                      'Enter your username. This will be visible to other users.',
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
                              controller: _usernameController,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 17),
                              keyboardType: TextInputType.text,
                              cursorColor: ColorPalette.primary,
                              onChanged: (text) {
                                setState(() {
                                  usernameLength = text.length;
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
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Text(
                      usernameExist ? 'Username already exists' : '',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        onPrimary: Colors.grey.shade200,
                        primary: usernameLength < 3 || usernameLength > 10
                            ? Colors.grey.shade200
                            : !isLoading
                                ? ColorPalette.primary
                                : Colors.grey.shade200,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                      ),
                      onPressed: usernameLength > 3 && usernameLength < 10
                          ? () => !isLoading ? _checkIfUsernameExist() : null
                          : null,
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
                              usernameSignupButton,
                              style: TextStyle(
                                fontSize: 18,
                                color: ColorPalette.white,
                                fontWeight: FontWeight.bold,
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
    );
  }

  Future _checkIfUsernameExist() async {
    setState(() {
      usernameExist = false;
      isLoading = true;
    });
    var userExist = await _authService.checkIfUsernameExist(capitalizeFirstLetter(_usernameController.text.trim()));
    if (!userExist) {
      MyAppState.reduxStore!.dispatch(
        CreateUserAction(
          User(
            username: capitalizeFirstLetter(_usernameController.text.trim()),
            email: userData!.email,
            password: userData!.password,
            dob: userData!.dob,
            phoneNumber: userData!.phoneNumber,
            profilePictureURL: userData!.profilePictureURL,
          ),
        ),
      );
      push(context, SetTeamNameScreen(widget.result, widget.type, widget.pageType));
    } else {
      setState(() {
        usernameExist = true;
        usernameSignupButton = 'Sign up';
        isLoading = false;
      });
    }
  }
}
