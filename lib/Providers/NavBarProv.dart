import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/History.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Home/HomePage.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Profile/Profile.dart';

class NavBarProv extends ChangeNotifier {
  List<Widget> _body = [
    const HomePage(),
    const HistoryPage(),
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

  Future<void> logout() async {
    currentIndex = 0;
  }
}
