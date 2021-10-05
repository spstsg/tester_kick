import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/image_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/search/search_service.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/ui/auth/username/SetUsernameScreen.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SetTeamNameScreen extends StatefulWidget {
  final String type;
  final String pageType;
  final dynamic result;
  SetTeamNameScreen(this.result, [this.type = '', this.pageType = '']);

  @override
  _SetTeamNameScreenState createState() => _SetTeamNameScreenState();
}

class _SetTeamNameScreenState extends State<SetTeamNameScreen> {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  FileService _fileService = FileService();
  AuthService _authService = AuthService();
  SearchService _searchService = SearchService();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  TextEditingController _searchController = TextEditingController();
  User? userData;
  String usernameSignupButton = 'Sign up';
  List<String> clubs = [];
  bool isLoading = false;
  String cloudinaryAppEndpoint = dotenv.get('CLOUDINARY_APP_ENDPOINT');

  @override
  void initState() {
    userData = MyAppState.reduxStore!.state.user;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          onPressed: () => push(context, SetUsernameScreen(widget.result, widget.type, widget.pageType)),
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
                      'Set primary team',
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
                      'Search and select the main team you support.',
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
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 17),
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: ColorPalette.primary,
                              onChanged: (input) async {
                                if (input.isNotEmpty) {
                                  var clubList = await _searchService.searchClubs(input);
                                  setState(() {
                                    clubs = clubList;
                                  });
                                } else {
                                  setState(() {
                                    clubs = [];
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: new EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                ),
                                hintText: 'Enter search',
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
                SizedBox(height: 25),
                Visibility(
                  visible: clubs.isNotEmpty,
                  child: Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(clubs[index]),
                          onTap: () {
                            _searchController.text = clubs[index];
                            setState(() {
                              clubs = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: clubs.isEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          onPrimary: Colors.grey.shade200,
                          primary: _searchController.text.isNotEmpty && !isLoading
                              ? ColorPalette.primary
                              : Colors.grey.shade200,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        onPressed:
                            _searchController.text.isNotEmpty ? () => !isLoading ? _authentication() : null : null,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _authentication() async {
    setState(() => isLoading = true);
    if (widget.result is auth.UserCredential) {
      _authenticateWithoutEmail();
    } else {
      _authenticateWithEmail();
    }
  }

  Future<bool> setFinishedOnBoarding() async {
    return _sharedPreferences.setSharedPreferencesBool(FINISHED_ON_BOARDING, true);
  }

  uploadProfileImage(String avatarProfileColor, String userId) async {
    var response;
    if (userData!.profilePictureURL != '') {
      final profileUrlImage = await convertSocialProfileUrlToImage(userData!.profilePictureURL);
      response = await _fileService.uploadSingleFile(
        profileUrlImage.path,
        userData!.username.toLowerCase(),
        true,
        true,
      );
    } else {
      ByteData? pngBytes = await createProfileAvatar(
        hexStringToColor(avatarProfileColor),
        Size(256, 256),
        capitalizeFirstLetter(userData!.username),
      );
      final avatarImageFile = await writeBufferToFile(pngBytes!);
      response = await _fileService.uploadSingleFile(
        avatarImageFile.path,
        userData!.username.toLowerCase(),
        true,
        true,
      );
    }
    if (response.isSuccessful && response.secureUrl.isNotEmpty) {
      ImageModel userImage = ImageModel(
        userId: userId,
        profilePicture: '$cloudinaryAppEndpoint/${response.publicId}',
      );
      await _fileService.addUserImageFile(userImage, '$cloudinaryAppEndpoint/${response.publicId}');
      return response;
    }
  }

  Future _authenticateWithoutEmail() async {
    try {
      final avatarProfileColor = avatarColor();
      final imageUrl = await uploadProfileImage(avatarProfileColor, widget.result.user!.uid);
      if (imageUrl.isSuccessful) {
        User user = await _authService.firebaseCreateSignUpUser(
          userData!.email,
          userData!.password,
          capitalizeFirstLetter(userData!.username),
          userData!.dob,
          userData!.phoneNumber,
          '$cloudinaryAppEndpoint/${imageUrl.publicId}',
          avatarProfileColor,
          _searchController.text.trim(),
          false,
          widget.result,
        );

        if (user is User) {
          MyAppState.currentUser = user;
          MyAppState.reduxStore!.dispatch(CreateUserAction(user));
          setFinishedOnBoarding();
          push(context, NavScreen());
        } else if (user is String) {
          setState(() {
            usernameSignupButton = 'Sign up';
          });
          final snackBar = SnackBar(content: Text(user.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (error) {
      setState(() {
        usernameSignupButton = 'Sign up';
        isLoading = false;
      });
      String message = 'Couldn\'t sign up. Please try again.';
      final snackBar = SnackBar(content: Text(message.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future _authenticateWithEmail() async {
    try {
      final avatarProfileColor = avatarColor();
      auth.UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userData!.email,
        password: userData!.password,
      );
      final imageUrl = await uploadProfileImage(avatarProfileColor, result.user!.uid);
      if (imageUrl.isSuccessful) {
        User user = await _authService.firebaseCreateSignUpUser(
          userData!.email,
          userData!.password,
          capitalizeFirstLetter(userData!.username),
          userData!.dob,
          userData!.phoneNumber,
          '$cloudinaryAppEndpoint/${imageUrl.publicId}',
          avatarProfileColor,
          _searchController.text.trim(),
          true,
          result,
        );
        if (user is User) {
          MyAppState.currentUser = user;
          MyAppState.reduxStore!.dispatch(CreateUserAction(user));
          setFinishedOnBoarding();
          push(context, NavScreen());
        } else if (user is String) {
          setState(() {
            usernameSignupButton = 'Sign up';
          });
          final snackBar = SnackBar(content: Text(user.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } on auth.FirebaseAuthException catch (error) {
      setState(() {
        usernameSignupButton = 'Sign up';
        isLoading = false;
      });
      String message = 'Couldn\'t sign up. Please try again.';
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';

          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      final snackBar = SnackBar(content: Text(message.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      setState(() {
        usernameSignupButton = 'Sign up';
        isLoading = false;
      });
      final snackBar = SnackBar(content: Text('Error creating an account. Try again later'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
