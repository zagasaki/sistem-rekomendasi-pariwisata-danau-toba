import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'KulinerModel.dart';
import 'KulinerPayment.dart';
import 'kulinerReview.dart'; // Adjust the import path if necessary

class KulinerDetail extends StatelessWidget {
  final KulinerModel kuliner;

  const KulinerDetail({super.key, required this.kuliner});

  Stream<List<Review>> _reviewsStream(String kulinerId) {
    return FirebaseFirestore.instance
        .collection('kuliner')
        .doc(kulinerId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<DocumentSnapshot> _getUserSnapshot(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  void _openGoogleMaps() async {
    final url = kuliner.gmaps;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: color2,
        title: Text(
          kuliner.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                kuliner.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    kuliner.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < kuliner.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(kuliner.price),
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _openGoogleMaps,
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      Image.asset("assets/googlemaps_logo.png", height: 20),
                      const SizedBox(width: 7),
                      const Text(
                        "Open on Maps",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                kuliner.deskripsi,
                style: const TextStyle(fontSize: 16),
              ),
              const Text(
                'Recent Review:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Review>>(
                stream: _reviewsStream(kuliner.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No review.');
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          KulinerReview(kulinerId: kuliner.id),
                    ),
                  );
                },
                child: const Text('See all review'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: color2),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KulinerPayment(kuliner: kuliner),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color2,
          ),
          child: const Text(
            'Proceed to Payment',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
