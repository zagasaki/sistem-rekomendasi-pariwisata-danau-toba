import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Bus/Bus.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/Hotel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/kuliner.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/Story.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Ships/Ship.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/Vacations.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Home/CulinaryRecomendation.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Home/DestinationRecomendation.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Home/HotelRecomendation.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
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

    fetchRecommendations();
  }

  @override
  void dispose() {
    _controller.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void fetchRecommendations() {
    final userId = context.read<UserProvider>().uid!;
    fetchRecommendedCulinary(userId);
    fetchRecommendedDestination(userId);
    fetchRecommendedHotels(userId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    fetchRecommendations();
  }

  Future<List<KulinerModel>> fetchRecommendedCulinary(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getCulinaryTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('kuliner')
        .where('tags', arrayContainsAny: userTags)
        .limit(5)
        .get();

    List<KulinerModel> recommendedCulinary = [];
    for (var doc in snapshot.docs) {
      recommendedCulinary.add(KulinerModel.fromDocSnapshot(doc));
    }
    return recommendedCulinary;
  }

  Future<List<String>> getCulinaryTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('culinarytags') ?? []);
      return userTags;
    } else {
      return [];
    }
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
      return [];
    }
  }

  Future<List<Hotel>> fetchRecommendedHotels(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getHotelTags(userId);
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

  Future<List<String>> getHotelTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('hoteltags') ?? []);
      return userTags;
    } else {
      return [];
    }
  }

  void _onFeatureTap(String featureName) {
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

  final List<String> imgList = [
    'assets/homeslider/slider1.png',
    'assets/homeslider/slider2.png',
    'assets/homeslider/slider3.png',
  ];

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
                CarouselSlider.builder(
                  itemCount: imgList.length,
                  itemBuilder: (context, index, realIndex) {
                    final imgUrl = imgList[index];
                    return Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Image.asset(
                          imgUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: screenSize.height * 0.5,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 1.0,
                    enlargeCenterPage: true,
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
                  top: screenSize.height * 0.25,
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
                    future: fetchRecommendedHotels(user.uid!),
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
                                            hotel: recommendedHotels[index],
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
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HotelRecommendationListPage(
                                                  userId: user.uid!)));
                                },
                                child:
                                    const Text("See all hotel recomendation"))
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
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DestinationRecommendationPage(
                                                  userId: user.uid!)));
                                },
                                child: const Text(
                                    "See all destination recomendation"))
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  FutureBuilder<List<KulinerModel>>(
                    future: fetchRecommendedCulinary(user.uid!),
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
                        List<KulinerModel> recommendedDestinations =
                            snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Culinary Recommended for You",
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
                                          builder: (context) => KulinerDetail(
                                            kuliner:
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
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CulinaryRecommendationPage(
                                                  userId: user.uid!)));
                                },
                                child: const Text(
                                    "See all culinary recomendation"))
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
