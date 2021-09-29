import 'dart:math';

import 'package:destiny/destiny.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kick_chat/services/auth/auth_service.dart';
import 'package:kick_chat/services/helper.dart';

class MockUserService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  AuthService _authService = AuthService();
  int counter = 0;

  generateUsers() async {
    final avatarProfileColor = avatarColor();

    var _imageurl = 'https://source.unsplash.com/random/$counter';
    counter++;
    String email = Destiny.email();
    String password = getRandomString(8);
    auth.UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _authService.firebaseCreateSignUpUser(
      email,
      password,
      Destiny.name(),
      '1990-10-10 00:35:58.011',
      '',
      _imageurl,
      avatarProfileColor,
      randomClubs(),
      true,
      result,
    );
  }

  String randomClubs() {
    List<String> clubs = [
      'Arsenal F.C.',
      'Chelsea F.C.',
      'Liverpool F.C.',
      'Manchester United F.C.',
      'Manchester City F.C.',
      'Tottenham Hotspurs F.C.',
      'Everton F.C.',
    ];
    final _random = new Random();
    return clubs[_random.nextInt(clubs.length)];
  }
}
