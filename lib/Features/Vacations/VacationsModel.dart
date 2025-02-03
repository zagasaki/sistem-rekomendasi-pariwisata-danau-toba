import 'package:cloud_firestore/cloud_firestore.dart';

class Destination {
  final String id;
  final String name;
  final String imageUrl;
  final int rating;
  final List<String> tags;
  final String description;
  final String location; // Tambahkan properti tags
  final String gmaps;

  Destination(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.rating,
      required this.tags,
      required this.description,
      required this.location, // Inisialisasi tags
      required this.gmaps});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'tags': tags,
      'description': description,
      'location': location,
      'gmaps': gmaps
    };
  }

  Destination.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        name = doc.data()?['name'] ?? '',
        imageUrl = doc.data()?['imageUrl'] ?? '',
        rating = doc.data()?['rating'] ?? 0,
        tags = List<String>.from(
            doc.data()?['tags'] ?? ['pemandangandanau', 'bukit']),
        description = doc.data()?['description'] ?? 'unknown',
        location = doc.data()?['location'] ?? 'unknown',
        gmaps = doc.data()?['gmaps'] ?? 'unknown';
}
