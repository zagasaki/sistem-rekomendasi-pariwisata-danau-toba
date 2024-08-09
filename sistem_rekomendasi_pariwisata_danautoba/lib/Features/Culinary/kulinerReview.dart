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
    final screenWidth = MediaQuery.of(context).size.width;

    final fontSizeSubTitle = screenWidth * 0.04;
    final padding = screenWidth * 0.04;
    final margin = screenWidth * 0.04;
    final iconSize = screenWidth * 0.05;
    final avatarRadius = screenWidth * 0.08;

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
                    margin: EdgeInsets.symmetric(
                        vertical: margin / 2, horizontal: margin),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: padding / 2, horizontal: padding),
                      leading: CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage:
                            NetworkImage(profilephoto), // Display profile photo
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeSubTitle),
                            ),
                          ),
                          Icon(Icons.star,
                              color: Colors.yellow, size: iconSize),
                          Text(
                            '${review.rating}',
                            style: TextStyle(fontSize: fontSizeSubTitle),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.deskripsi,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: fontSizeSubTitle * 0.8),
                          ),
                          SizedBox(height: padding / 4),
                          Text(
                            DateFormat('dd-MM-yyyy').format(review.tanggal),
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: fontSizeSubTitle * 0.7),
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
