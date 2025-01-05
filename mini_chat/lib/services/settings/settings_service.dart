import 'package:flutter/material.dart';
import 'package:mini_chat/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void deleteUserAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // Confirm delete button
          TextButton(
            onPressed: () async {
              try {
                // take current user id
                final String userId = _auth.currentUser!.uid;
                
                // delete user from friends list of other users
                final QuerySnapshot usersSnapshot = await _firestore
                  .collection("Users")
                  .get();
              
                for (var userDoc in usersSnapshot.docs) {
                  if (userDoc.id != userId) {
                   await _firestore
                      .collection("Users")
                      .doc(userDoc.id)
                      .update({
                    'friends': FieldValue.arrayRemove([userId])
                  });
                }
              }

                // Xóa dữ liệu user từ Firestore
                await _firestore.collection("Users").doc(userId).delete();
                
                // Xóa các tin nhắn liên quan
                final QuerySnapshot chatRooms = await _firestore
                    .collection("chat_rooms")
                    .get();
                
                for (var doc in chatRooms.docs) {
                  if (doc.id.contains(userId)) {
                    await doc.reference.delete();
                  }
                }

                await _authService.deleteUser();
                // Đóng dialog và trang settings
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              } catch (e) {
                // Show error if any
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(e.toString()),
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

} 