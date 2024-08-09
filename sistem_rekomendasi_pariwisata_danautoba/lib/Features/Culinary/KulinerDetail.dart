import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'KulinerModel.dart';
import 'KulinerPayment.dart';
import 'kulinerReview.dart';

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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fontSizeTitle = screenWidth * 0.05;
    final double fontSizePrice = screenWidth * 0.05;
    final double iconSize = screenWidth * 0.05;
    final double padding = screenWidth * 0.04;
    final double spacing = screenHeight * 0.02;
    final double reviewCardWidth = screenWidth * 0.85;

    Widget buildReviewCard(Review review) {
      return FutureBuilder<DocumentSnapshot>(
        future: _getUserSnapshot(review.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError || !userSnapshot.hasData) {
            return const Center(child: Icon(Icons.error));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final profilePicUrl = userData['profilephoto'] ?? '';
          final username = userData['username'] ?? 'Anonymous';

          return Container(
            width: reviewCardWidth,
            margin: EdgeInsets.symmetric(horizontal: padding),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                          style: TextStyle(
                              fontSize: fontSizeTitle * 0.9,
                              color: Colors.black,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      Icon(Icons.star, color: Colors.yellow, size: iconSize),
                      Text(
                        '${review.rating}',
                        style: TextStyle(fontSize: fontSizeTitle * 0.8),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 0.5),
                  Text(
                    review.deskripsi,
                    style: TextStyle(
                        fontSize: fontSizeTitle * 0.8, color: Colors.black),
                  ),
                  SizedBox(height: spacing * 0.5),
                  Text(
                    DateFormat('dd-MM-yyyy').format(review.tanggal),
                    style: TextStyle(
                        fontSize: fontSizeTitle * 0.7, color: Colors.black54),
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
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                kuliner.imageUrl,
                width: double.infinity,
                height: screenHeight * 0.25,
                fit: BoxFit.cover,
              ),
              SizedBox(height: spacing),
              Row(
                children: [
                  Text(
                    maxLines: 2,
                    kuliner.name,
                    style: TextStyle(
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < kuliner.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: iconSize,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: spacing * 0.5),
              Text(
                currencyFormatter.format(kuliner.price),
                style: TextStyle(
                    fontSize: fontSizePrice,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: spacing),
              InkWell(
                onTap: _openGoogleMaps,
                child: Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/googlemaps_logo.png",
                          height: iconSize),
                      SizedBox(width: spacing),
                      const Text(
                        "Open on Maps",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Text(
                kuliner.deskripsi,
                style: TextStyle(fontSize: fontSizeTitle * 0.8),
              ),
              SizedBox(height: spacing),
              Text(
                'Recent Review:',
                style: TextStyle(
                    fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: spacing * 0.5),
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
                    height: screenHeight * 0.25,
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
              SizedBox(height: spacing),
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
                child: Text(
                  'See all review',
                  style: TextStyle(fontSize: fontSizeTitle * 0.8),
                ),
              ),
              SizedBox(height: spacing),
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
            padding: EdgeInsets.symmetric(vertical: padding * 0.8),
          ),
          child: Text(
            'Proceed to Payment',
            style:
                TextStyle(fontSize: fontSizeTitle * 0.9, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
