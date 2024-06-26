import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/UserModel.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
