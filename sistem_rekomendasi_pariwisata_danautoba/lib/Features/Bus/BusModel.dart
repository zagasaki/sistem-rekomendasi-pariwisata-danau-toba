// lib/models/bus_ticket.dart
class BusTicket {
  final String id;
  final String transportName;
  final String from;
  final String to;
  final List<String> departTime;
  final int price;

  BusTicket({
    required this.id,
    required this.transportName,
    required this.from,
    required this.to,
    required this.departTime,
    required this.price,
  });

  factory BusTicket.fromFirestore(Map<String, dynamic> data, String id) {
    // Konversi departTime dari List<dynamic> ke List<String>
    List<String> departTimeList =
        (data['departTime'] as List<dynamic>).map((e) => e.toString()).toList();

    return BusTicket(
      id: id,
      transportName: data['transportName'] ?? 'unknown',
      from: data['from'] ?? 'unknown',
      to: data['to'] ?? 'unknown',
      departTime: departTimeList,
      price: data['price'] ?? 0,
    );
  }
}
