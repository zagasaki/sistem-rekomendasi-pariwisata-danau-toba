import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotel/Hotel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Kuliner/kuliner.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.hotel_outlined, 'name': 'Hotel'},
    {'icon': Icons.directions_boat_filled_outlined, 'name': 'Kapal'},
    {'icon': Icons.map_outlined, 'name': 'Wisata'},
    {'icon': Icons.book_outlined, 'name': 'Share Story'},
    {'icon': Icons.restaurant_outlined, 'name': 'Kuliner'},
    {'icon': Icons.directions_bus_outlined, 'name': 'Bus'},
  ];

  void _onFeatureTap(String featureName) {
    // Handle navigation based on the feature tapped
    switch (featureName) {
      case 'Hotel':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HotelScreen()),
        );
        break;
      case 'Kapal':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KapalPage()),
        );
        break;
      case 'Wisata':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WisataPage()),
        );
        break;
      case 'Share Story':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShareStoryPage()),
        );
        break;
      case 'Kuliner':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KulinerWidget()),
        );
        break;
      case 'Bus':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BusPage()),
        );
        break;
      default:
        print("Feature not implemented yet");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>();
    final screenSize = MediaQuery.of(context).size;
    final double containerHeight = screenSize.height * 0.35;
    final double iconSize = screenSize.width * 0.06;
    final double fontSize = screenSize.width * 0.035;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: screenSize.height * 0.25,
                decoration: const BoxDecoration(color: Colors.green),
                padding:
                    EdgeInsets.fromLTRB(10, screenSize.height * 0.05, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome To Danau Toba",
                      style: TextStyle(
                          color: Colors.white, fontSize: fontSize * 1.2),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      ("hai, ${user.username}"),
                      style: TextStyle(color: Colors.white, fontSize: fontSize),
                    ),
                    Text(
                      "Ada yang bisa kami bantu untukmu?",
                      style: TextStyle(color: Colors.white, fontSize: fontSize),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
            ],
          ),

          // FITUR BAR
          Positioned(
            top: screenSize.height * 0.19,
            left: 0,
            right: 0,
            child: Container(
              height: containerHeight,
              margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => _onFeatureTap(features[index]['name']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            features[index]['icon'],
                            size: iconSize, // Adjust icon size
                            color: Colors.blue,
                          ),
                          SizedBox(
                              height:
                                  screenSize.height * 0.01), // Adjust height
                          Text(
                            features[index]['name'],
                            style: TextStyle(
                                fontSize: fontSize), // Adjust font size
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder pages for each feature

class KapalPage extends StatelessWidget {
  const KapalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapal Page'),
      ),
      body: const Center(
        child: Text('Welcome to Kapal Page'),
      ),
    );
  }
}

class WisataPage extends StatelessWidget {
  const WisataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisata Page'),
      ),
      body: const Center(
        child: Text('Welcome to Wisata Page'),
      ),
    );
  }
}

class ShareStoryPage extends StatelessWidget {
  const ShareStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Story Page'),
      ),
      body: const Center(
        child: Text('Welcome to Share Story Page'),
      ),
    );
  }
}

class BusPage extends StatelessWidget {
  const BusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Page'),
      ),
      body: const Center(
        child: Text('Welcome to Bus Page'),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
