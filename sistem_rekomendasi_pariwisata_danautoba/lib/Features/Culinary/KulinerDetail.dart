import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/kulinerReview.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'KulinerModel.dart'; // Adjust the import path if necessary
import 'KulinerPayment.dart'; // Import the payment page// Ensure ReviewModel is imported

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

  void _showAllReviews(BuildContext context, String kulinerId) {
    Stream<List<Review>> reviewsStream = _reviewsStream(kulinerId);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Semua Ulasan'),
          content: SingleChildScrollView(
            child: StreamBuilder<List<Review>>(
              stream: reviewsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Belum ada ulasan.');
                }
                return Column(
                  children: snapshot.data!.map((review) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      color: color3,
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'By: ${review.username}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
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
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tanggal: ${review.tanggal}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
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
                Navigator.of(dialogContext).pop();
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: color1),
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
              Text(
                kuliner.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${kuliner.price}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow[700],
                  ),
                  Text(
                    '${kuliner.rating}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                kuliner.deskripsi,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Text(
                'Ulasan Terbaru:',
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
                    return const Text('Belum ada ulasan.');
                  }
                  // Ambil 5 ulasan terbaru
                  List<Review> latestReviews =
                      snapshot.data!.reversed.take(5).toList();

                  return SizedBox(
                    height: 200, // Atur tinggi ListView sesuai kebutuhan Anda
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: latestReviews.length,
                      itemBuilder: (context, index) {
                        Review review = latestReviews[index];
                        return Container(
                          width: 300, // Lebar container untuk setiap ulasan
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        review.username,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    const Icon(Icons.star,
                                        color: Colors.yellow),
                                    Text(
                                      '${review.rating}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.deskripsi,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${review.tanggal}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
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
                          builder: (context) => KulinerReview(
                                kulinerId: kuliner.id,
                              )));
                },
                child: const Text('Lihat Semua Ulasan'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KulinerPayment(kuliner: kuliner),
                    ),
                  );
                },
                child: const Text('Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
