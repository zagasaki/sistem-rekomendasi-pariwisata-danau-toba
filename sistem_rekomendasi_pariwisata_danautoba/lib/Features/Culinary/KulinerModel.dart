import 'package:cloud_firestore/cloud_firestore.dart';

class KulinerModel {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final int rating;
  final String deskripsi;

  KulinerModel(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.price,
      required this.rating,
      required this.deskripsi});

  factory KulinerModel.fromDocSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return KulinerModel(
        id: doc.id,
        name: data['name'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        price: data['price'] ?? 0,
        rating: data['rating'] ?? 0,
        deskripsi: data['deskripsi'] ?? 'no desc');
  }
}

class Review {
  final double rating;
  final String deskripsi;
  final DateTime tanggal;
  final String username;

  Review({
    required this.rating,
    required this.deskripsi,
    required this.tanggal,
    required this.username,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      rating: data['rating']?.toDouble() ?? 0.0,
      deskripsi: data['deskripsi'] ?? 'unknown desc',
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      username: data['username'] ?? 'anonymous',
    );
  }
}
