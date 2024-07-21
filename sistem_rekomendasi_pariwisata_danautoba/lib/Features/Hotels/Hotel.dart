import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'HotelModel.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  _HotelScreenState createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  List<Hotel> hotels = [];
  bool isLoading = true;
  bool isFetching = false;
  bool hasMoreData = true;
  TextEditingController searchController = TextEditingController();
  DocumentSnapshot? lastDocument;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var collection = db.collection('hotels').orderBy('name').limit(10);

    var data = await collection.get();
    setState(() {
      hotels = data.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
      if (data.docs.isNotEmpty) {
        lastDocument = data.docs.last;
      }
      isLoading = false;
    });
  }

  Future<void> fetchMoreHotels() async {
    if (isFetching || !hasMoreData) return;

    setState(() {
      isFetching = true;
    });

    FirebaseFirestore db = FirebaseFirestore.instance;
    var collection = db
        .collection('hotels')
        .orderBy('name')
        .startAfterDocument(lastDocument!)
        .limit(10);

    var data = await collection.get();
    setState(() {
      var newHotels =
          data.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
      if (newHotels.isNotEmpty) {
        hotels.addAll(newHotels);
        lastDocument = data.docs.last;
      } else {
        hasMoreData = false;
      }
      isFetching = false;
    });
  }

  List<Hotel> filteredHotels(String query) {
    return hotels.where((hotel) {
      final hotelNameLower = hotel.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return hotelNameLower.contains(searchLower);
    }).toList();
  }

  // Fungsi untuk memperbarui tag pengguna
  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('tags') ?? []);

        // Gabungkan tags lama dengan tags baru, lalu ambil 5 tags teratas
        Set<String> updatedTagsSet = {...existingTags, ...newTags};
        List<String> updatedTags =
            updatedTagsSet.toList().sublist(0, min(updatedTagsSet.length, 5));

        // Perbarui data pengguna dengan tags baru yang sudah di-limit
        await userDoc.set({'tags': updatedTags}, SetOptions(merge: true));
      } else {
        // Jika dokumen pengguna tidak ada, buat dokumen baru dengan tags dari hotel
        await userDoc.set({'tags': newTags});
      }

      print('Tags updated successfully.');
    } catch (e) {
      print('Error updating tags: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gantilah userId dengan id pengguna sebenarnya yang masuk
    final userId = context.read<UserProvider>().uid;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: color2,
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
              hintText: 'Cari hotel...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white)),
          onChanged: (value) {
            setState(() {});
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
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  fetchMoreHotels();
                }
                return true;
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredHotels(searchController.text).length +
                      (isFetching ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < filteredHotels(searchController.text).length) {
                      final hotel =
                          filteredHotels(searchController.text)[index];
                      return InkWell(
                        onTap: () async {
                          // Perbarui tag pengguna
                          await updateUserTags(userId!, hotel.tags);

                          // Navigasi ke halaman detail hotel
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelDetailPage(
                                hotel: hotel,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 4 / 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    hotel.imageUrls[0],
                                    fit: BoxFit.cover,
                                  ),
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
                        ),
                      );
                    } else {
                      return Center(
                        child: isFetching
                            ? const CircularProgressIndicator()
                            : const Text('No more data'),
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }
}
