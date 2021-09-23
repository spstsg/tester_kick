import 'package:google_sign_in/google_sign_in.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/services/user/user_service.dart';

class GoogleAuthService {
  UserService _userService = UserService();

  Future<dynamic> signInWithGoogle(GoogleSignInAccount? googleUser) async {
    if (googleUser != null) {
      final GoogleSignInAuthentication googleSignInAuth = await googleUser.authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuth.accessToken,
        idToken: googleSignInAuth.idToken,
      );

      final auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.signInWithCredential(credential);

      User? user = await _userService.getCurrentUser(userCredential.user?.uid ?? '');

      if (user is User) {
        return user;
      } else {
        return userCredential;
      }
    }
  }
}
