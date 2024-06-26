import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/HomePage.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Profile/Profile.dart';

class NavBarProv extends ChangeNotifier {
  List<Widget> _body = [
    const HomePage(),
    const Profile(),
  ];
  inisialisasi() {}

  int currentIndex = 0;
  int get dataCurrentIndex => currentIndex;
  set setCurrentIndex(int val) {
    currentIndex = val;
    notifyListeners();
  }

  List<Widget> get body => _body;
  void updateBody(List<Widget> newBody) {
    _body = newBody;
    notifyListeners();
  }
}
