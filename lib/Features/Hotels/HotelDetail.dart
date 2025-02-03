import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelReview.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'HotelBooking.dart';
import 'HotelModel.dart';

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  late Future<List<Room>> _roomsFuture;
  late Stream<List<Review>> _reviewsStream;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _fetchRooms();
    _reviewsStream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(widget.hotel.id)
        .collection('reviews')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<List<Room>> _fetchRooms() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('hotels')
        .doc(widget.hotel.id)
        .collection('rooms')
        .get();

    return snapshot.docs.map((doc) => Room.fromDocSnapshot(doc)).toList();
  }

  Future<DocumentSnapshot> _getUserSnapshot(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    Widget buildReviewCard(Review review) {
      return FutureBuilder<DocumentSnapshot>(
        future: _getUserSnapshot(review.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError || !userSnapshot.hasData) {
            return const CircleAvatar(child: Icon(Icons.error));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final profilePicUrl = userData['profilephoto'] ?? '';
          final username = userData['username'] ?? 'Anonymous';

          return Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profilePicUrl),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.yellow),
                      Text(
                        '${review.rating}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.deskripsi,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd-MM-yyyy').format(review.tanggal),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    initialPage: 0,
                    autoPlay: true,
                  ),
                  items: widget.hotel.imageUrls.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return const Center(
                                    child: Text('Error loading image'));
                              },
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4.0),
                        child: Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < widget.hotel.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.hotel.address.join(', '),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${widget.hotel.contact}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Facilities:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.hotel.facilities.map((facility) {
                      return Chip(
                        label: Text(facility),
                        backgroundColor: color3,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Review:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Review>>(
                    stream: _reviewsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Not reviewed yet');
                      }
                      List<Review> latestReviews =
                          snapshot.data!.reversed.take(5).toList();

                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: latestReviews.length,
                          itemBuilder: (context, index) {
                            return buildReviewCard(latestReviews[index]);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HotelReview(hotelId: widget.hotel.id)));
                    },
                    child: const Text('See all review'),
                  ),
                  const Text(
                    'Room:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Room>>(
                    future: _roomsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading rooms'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No rooms available'));
                      } else {
                        return Column(
                          children: snapshot.data!.map((room) {
                            return Card(
                              color: color2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      if (room.imageUrl.isNotEmpty)
                                        Image.network(
                                          room.imageUrl,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            }
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return const Center(
                                              child:
                                                  Text('Error loading image'),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    title: Text(
                                      room.type,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Facilities: ${room.facilities.join(', ')}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            room.available
                                                ? 'available'
                                                : 'not available',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: room.available
                                                  ? const Color.fromARGB(
                                                      255, 15, 174, 1)
                                                  : Colors.red,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currencyFormatter
                                              .format(widget.hotel.price),
                                          style: const TextStyle(
                                            color: color1,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookingPage(
                                                  room: room,
                                                  hotel: widget.hotel,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Booking'),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
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
