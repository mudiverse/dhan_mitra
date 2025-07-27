import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get short user ID
  String getShortUserId(String uid) {
    return uid.length >= 6 ? uid.substring(0, 6) : uid;
  }

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

      // Step 5: Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Step 6: Create or update user document with short ID
      if (userCredential.user != null) {
        final shortUserId = getShortUserId(userCredential.user!.uid);
        final userDoc = _firestore.collection('users').doc(shortUserId);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'name': userCredential.user!.displayName ?? 'User_$shortUserId',
            'email': userCredential.user!.email ?? '',
            'userid': shortUserId,
            'createdAt': Timestamp.now(),
          });
        }
      }

      return userCredential;
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
