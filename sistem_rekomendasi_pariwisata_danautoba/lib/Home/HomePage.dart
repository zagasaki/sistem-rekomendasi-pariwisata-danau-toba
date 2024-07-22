import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Bus/Bus.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/Hotel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/kuliner.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/Story.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Ships/Ship.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/Vacations.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.hotel_rounded, 'name': 'Hotels'},
    {'icon': Icons.directions_boat_filled, 'name': 'Ships'},
    {'icon': Icons.map_rounded, 'name': 'Vacations'},
    {'icon': Icons.book_rounded, 'name': 'Moments'},
    {'icon': Icons.restaurant_rounded, 'name': 'Culinary'},
    {'icon': Icons.directions_bus_filled_rounded, 'name': 'Bus'},
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Destination>> fetchRecommendedDestination(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getDestinationTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('destinations')
        .where('tags', arrayContainsAny: userTags)
        .limit(5)
        .get();

    List<Destination> recommendedDestination = [];
    for (var doc in snapshot.docs) {
      recommendedDestination.add(Destination.fromDocSnapshot(doc));
    }
    return recommendedDestination;
  }

  Future<List<String>> getDestinationTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('vacationtags') ?? []);
      return userTags;
    } else {
      return []; // Jika user tidak ditemukan atau tidak memiliki tags
    }
  }

  Future<List<String>> getUserTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags = List<String>.from(userSnapshot.get('tags') ?? []);
      return userTags;
    } else {
      return []; // Jika user tidak ditemukan atau tidak memiliki tags
    }
  }

  Future<List<Hotel>> fetchRecommendedHotels(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getUserTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('hotels')
        .where('tags', arrayContainsAny: userTags)
        .limit(5)
        .get();

    List<Hotel> recommendedHotels = [];
    for (var doc in snapshot.docs) {
      recommendedHotels.add(Hotel.fromDocSnapshot(doc));
    }
    return recommendedHotels;
  }

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
          MaterialPageRoute(builder: (context) => const ShipTicketOrderPage()),
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
          MaterialPageRoute(builder: (context) => const BusTicketOrderPage()),
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
                        "Let's Explore\nThe Toba Lake",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.06,
                          fontWeight: FontWeight.bold,
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
                  FutureBuilder<List<Hotel>>(
                    future: fetchRecommendedHotels(
                        user.uid!), // Ambil data hotel yang direkomendasikan
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: RotationTransition(
                            turns: _animation,
                            child: const Icon(Icons.donut_large),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox
                            .shrink(); // Tidak ada hotel direkomendasikan
                      } else {
                        List<Hotel> recommendedHotels = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recommended Hotel For You",
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
                                  recommendedHotels.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HotelDetailPage(
                                            hotel: recommendedHotels[
                                                index], // Pass hotel object to detail page
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: screenSize.width * 0.03),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: screenSize.height * 0.15,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(10),
                                              ),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    recommendedHotels[index]
                                                        .imageUrls[0]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(
                                                screenSize.width * 0.03),
                                            child: Text(
                                              recommendedHotels[index].name,
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
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  FutureBuilder<List<Destination>>(
                    future: fetchRecommendedDestination(user.uid!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: RotationTransition(
                            turns: _animation,
                            child: const Icon(Icons.donut_large),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      } else {
                        List<Destination> recommendedDestinations =
                            snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Destination Recommended for You",
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
                                  recommendedDestinations.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DestinationDetailPage(
                                            destination:
                                                recommendedDestinations[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: screenSize.width * 0.03),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: screenSize.height * 0.15,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(10),
                                              ),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    recommendedDestinations[
                                                            index]
                                                        .imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(
                                                screenSize.width * 0.03),
                                            child: Text(
                                              recommendedDestinations[index]
                                                  .name,
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
                            ),
                          ],
                        );
                      }
                    },
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
