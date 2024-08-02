import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
// Model Hotel

class HotelRecommendationListPage extends StatefulWidget {
  final String userId;

  const HotelRecommendationListPage({super.key, required this.userId});

  @override
  _HotelRecommendationListPageState createState() =>
      _HotelRecommendationListPageState();
}

class _HotelRecommendationListPageState
    extends State<HotelRecommendationListPage> {
  final TextEditingController searchController = TextEditingController();
  bool isFetching = false;
  List<Hotel> allHotels = [];

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<List<Hotel>> fetchAllRecommendedHotels(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getHotelTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('hotels')
        .where('tags', arrayContainsAny: userTags)
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

  Future<void> fetchHotels() async {
    setState(() {
      isFetching = true;
    });

    List<Hotel> hotels = await fetchAllRecommendedHotels(widget.userId);

    setState(() {
      allHotels = hotels;
      isFetching = false;
    });
  }

  List<Hotel> filteredHotels(String query) {
    if (query.isEmpty) {
      return allHotels;
    } else {
      return allHotels
          .where(
              (hotel) => hotel.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: color2,
        title: const Text(
          'Daftar Hotel Rekomendasi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredHotels(searchController.text).length +
                    (isFetching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < filteredHotels(searchController.text).length) {
                    final hotel = filteredHotels(searchController.text)[index];
                    return InkWell(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelDetailPage(hotel: hotel),
                          ),
                        );
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.2,
                              child: Image.network(
                                hotel.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                hotel.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < hotel.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                currencyFormatter.format(hotel.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: isFetching
                          ? const CircularProgressIndicator()
                          : const Text('Tidak ada data lagi'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
