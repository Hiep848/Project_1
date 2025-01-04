import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  // instance of auth & firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      // save user info if it doeasn't exist
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      );

      return userCredential;  
  } on FirebaseAuthException catch (e) {
    throw Exception(e.code);
    }
  }
  // sign up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      // create user
      UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

      // save user info in a separate doc
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  
  // delete user
  Future<void> deleteUser() async {
    try {
      final String userId = _auth.currentUser!.uid;
      
      // 1. Xóa tất cả chat rooms liên quan
      final QuerySnapshot chatRooms = await _firestore
          .collection("chat_rooms")
          .get();
      
      for (var doc in chatRooms.docs) {
        if (doc.id.contains(userId)) {
          await doc.reference.delete();
        }
      }

      // 2. Xóa document của user trong collection Users
      await _firestore.collection("Users").doc(userId).delete();

      // 3. Cuối cùng mới xóa user trong Authentication
      await _auth.currentUser!.delete();
      
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  // sign out
    Future<void> signOut() async {
      return await _auth.signOut();
    }
  // errors


}