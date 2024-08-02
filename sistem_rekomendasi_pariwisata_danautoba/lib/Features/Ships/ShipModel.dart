class ShipTicket {
  final String id;

  final String from;
  final String to;
  final List<String> departTime;
  final int price;

  ShipTicket({
    required this.id,
    required this.from,
    required this.to,
    required this.departTime,
    required this.price,
  });

  factory ShipTicket.fromFirestore(Map<String, dynamic> data, String id) {
    List<String> departTimeList =
        (data['departTime'] as List<dynamic>).map((e) => e.toString()).toList();

    return ShipTicket(
      id: id,
      from: data['from'] ?? 'unknown',
      to: data['to'] ?? 'unknown',
      departTime: departTimeList,
      price: data['price'] ?? 0,
    );
  }
}
