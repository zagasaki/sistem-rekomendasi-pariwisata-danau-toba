import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/Hotel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/kuliner.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/Story.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/Vacations.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.hotel_rounded, 'name': 'Hotels'},
    {'icon': Icons.directions_boat_filled, 'name': 'Ships'},
    {'icon': Icons.map_rounded, 'name': 'Vacations'},
    {'icon': Icons.book_rounded, 'name': 'Moments'},
    {'icon': Icons.restaurant_rounded, 'name': 'Culinary'},
    {'icon': Icons.directions_bus_filled_rounded, 'name': 'Bus'},
  ];

  void _onFeatureTap(String featureName) {
    // Handle navigation based on the feature tapped
    switch (featureName) {
      case 'Hotels':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HotelScreen()),
        );
        break;
      case 'Ships':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KapalPage()),
        );
        break;
      case 'Vacations':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Vacations()),
        );
        break;
      case 'Moments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Story()),
        );
        break;
      case 'Culinary':
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
    final double iconSize = screenSize.width * 0.06;
    final double fontSize = screenSize.width * 0.035;

    return Scaffold(
      backgroundColor: color1,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: screenSize.height * 0.55,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/homeimage.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: screenSize.height * 0.18,
                  left: screenSize.width * 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's Explore The Toba Lake",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Hi, ${user.username}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: screenSize.height * 0.27,
                  left: screenSize.width * 0.00,
                  right: screenSize.width * 0.00,
                  child: Container(
                    height: screenSize.height * 0.3,
                    width: screenSize.width * 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: features.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.6,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () => _onFeatureTap(features[index]['name']),
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: color2,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    features[index]['icon'],
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: screenSize.height * 0.01),
                                  Text(
                                    features[index]['name'],
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.02),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recommended For You",
                    style: TextStyle(
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin:
                              EdgeInsets.only(right: screenSize.width * 0.03),
                          width: screenSize.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: screenSize.height * 0.15,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  image: DecorationImage(
                                    image: AssetImage('assets/homeimage.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.all(screenSize.width * 0.03),
                                child: Text(
                                  "Popular Offer ${index + 1}",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Text(
                    "Hotel Near You",
                    style: TextStyle(
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin:
                              EdgeInsets.only(right: screenSize.width * 0.03),
                          width: screenSize.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: screenSize.height * 0.15,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  image: DecorationImage(
                                    image: AssetImage('assets/homeimage.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.all(screenSize.width * 0.03),
                                child: Text(
                                  "Hotel ${index + 1}",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width * 0.03),
                                child: Text(
                                  "\$${100 + index * 50}/night",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
