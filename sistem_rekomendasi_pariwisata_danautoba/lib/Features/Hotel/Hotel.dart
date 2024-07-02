import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotel/HotelDetail.dart';
import 'HotelModel.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  _HotelScreenState createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  List<Hotel> hotels = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future readData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var data = await db.collection('hotels').get();
    setState(() {
      hotels = data.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
    });
    setState(() {
      isLoading = false;
    });
    print("ini adalah data${(data)}");
  }

  List<Hotel> filteredHotels(String query) {
    return hotels.where((hotel) {
      final hotelNameLower = hotel.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return hotelNameLower.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Cari hotel...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {}); // Trigger rebuild on typing
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                searchController.clear();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredHotels(searchController.text).length,
                itemBuilder: (context, index) {
                  final hotel = filteredHotels(searchController.text)[index];
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HotelDetailPage(
                                      hotel: hotel,
                                    )));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                hotel.imageUrls[0],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                hotel.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Rp. ${hotel.price.toStringAsFixed(0)} / night',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.favorite_border),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
    );
  }
}
