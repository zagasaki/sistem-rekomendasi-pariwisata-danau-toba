import 'package:flutter/material.dart';

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

  void initialize() {}
}
