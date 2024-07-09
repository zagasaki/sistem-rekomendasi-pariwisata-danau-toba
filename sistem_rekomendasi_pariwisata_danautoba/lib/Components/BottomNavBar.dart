import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/NavBarProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NavBarProv>();
    return BottomNavigationBar(
      selectedLabelStyle:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      selectedIconTheme: const IconThemeData(size: 15),
      showSelectedLabels: true,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      backgroundColor: color1,
      selectedItemColor: color2,
      onTap: (idx) {
        prov.setCurrentIndex = idx;
      },
      currentIndex: prov.currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 20, color: color2),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_sharp, size: 20, color: color2),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 20, color: color2),
          label: "Profile",
        )
      ],
    );
  }
}
