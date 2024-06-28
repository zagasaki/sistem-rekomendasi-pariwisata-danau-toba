import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotel/HotelBooking.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotel/HotelModel.dart';

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

  void _showAllReviews(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Semua Ulasan'),
          content: SingleChildScrollView(
            child: StreamBuilder<List<Review>>(
              stream: _reviewsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Belum ada ulasan.');
                }
                return Column(
                  children: snapshot.data!.map((review) {
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.comment,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow),
                          Text(
                            '${review.rating}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                icon: const Icon(Icons.arrow_back),
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
                  const SizedBox(height: 8),
                  Text(widget.hotel.address),
                  const SizedBox(height: 8),
                  Text('Email: ${widget.hotel.contact}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Rating: ',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Icon(Icons.star, color: Colors.yellow),
                      Text(
                        '${widget.hotel.rating}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fasilitas:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.hotel.facilities.map((facility) {
                      return Chip(
                        label: Text(facility),
                        backgroundColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ulasan Terbaru:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Review>>(
                    stream: _reviewsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Belum ada ulasan.');
                      }
                      return Column(
                        children: snapshot.data!.map((review) {
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    review.comment,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.yellow),
                                Text(
                                  '${review.rating}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _showAllReviews(context);
                    },
                    child: const Text('Lihat Semua Ulasan'),
                  ),
                  const Text(
                    'Kamar:',
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
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      // Check if the room image URL is valid
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
                                    title: Text(room.type),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Fasilitas: ${room.facilities.join(', ')}'),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ketersediaan: ${room.available ? 'Tersedia' : 'Penuh'}',
                                          style: TextStyle(
                                            color: room.available
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
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
                                          'Rp ${room.pricePerNight}',
                                          style: const TextStyle(
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
