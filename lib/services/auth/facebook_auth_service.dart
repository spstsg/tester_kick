import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/services/user/user_service.dart';

class FacebookAuthService {
  UserService _userService = UserService();

  Future<dynamic> loginWithFacebook(dynamic userData, LoginResult fbResult) async {
    if (fbResult.status != LoginStatus.cancelled) {
      final AccessToken accessToken = fbResult.accessToken!;
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(
        auth.FacebookAuthProvider.credential(accessToken.token),
      );
      User? user = await _userService.getCurrentUser(userCredential.user?.uid ?? '');

      if (user is User) {
        return user;
      } else {
        return userCredential;
      }
    }
  }
}
