import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  String username = "";
  String email = "";
  String phone = "";
  String? profilephoto;
  String? _uid;

  String? get uid => _uid;

  void setUid(String? uid) {
    _uid = uid;
    notifyListeners();
  }

  void updateProfilePhoto(String? newProfilePhoto) {
    profilephoto = newProfilePhoto;
    notifyListeners();
  }

  void updateUserData(String newUsername, String newEmail, String newPhone,
      String? newProfilePhoto) {
    username = newUsername;
    email = newEmail;
    phone = newPhone;
    profilephoto = newProfilePhoto;
    notifyListeners();
  }

  Future<void> initialize() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      email = user.email ?? "";

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (userDoc.exists) {
        username = userDoc['name'] ?? "";
        phone = userDoc['phone'] ?? "";
        profilephoto = userDoc['profilephoto'];
        notifyListeners();
      }
    }
  }

  Future<void> updateProfile(
      String newUsername, String newPhone, String? newProfilePhoto) async {
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': newUsername,
        'phoneNumber': newPhone,
        'profilephoto': newProfilePhoto,
      });

      updateUserData(newUsername, email, newPhone, newProfilePhoto);
    }
  }

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
