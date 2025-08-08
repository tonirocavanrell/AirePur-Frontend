

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> logInGoogle() => _googleSignIn.signIn();

  static Future logOutGoogle() => _googleSignIn.disconnect();
}