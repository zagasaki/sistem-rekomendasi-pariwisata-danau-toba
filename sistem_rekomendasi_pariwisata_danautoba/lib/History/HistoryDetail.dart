import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class HistoryDetail extends StatefulWidget {
  final HistoryItem historyItem;

  const HistoryDetail({super.key, required this.historyItem});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  late Future<bool> _isReviewed;

  @override
  void initState() {
    super.initState();
    _isReviewed = _checkIfReviewed();
  }

  Future<bool> _checkIfReviewed() async {
    final userid = context.read<UserProvider>().uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('history')
        .doc(widget.historyItem.id)
        .get();
    return doc.data()?['reviewed'] ?? false;
  }

  void _submitReview(BuildContext context, HistoryItem historyItem,
      String reviewText, double rating) async {
    final username = context.read<UserProvider>().username;
    final itemId = historyItem.historyType == 'hotel'
        ? historyItem.hotelID
        : historyItem.kulinerID;

    Map<String, dynamic> reviewData = {
      'username': username,
      'rating': rating,
      'deskripsi': reviewText,
      'tanggal': Timestamp.fromDate(DateTime.now()),
    };

    DocumentReference itemDoc = FirebaseFirestore.instance
        .collection(historyItem.historyType == 'hotel' ? 'hotels' : 'kuliner')
        .doc(itemId);

    await itemDoc.collection('reviews').add(reviewData).then((_) async {
      final userid = context.read<UserProvider>().uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .collection('history')
          .doc(historyItem.id)
          .update({'reviewed': true}).then((_) {
        Fluttertoast.showToast(
          msg: 'Review berhasil',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        setState(() {
          _isReviewed = Future.value(true);
        });
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: 'Review gagal diupdate',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Review gagal, coba lagi',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.historyItem.historyType == 'hotel'
            ? widget.historyItem.hotelName
            : widget.historyItem.kulinerName),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${widget.historyItem.historyType}',
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Date: ${widget.historyItem.date}',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Price: Rp ${widget.historyItem.price}',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Payment Method: ${widget.historyItem.paymentMethod}',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (widget.historyItem.historyType == 'hotel') ...[
              Text(
                'Hotel Name: ${widget.historyItem.hotelName}',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Room Type: ${widget.historyItem.roomType}',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
            ] else ...[
              Text(
                'Kuliner Name: ${widget.historyItem.kulinerName}',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Address: ${widget.historyItem.address}',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Notes: ${widget.historyItem.notes}',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: FutureBuilder<bool>(
          future: _isReviewed,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            final isReviewed = snapshot.data ?? false;
            return ElevatedButton(
              onPressed: isReviewed
                  ? null
                  : () {
                      _navigateToReviewPage(context, widget.historyItem);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isReviewed ? Colors.grey : Colors.blue,
              ),
              child: Text(
                isReviewed ? "Ulasan Diberikan" : "Berikan Ulasan",
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
            );
          },
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
            Text(
                'Item: ${historyItem.historyType == 'hotel' ? historyItem.hotelName : historyItem.kulinerName}'),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
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
}