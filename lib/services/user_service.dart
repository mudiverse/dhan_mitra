import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _auth = FirebaseAuth.instance; // to access the current user
  final _firestore = FirebaseFirestore.instance; // to access the firestore DB

  // Helper method to get short user ID
  String getShortUserId(String uid) {
    return uid.length >= 6 ? uid.substring(0, 6) : uid;
  }

  // create user doc or  a new user if not presrnt using the authID

  Future<void> createUserIfDocumentNotExists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get the short user ID (first 6 characters)
      final shortUserId = getShortUserId(user.uid);
      
      final userDoc = _firestore.collection('users').doc(shortUserId);
      final docSnapshot = await userDoc.get(); // chek if doc exists?

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? 'User_$shortUserId',
          'email': user.email ?? '',
          'userid': shortUserId, // Store only the short ID
          'createdAt': Timestamp.now(),
        });
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to create user document: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while creating user document: $e');
    }
  }

  //get user Data from firestore DB
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Use short user ID for document reference
      final shortUserId = getShortUserId(user.uid);
      final doc = await _firestore.collection('users').doc(shortUserId).get();
      return doc.data(); // Return the Firestore document data as a map okay
    } on FirebaseException catch (e) {
      throw Exception('Failed to get user data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while getting user data: $e');
    }
  }
}
