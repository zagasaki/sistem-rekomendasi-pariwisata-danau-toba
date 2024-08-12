// ignore_for_file: use_build_context_synchronously, empty_catches, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/addHotelData.dart';
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
  List<String> searchHistory = [];
  Map<String, Hotel> hotelMap = {};
  bool isLoading = true;
  bool isFetching = false;
  bool hasMoreData = true;
  TextEditingController searchController = TextEditingController();
  DocumentSnapshot? lastDocument;

  String priceFilterState = 'none';
  String ratingFilterState = 'none';
  String latestFilterState = 'none';
  int selectedStarRating = 0;

  String selectedLocationFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var collection = db.collection('hotels').orderBy('name');

    var data = await collection.get();
    setState(() {
      hotels = data.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
      if (data.docs.isNotEmpty) {
        lastDocument = data.docs.last;
      }
      isLoading = false;
    });
  }

  // Future<void> fetchMoreHotels() async {
  //   if (isFetching || !hasMoreData) return;

  //   setState(() {
  //     isFetching = true;
  //   });

  //   FirebaseFirestore db = FirebaseFirestore.instance;
  //   var collection = db
  //       .collection('hotels')
  //       .orderBy('name')
  //       .startAfterDocument(lastDocument!)
  //       .limit(10);

  //   var data = await collection.get();
  //   setState(() {
  //     var newHotels =
  //         data.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
  //     if (newHotels.isNotEmpty) {
  //       hotels.addAll(newHotels);
  //       lastDocument = data.docs.last;
  //     } else {
  //       hasMoreData = false;
  //     }
  //     isFetching = false;
  //   });
  // }

  List<Hotel> filteredHotels(String query) {
    List<Hotel> filteredList = hotels.where((hotel) {
      final hotelNameLower = hotel.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return hotelNameLower.contains(searchLower) &&
          (selectedLocationFilter == 'All' ||
              hotel.address.contains(selectedLocationFilter));
    }).toList();

    // Sorting logic (harga, rating, dsb)
    if (priceFilterState == 'highToLow') {
      filteredList.sort((a, b) => b.price.compareTo(a.price));
    } else if (priceFilterState == 'lowToHigh') {
      filteredList.sort((a, b) => a.price.compareTo(b.price));
    }

    if (ratingFilterState == 'highToLow') {
      filteredList.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (ratingFilterState == 'lowToHigh') {
      filteredList.sort((a, b) => a.rating.compareTo(b.rating));
    }

    if (selectedStarRating > 0) {
      filteredList = filteredList
          .where((hotel) => hotel.rating == selectedStarRating)
          .toList();
    }

    return filteredList;
  }

  void togglePriceFilter() {
    setState(() {
      if (priceFilterState == 'none') {
        priceFilterState = 'highToLow';
      } else if (priceFilterState == 'highToLow') {
        priceFilterState = 'lowToHigh';
      } else {
        priceFilterState = 'none';
      }
    });
  }

  void toggleRatingFilter() {
    setState(() {
      if (ratingFilterState == 'none') {
        ratingFilterState = 'highToLow';
      } else if (ratingFilterState == 'highToLow') {
        ratingFilterState = 'lowToHigh';
      } else {
        ratingFilterState = 'none';
      }
    });
  }

  void selectStarRating(int rating) {
    setState(() {
      if (selectedStarRating == rating) {
        selectedStarRating = 0;
      } else {
        selectedStarRating = rating;
      }
    });
  }

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('hoteltags') ?? []);

        for (String tag in newTags) {
          if (!existingTags.contains(tag)) {
            if (existingTags.length >= 5) {
              existingTags.removeAt(0);
            }
            existingTags.add(tag);
          }
        }

        await userDoc.set({'hoteltags': existingTags}, SetOptions(merge: true));
      } else {
        List<String> uniqueNewTags = newTags.toSet().toList();
        List<String> initialTags = uniqueNewTags.length > 5
            ? uniqueNewTags.sublist(0, 5)
            : uniqueNewTags;
        await userDoc.set({'hoteltags': initialTags});
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final double horizontalPadding = screenWidth * 0.02;
    final double verticalPadding = screenHeight * 0.01;
    final double fontSize = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.05;

    return Scaffold(
      // floatingActionButton: ElevatedButton(
      //     onPressed: () {
      //       Navigator.push(context,
      //           MaterialPageRoute(builder: (context) => const AddHotelPage()));
      //     },
      //     child: const Icon(Icons.add)),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: iconSize),
        actionsIconTheme: IconThemeData(color: Colors.white, size: iconSize),
        centerTitle: true,
        backgroundColor: color2,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search hotel...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white, fontSize: fontSize),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: iconSize),
                  SizedBox(width: horizontalPadding / 2),
                  DropdownButton<String>(
                    value: selectedLocationFilter,
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.white, size: iconSize),
                    dropdownColor: color2,
                    underline: const SizedBox(),
                    items: <String>[
                      'All',
                      'Parapat',
                      'Tongging',
                      'Tuk-tuk',
                      'Simanindo',
                      'Ajibata',
                      'Balige'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      setState(() {
                        selectedLocationFilter = newValue!;
                      });
                      await Future.delayed(const Duration(seconds: 2));
                      await fetchHotels();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: verticalPadding * 2,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterButton(
                  text: _getPriceFilterText(),
                  selected: priceFilterState != 'none',
                  onTap: togglePriceFilter,
                ),
                FilterButton(
                  text: _getRatingFilterText(),
                  selected: ratingFilterState != 'none',
                  onTap: toggleRatingFilter,
                ),
                ...List.generate(5, (index) {
                  int rating = index + 1;
                  return StarFilterButton(
                    rating: rating,
                    selected: selectedStarRating == rating,
                    onTap: () => selectStarRating(rating),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: filteredHotels(searchController.text).length +
                    (isFetching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < filteredHotels(searchController.text).length) {
                    final hotel = filteredHotels(searchController.text)[index];
                    return InkWell(
                      onTap: () async {
                        await updateUserTags(userId!, hotel.tags);

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.3,
                              child: Image.network(
                                hotel.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(horizontalPadding),
                              child: Text(
                                hotel.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: verticalPadding / 2),
                              child: Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < hotel.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: iconSize,
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Text(
                                currencyFormatter.format(hotel.price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: fontSize,
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
                          : Text('No more data',
                              style: TextStyle(fontSize: fontSize)),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPriceFilterText() {
    if (priceFilterState == 'highToLow') {
      return 'High Price';
    } else if (priceFilterState == 'lowToHigh') {
      return 'Low Price';
    } else {
      return 'Price Filter';
    }
  }

  String _getRatingFilterText() {
    if (ratingFilterState == 'highToLow') {
      return 'High Rating';
    } else if (ratingFilterState == 'lowToHigh') {
      return 'Low Rating';
    } else {
      return 'Rating Filter';
    }
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? color2 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class StarFilterButton extends StatelessWidget {
  final int rating;
  final bool selected;
  final VoidCallback onTap;

  const StarFilterButton({
    required this.rating,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? color2 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              '$rating',
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              color: selected ? Colors.white : Colors.black,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
