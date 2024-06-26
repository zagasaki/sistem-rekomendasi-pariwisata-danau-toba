import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Components/BottomNavBar.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/NavBarProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi loadUserDataFromSharedPreferences saat initState
    loadUserDataFromSharedPreferences();
  }

  Future<void> loadUserDataFromSharedPreferences() async {
    final user = context.read<UserProvider>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user.updateUserData(
        prefs.getString("username") ?? "",
        prefs.getString("email") ?? "",
        prefs.getString("phone") ?? "",
        prefs.getString("profilephoto") ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NavBarProv>();
    return Scaffold(
      body: prov.body[prov.dataCurrentIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
