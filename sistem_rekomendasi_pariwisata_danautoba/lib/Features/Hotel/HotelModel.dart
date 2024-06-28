import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String type;
  final int pricePerNight;
  final List<String> facilities;
  final bool available;
  final String imageUrl;

  Room({
    required this.id,
    required this.type,
    required this.pricePerNight,
    required this.facilities,
    required this.available,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'pricePerNight': pricePerNight,
      'facilities': facilities,
      'available': available,
      'imageUrl': imageUrl,
    };
  }

  Room.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        type = doc.data()?['type'],
        pricePerNight = doc.data()?['pricePerNight'],
        facilities = List<String>.from(doc.data()?['facilities'] ?? []),
        available = doc.data()?['available'],
        imageUrl = doc.data()?['imageUrl'];
}

class Hotel {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> imageUrls;
  final int price;
  final String address;
  final String contact;
  final int rating;
  final List<String> facilities;

  Hotel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imageUrls,
    required this.price,
    required this.address,
    required this.contact,
    required this.rating,
    required this.facilities,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'price': price,
      'address': address,
      'contact': contact,
      'rating': rating,
      'facilities': facilities,
    };
  }

  Hotel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        name = doc.data()?['name'] ?? '',
        imageUrl = doc.data()?['imageUrl'] ?? '',
        imageUrls = List<String>.from(doc.data()?['imageUrls'] ?? []),
        price = doc.data()?['price'] ?? 0,
        address = doc.data()?['address'] ?? '',
        contact = doc.data()?['contact'] ?? '',
        rating = doc.data()?['rating'] ?? 0,
        facilities = List<String>.from(doc.data()?['facilities'] ?? []);
}

class Review {
  final int rating;
  final String comment;

  Review({required this.rating, required this.comment});

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      rating: data['rating'],
      comment: data['comment'],
    );
  }
}
