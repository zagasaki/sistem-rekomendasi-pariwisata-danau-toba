import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerModel.dart';

class KulinerReview extends StatefulWidget {
  final String kulinerId;

  const KulinerReview({super.key, required this.kulinerId});

  @override
  State<KulinerReview> createState() => _KulinerReviewState();
}

class _KulinerReviewState extends State<KulinerReview> {
  String? _selectedFilter;

  Stream<List<Review>> _reviewsStream(String filter) {
    Query query = FirebaseFirestore.instance
        .collection('kuliner')
        .doc(widget.kulinerId)
        .collection('reviews');

    if (filter == 'Terbaru') {
      query = query.orderBy('tanggal', descending: true);
    } else {
      // Filter berdasarkan rating
      int rating = int.parse(filter);
      query = query.where('rating', isEqualTo: rating);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Review.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Stream<Map<String, dynamic>> _userStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
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
              return StreamBuilder<Map<String, dynamic>>(
                stream: _userStream(review.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }
                  if (!userSnapshot.hasData) {
                    return const Text('User not found.');
                  }
                  Map<String, dynamic> userData = userSnapshot.data!;
                  String username = userData['username'] ?? 'Unknown User';
                  String profilephoto = userData['profilephoto'] ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage(profilephoto), // Display profile photo
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
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
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
