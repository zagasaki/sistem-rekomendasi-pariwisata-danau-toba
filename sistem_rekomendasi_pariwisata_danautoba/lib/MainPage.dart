import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = context.read<UserProvider>().uid;

    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        context.read<UserProvider>().updateUserData(
              userData['username'],
              userData['email'],
              userData['phone'],
              userData['profilephoto'],
            );
      }
    }
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
