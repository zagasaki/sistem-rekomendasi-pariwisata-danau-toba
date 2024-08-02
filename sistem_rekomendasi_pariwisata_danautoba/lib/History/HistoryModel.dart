import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String historyType;
  final String date;
  final String paymentMethod;
  final int price;
  final String username;
  final bool reviewed;
  final String virtualAccountNumber;
  final bool pay;
  final DateTime paymentDeadline;

  //HotelHistoryModel
  final String hotelID;
  final String hotelName;
  final String roomType;

  //KulinerHistoryModel
  final String kulinerID;
  final String kulinerName;
  final String address;
  final String notes;

  //BusHistoryModel
  final String ticketID;
  final String departTime;
  final String departDate;
  final String destination;
  final String origin;
  final int totalpassanger;
  final String transportName;

  HistoryItem({
    required this.id,
    required this.historyType,
    required this.date,
    required this.paymentMethod,
    required this.price,
    required this.username,
    required this.reviewed,
    required this.virtualAccountNumber,
    required this.pay,
    required this.paymentDeadline,

    //HotelHistoryModel
    required this.hotelID,
    required this.hotelName,
    required this.roomType,

    //KulinerHistoryModel
    required this.kulinerID,
    required this.kulinerName,
    required this.address,
    required this.notes,

    //Bus&ShipHistoryModel
    required this.ticketID,
    required this.transportName,
    required this.departDate,
    required this.departTime,
    required this.destination,
    required this.origin,
    required this.totalpassanger,
  });

  factory HistoryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Missing data for HistoryItem: ${doc.id}');
    }

    DateTime paymentDeadline;
    if (data['paymentDeadline'] is Timestamp) {
      paymentDeadline = (data['paymentDeadline'] as Timestamp).toDate();
    } else {
      paymentDeadline = DateTime.now();
    }

    return HistoryItem(
        id: doc.id,
        historyType: data['historyType'] ?? 'unknown history type',
        date: data['date'] ?? 'unknown history date',
        paymentMethod: data['paymentMethod'] ?? 'unknown payment method',
        price: data['price'] ?? 0,
        username: data['username'] ?? 'unknown username',
        reviewed: data['reviewed'] ?? false,
        virtualAccountNumber: data['virtualAccountNumber'] ?? '',
        pay: data['pay'] ?? false,
        paymentDeadline: paymentDeadline,

        //HotelHistoryModel
        hotelID: data['hotelID'] ?? 'unknown hotel id',
        hotelName: data['hotelName'] ?? 'unknown hotel name',
        roomType: data['roomType'] ?? 'unknown room type',

        //KulinerHistoryModel
        kulinerID: data['kulinerID'] ?? 'unknown kuliner id',
        kulinerName: data['kulinerName'] ?? 'unknown kuliner name',
        address: data['address'] ?? 'unknown address',
        notes: data['notes'] ?? 'unknown notes',

        //Bus&ShipHistoryModel
        ticketID: data['ticketID'] ?? 'uknown ticketID',
        departTime: data['departTime'] ?? 'unknown departTime',
        departDate: data['departDate'] ?? 'unknown departDate',
        destination: data['destination'] ?? 'unknown destination',
        origin: data['origin'] ?? 'unknown origin',
        totalpassanger: data['totalPassanger'] ?? 0,
        transportName: data['transportName'] ?? 'unknown transportName');
  }
}
