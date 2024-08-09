import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class HistoryDetail extends StatefulWidget {
  final HistoryItem historyItem;

  const HistoryDetail({super.key, required this.historyItem});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  late Future<bool> _isReviewed;
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _isReviewed = _checkIfReviewed();
    _startCountdown();
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

  void _startCountdown() {
    final now = DateTime.now();
    final deadline = widget.historyItem.paymentDeadline;
    _timeLeft = deadline.difference(now);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = deadline.difference(DateTime.now());
        if (_timeLeft.isNegative) {
          _timer.cancel();
          _handleDeadlinePassed();
        }
      });
    });
  }

  void _handleDeadlinePassed() async {
    if (!widget.historyItem.pay) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(context.read<UserProvider>().uid)
          .collection('history')
          .doc(widget.historyItem.id)
          .delete();

      Fluttertoast.showToast(
        msg: 'Deadline exceeded. Booking has been canceled.',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _submitReview(BuildContext context, HistoryItem historyItem,
      String reviewText, double rating) async {
    final user = context.read<UserProvider>();
    final itemId = historyItem.historyType == 'hotel'
        ? historyItem.hotelID
        : historyItem.historyType == 'kuliner'
            ? historyItem.kulinerID
            : historyItem.ticketID;

    Map<String, dynamic> reviewData = {
      'uid': user.uid,
      'rating': rating,
      'deskripsi': reviewText,
      'tanggal': Timestamp.fromDate(DateTime.now()),
    };

    DocumentReference itemDoc = FirebaseFirestore.instance
        .collection(historyItem.historyType == 'hotel'
            ? 'hotels'
            : historyItem.historyType == 'kuliner'
                ? 'kuliner'
                : 'bus')
        .doc(itemId);

    await itemDoc.collection('reviews').add(reviewData).then((_) async {
      final userid = context.read<UserProvider>().uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .collection('history')
          .doc(historyItem.id)
          .update({'reviewed': true}).then((_) {
        setState(() {
          _isReviewed = Future.value(true);
        });
        Fluttertoast.showToast(
          msg: 'Review berhasil',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: 'Review gagal diupdate',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPendingPayment = !widget.historyItem.pay;
    final showVirtualAccount =
        isPendingPayment && widget.historyItem.virtualAccountNumber.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: color2,
        centerTitle: true,
        title: Text(
          widget.historyItem.historyType == 'hotel'
              ? widget.historyItem.hotelName
              : widget.historyItem.historyType == 'kuliner'
                  ? widget.historyItem.kulinerName
                  : widget.historyItem.historyType == 'Ship'
                      ? widget.historyItem.destination
                      : widget.historyItem.destination,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.03,
          vertical: screenSize.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isPendingPayment
                      ? 'Waiting for Payment'
                      : 'Transaction success!',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: isPendingPayment ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                if (isPendingPayment)
                  Text(
                    'Time Left: ${_formatDuration(_timeLeft)}',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            if (showVirtualAccount)
              _buildDetailRow('Virtual Account Number',
                  widget.historyItem.virtualAccountNumber),
            SizedBox(height: screenSize.height * 0.02),
            const Divider(),
            SizedBox(height: screenSize.height * 0.02),
            _buildDetailRow('Transaction ID', widget.historyItem.id),
            SizedBox(height: screenSize.height * 0.02),
            _buildDetailRow(
                'Order Merchant ID',
                widget.historyItem.historyType == 'hotel'
                    ? widget.historyItem.hotelID
                    : widget.historyItem.historyType == 'kuliner'
                        ? widget.historyItem.kulinerID
                        : widget.historyItem.ticketID),
            SizedBox(height: screenSize.height * 0.02),
            _buildDetailRow('Transaction Date', widget.historyItem.date),
            SizedBox(height: screenSize.height * 0.02),
            const Divider(),
            _buildDetailRow('Payment method', widget.historyItem.paymentMethod),
            SizedBox(height: screenSize.height * 0.02),
            if (widget.historyItem.historyType == 'hotel')
              _buildDetailRow('Nama Hotel', widget.historyItem.hotelName),
            if (widget.historyItem.historyType == 'hotel')
              _buildDetailRow('Room type', widget.historyItem.roomType),
            if (widget.historyItem.historyType == 'kuliner')
              _buildDetailRow('Nama Kuliner', widget.historyItem.kulinerName),
            if (widget.historyItem.historyType == 'bus')
              _buildDetailRow(
                  'Transport Name', widget.historyItem.transportName),
            if (widget.historyItem.historyType == 'bus')
              _buildDetailRow('Departure Date', widget.historyItem.departDate),
            if (widget.historyItem.historyType == 'bus')
              _buildDetailRow('Departure Time', widget.historyItem.departTime),
            if (widget.historyItem.historyType == 'bus')
              _buildDetailRow('Origin', widget.historyItem.origin),
            if (widget.historyItem.historyType == 'bus')
              _buildDetailRow('Destination', widget.historyItem.destination),
            if (widget.historyItem.historyType == 'bus')
              _buildDetailRow('Total Passengers',
                  widget.historyItem.totalpassanger.toString()),
            if (widget.historyItem.historyType == 'Ship')
              _buildDetailRow('Departure Date', widget.historyItem.departDate),
            if (widget.historyItem.historyType == 'Ship')
              _buildDetailRow('Departure Time', widget.historyItem.departTime),
            if (widget.historyItem.historyType == 'Ship')
              _buildDetailRow('Origin', widget.historyItem.origin),
            if (widget.historyItem.historyType == 'Ship')
              _buildDetailRow('Destination', widget.historyItem.destination),
            if (widget.historyItem.historyType == 'Ship')
              _buildDetailRow('Total Passengers',
                  widget.historyItem.totalpassanger.toString()),
            SizedBox(height: screenSize.height * 0.02),
            _buildDetailRow('Price', 'Rp${widget.historyItem.price}'),
          ],
        ),
      ),
      bottomNavigationBar: widget.historyItem.historyType == 'bus' ||
              isPendingPayment ||
              widget.historyItem.historyType == 'Ship'
          ? null
          : Padding(
              padding: EdgeInsets.all(screenSize.width * 0.05),
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
                        backgroundColor: isReviewed ? Colors.grey : color2),
                    child: Text(
                      isReviewed ? "Ulasan Diberikan" : "Berikan Ulasan",
                      style: TextStyle(
                          fontSize: screenSize.width * 0.045, color: color1),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final screenSize = MediaQuery.of(context).size;

    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.04,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: screenSize.width * 0.04),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'Expired';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
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
                'Item: ${historyItem.historyType == 'hotel' ? historyItem.hotelName : historyItem.historyType == 'kuliner' ? historyItem.kulinerName : historyItem.transportName}'),
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
