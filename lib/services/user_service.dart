import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _auth = FirebaseAuth.instance; // to access the current user
  final _firestore = FirebaseFirestore.instance; // to access the firestore DB

  // create user doc or  a new user if not presrnt using the authID

  Future<void> createUserIfDocumentNotExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get(); // chek if doc exists?

    if (!docSnapshot.exists) {
      await userDoc.set({
        'name': user.displayName ?? 'New User',
        'email': user.email ?? '',
        'userid': user.uid,
        'createdAt': Timestamp.now(),
      });
    }
  }

  //get user Data from firestore DB
  Future<Map<String, dynamic>?> getUserData() async {
    //remeber returns a MAP
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data(); // Return the Firestore document data as a map okay

    //rem
  }
}
