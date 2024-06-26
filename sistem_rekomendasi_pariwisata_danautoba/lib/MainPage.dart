import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Components/BottomNavBar.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/NavBarProv.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NavBarProv>();
    return Scaffold(
      body: prov.body[prov.dataCurrentIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
