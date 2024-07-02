import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String itemId;
  final String name;
  final String type;
  final String details;
  final String date;
  final int price;

  HistoryItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.type,
    required this.details,
    required this.date,
    required this.price,
  });

  factory HistoryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Missing data for HistoryItem: ${doc.id}');
    }

    return HistoryItem(
      id: doc.id,
      itemId: data['itemId'] ?? 'No ID',
      name: data['name'] ?? 'No Name',
      type: data['type'] ?? 'No Type',
      details: data['details'] ?? 'No Details',
      date: data['date'],
      price: data['totalHarga'] ?? 0,
    );
  }
}
