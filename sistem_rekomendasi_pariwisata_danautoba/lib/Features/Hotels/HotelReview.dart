import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';

class HotelReview extends StatefulWidget {
  final String hotelId;

  const HotelReview({super.key, required this.hotelId});

  @override
  State<HotelReview> createState() => _HotelReviewState();
}

class _HotelReviewState extends State<HotelReview> {
  String? _selectedFilter;

  Stream<List<Review>> _reviewsStream(String filter) {
    Query query = FirebaseFirestore.instance
        .collection('hotels')
        .doc(widget.hotelId)
        .collection('reviews');

    if (filter == 'Terbaru') {
      query = query.orderBy('tanggal', descending: true);
    } else {
      // Filter berdasarkan rating
      int rating = int.parse(filter);
      query = query.where('rating', isEqualTo: rating);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Ulasan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Terbaru',
                  child: Text('Terbaru'),
                ),
                const PopupMenuItem(
                  value: '1',
                  child: Text('Rating 1'),
                ),
                const PopupMenuItem(
                  value: '2',
                  child: Text('Rating 2'),
                ),
                const PopupMenuItem(
                  value: '3',
                  child: Text('Rating 3'),
                ),
                const PopupMenuItem(
                  value: '4',
                  child: Text('Rating 4'),
                ),
                const PopupMenuItem(
                  value: '5',
                  child: Text('Rating 5'),
                ),
              ];
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<List<Review>>(
        stream: _reviewsStream(_selectedFilter ?? 'Terbaru'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada ulasan.'));
          }
          return ListView(
            children: snapshot.data!.map((review) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  title: Row(
                    children: [
                      Text(
                        review.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.yellow),
                      Text('${review.rating}'),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.deskripsi,
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd-MM-yyyy').format(review.tanggal),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  tileColor: Colors.grey[200],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
