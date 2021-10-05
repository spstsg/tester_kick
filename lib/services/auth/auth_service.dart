import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/user/user_service.dart';

class AuthService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserService _userService = UserService();
  String kickchatBackendUrl = dotenv.get('KICK_CHAT_BACKEND_URL');

  static getUserIpInfo() async {
    var url = Uri.parse('http://ip-api.com/json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  validateEmail(String email) async {
    String baseUrl = '$kickchatBackendUrl/validate_email?email=$email';
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw 'Could not validate email.';
    }
  }

  firebaseCreateSignUpUser(
    String emailAddress,
    String password,
    String username,
    String dob,
    String phoneNumber,
    String profilePicture,
    String avatarColor,
    String team,
    bool emailPasswordLogin,
    auth.UserCredential result,
  ) async {
    User user = User(
      username: username,
      lowercaseUsername: username.toLowerCase(),
      email: emailAddress,
      settings: UserSettings(),
      password: password,
      lastOnlineTimestamp: Timestamp.now(),
      active: true,
      userID: result.user!.uid,
      fcmToken: await firebaseMessaging.getToken() ?? '',
      profilePictureURL: profilePicture,
      dob: dob,
      phoneNumber: phoneNumber,
      postCount: 0,
      avatarColor: avatarColor,
      uniqueId: getRandomInt(10),
      team: team,
      lowercaseTeam: team.toLowerCase(),
      emailPasswordLogin: emailPasswordLogin,
    );
    String? errorMessage = await firebaseCreateNewUser(user);
    if (errorMessage == null) {
      return user;
    } else {
      return 'Couldn\'t sign up, Please try again.';
    }
  }

  Future<dynamic> loginWithEmailAndPassword(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await firestore.collection(USERS).doc(uid).get();
      User? user;
      if (documentSnapshot.exists) {
        user = User.fromJson(documentSnapshot.data() as Map<String, dynamic>);
        user.fcmToken = await firebaseMessaging.getToken() ?? '';
        user.active = true;
        await _userService.updateCurrentUser(user);
      }
      return user;
    } catch (e) {
      return 'Login failed, Please try again.';
    }
  }

  Future<String?> firebaseCreateNewUser(User user) async =>
      await firestore.collection(USERS).doc(user.userID).set(user.toJson()).then((value) => null, onError: (e) => e);

  Future<bool> checkIfEmailExist(String email) async {
    var userDocument = await FirebaseFirestore.instance.collection(USERS).where('email', isEqualTo: email).get();
    return userDocument.docs.length >= 1 ? true : false;
  }

  Future<bool> checkIfUsernameExist(String username) async {
    var userDocument = await FirebaseFirestore.instance.collection(USERS).where('username', isEqualTo: username).get();
    return userDocument.docs.length >= 1 ? true : false;
  }

  firebaseSubmitPhoneNumber(
    String phoneNumber,
    auth.PhoneCodeAutoRetrievalTimeout? phoneCodeAutoRetrievalTimeout,
    auth.PhoneCodeSent? phoneCodeSent,
    auth.PhoneVerificationFailed? phoneVerificationFailed,
    auth.PhoneVerificationCompleted? phoneVerificationCompleted,
  ) {
    auth.FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted!,
      verificationFailed: phoneVerificationFailed!,
      codeSent: phoneCodeSent!,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout!,
    );
  }

  Future<dynamic> firebaseSubmitPhoneNumberCode(
    String verificationID,
    String code,
    String phoneNumber,
  ) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: code,
    );
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await _userService.getCurrentUser(userCredential.user?.uid ?? '');
    if (user is User) {
      return user;
    } else {
      return userCredential;
    }
  }
}
