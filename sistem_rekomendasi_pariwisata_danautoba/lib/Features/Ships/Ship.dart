import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Ships/ShipDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Ships/ShipModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart'; // Import halaman detail

class ShipTicketOrderPage extends StatefulWidget {
  const ShipTicketOrderPage({super.key});

  @override
  _ShipTicketOrderPageState createState() => _ShipTicketOrderPageState();
}

class _ShipTicketOrderPageState extends State<ShipTicketOrderPage> {
  String? _selectedOrigin;
  String? _selectedDestination;
  List<ShipTicket> _filteredShipTickets = [];

  final List<String> _origins = [
    'Pelabuhan Ajibata',
    'Pelabuhan Simanindo',
    'Pelabuhan Tigaras',
    'Pelabuhan Muara',
    'Pelabuhan Bakti Raja',
    'Pelabuhan Tongging',
  ];
  final List<String> _destinations = [
    'Pelabuhan Ajibata',
    'Pelabuhan Simanindo',
    'Pelabuhan Tigaras',
    'Pelabuhan Muara',
    'Pelabuhan Bakti Raja',
    'Pelabuhan Tongging',
  ];

  Future<List<ShipTicket>> fetchShipTickets() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('ship').get();
      print('Fetched ${snapshot.docs.length} tickets');
      return snapshot.docs
          .map((doc) => ShipTicket.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  void _filterShipTickets() async {
    if (_selectedOrigin != null && _selectedDestination != null) {
      var allTickets = await fetchShipTickets();
      setState(() {
        _filteredShipTickets = allTickets
            .where((ticket) =>
                ticket.from.toLowerCase() == _selectedOrigin!.toLowerCase() &&
                ticket.to.toLowerCase() == _selectedDestination!.toLowerCase())
            .toList();
      });
    }
  }

  List<String> _getAvailableDestinations() {
    return _destinations.where((destination) {
      return _selectedOrigin == null || destination != _selectedOrigin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ship',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Order Your Ship Ticket',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color2),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.03),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Origin',
                  fillColor: color2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                value: _selectedOrigin,
                onChanged: (value) {
                  setState(() {
                    _selectedOrigin = value;
                    _selectedDestination = null;
                    _filterShipTickets();
                  });
                },
                items: _origins
                    .map((origin) => DropdownMenuItem(
                          value: origin,
                          child: Text(origin),
                        ))
                    .toList(),
              ),
              SizedBox(height: screenSize.height * 0.03),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                value: _selectedDestination,
                onChanged: (value) {
                  setState(() {
                    _selectedDestination = value;
                    _filterShipTickets();
                  });
                },
                items: _getAvailableDestinations()
                    .map((destination) => DropdownMenuItem(
                          value: destination,
                          child: Text(destination),
                        ))
                    .toList(),
              ),
              SizedBox(height: screenSize.height * 0.03),
              if (_selectedOrigin != null)
                Container(
                    decoration: const BoxDecoration(
                        color: color2,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: _filteredShipTickets.isEmpty
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No tickets available for the selected route.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                        : Padding(
                            padding: const EdgeInsets.all(15),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredShipTickets.length,
                              itemBuilder: (context, index) {
                                var ticket = _filteredShipTickets[index];
                                return Card(
                                  elevation: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              ticket.from,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Icon(Icons.arrow_right),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 100,
                                            ),
                                            Text(
                                              ticket.to,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Depart Times: ${ticket.departTime.join(', ')}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Rp ${ticket.price}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.green),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShipTicketDetailPage(
                                                    ticket: ticket,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: color2,
                                              textStyle: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                            child: const Text(
                                              'Book Ticket',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )),
              SizedBox(height: screenSize.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
