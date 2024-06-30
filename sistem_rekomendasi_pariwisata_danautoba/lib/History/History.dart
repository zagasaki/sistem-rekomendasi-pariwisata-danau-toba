import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('history')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No History Data Available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              try {
                HistoryItem historyItem = HistoryItem.fromFirestore(document);
                return CustomCard(historyItem: historyItem);
              } catch (e) {
                return ListTile(
                  title: Text('Error loading item: ${document.id}'),
                  subtitle: Text('$e'),
                );
              }
            }).toList(),
          );
        },
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final HistoryItem historyItem;

  const CustomCard({super.key, required this.historyItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            historyItem.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            historyItem.details,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${historyItem.price}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
              Text(
                historyItem.date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _navigateToReviewPage(context, historyItem);
                },
                child: const Text('Beri Ulasan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToReviewPage(BuildContext context, HistoryItem historyItem) {
    TextEditingController reviewController = TextEditingController();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri Ulasan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${historyItem.name}'),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (ratingValue) {
                rating = ratingValue;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reviewController,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Masukkan ulasan Anda...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              String reviewText = reviewController.text.trim();
              if (reviewText.isNotEmpty && rating > 0) {
                _submitReview(context, historyItem, reviewText, rating);
                Navigator.of(context).pop();
              } else {
                // Tampilkan pesan error jika ulasan kosong atau rating belum diberikan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Masukkan ulasan dan rating Anda terlebih dahulu.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Simpan Ulasan'),
          ),
        ],
      ),
    );
  }

  void _submitReview(BuildContext context, HistoryItem historyItem,
      String reviewText, double rating) {
    final username = context.read<UserProvider>().username;
    final hotelId =
        historyItem.itemId; // Sesuaikan dengan ID hotel dari historyItem

    // Data ulasan yang akan dikirim ke koleksi 'reviews' di hotel
    Map<String, dynamic> reviewData = {
      'username': username,
      'rating': rating,
      'deskripsi': reviewText,
      'tanggal': Timestamp.fromDate(DateTime.now()),
    };

    // Referensi ke dokumen hotel
    DocumentReference hotelDoc =
        FirebaseFirestore.instance.collection('hotels').doc(hotelId);

    // Tambah ulasan ke sub-koleksi 'reviews' dalam dokumen hotel
    hotelDoc.collection('reviews').add(reviewData).then((_) {
      Fluttertoast.showToast(
        msg: 'Review berhasil',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }).catchError((error) {
      // Handle error jika gagal menambah ulasan
      Fluttertoast.showToast(
        msg: 'Review gagal,coba lagi',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    });
  }
}
