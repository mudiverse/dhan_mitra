import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Step 1: Sign out of any existing Google account to allow fresh login
      await _googleSignIn.signOut();

      // Step 2: Begin Google sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) {
        // User cancelled login
        return null;
      }

      // Step 3: Obtain authentication tokens
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Step 4: Create Firebase credential using tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Step 5: Sign in to Firebase and return the result
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In failed: $e');
      return null;
    }
  }

  // Sign out of both Google and Firebase
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();        // Google sign out
    await _auth.signOut();                // Firebase sign out
  }
}
