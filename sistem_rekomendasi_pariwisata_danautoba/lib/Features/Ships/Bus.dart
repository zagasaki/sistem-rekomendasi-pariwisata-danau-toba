import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Bus/BusDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Bus/BusModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart'; // Import halaman detail

class BusTicketOrderPage extends StatefulWidget {
  const BusTicketOrderPage({super.key});

  @override
  _BusTicketOrderPageState createState() => _BusTicketOrderPageState();
}

class _BusTicketOrderPageState extends State<BusTicketOrderPage> {
  String? _selectedOrigin;
  String? _selectedDestination;
  List<BusTicket> _filteredBusTickets = [];

  final List<String> _origins = [
    'Medan',
    'Pematang Siantar',
    'Parapat',
    'Danau Toba',
    'Berastagi',
    'Samosir',
  ];
  final List<String> _destinations = [
    'Medan',
    'Pematang Siantar',
    'Parapat',
    'Danau Toba',
    'Berastagi',
    'Samosir'
  ];

  Future<List<BusTicket>> fetchBusTickets() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('buses').get();
      print('Fetched ${snapshot.docs.length} tickets');
      return snapshot.docs
          .map((doc) => BusTicket.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  void _filterBusTickets() async {
    if (_selectedOrigin != null && _selectedDestination != null) {
      var allTickets = await fetchBusTickets();
      setState(() {
        _filteredBusTickets = allTickets
            .where((ticket) =>
                ticket.from.toLowerCase() == _selectedOrigin!.toLowerCase() &&
                ticket.to.toLowerCase() == _selectedDestination!.toLowerCase())
            .toList();
      });
    }
  }

  List<String> _getAvailableDestinations() {
    // Filter destinations based on selected origin
    return _destinations.where((destination) {
      return _selectedOrigin == null || destination != _selectedOrigin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bus',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Order Your Bus Ticket',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                    _filterBusTickets();
                  });
                },
                items: _origins
                    .map((origin) => DropdownMenuItem(
                          value: origin,
                          child: Text(origin),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
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
                    _filterBusTickets();
                  });
                },
                items: _getAvailableDestinations()
                    .map((destination) => DropdownMenuItem(
                          value: destination,
                          child: Text(destination),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              if (_selectedOrigin != null)
                Container(
                    decoration: const BoxDecoration(
                        color: color2,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: _filteredBusTickets.isEmpty
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
                              itemCount: _filteredBusTickets.length,
                              itemBuilder: (context, index) {
                                var ticket = _filteredBusTickets[index];
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
                                        Text(
                                          ticket.transportName,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ticket.from,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Icon(Icons.arrow_right),
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
                                          margin:
                                              const EdgeInsets.only(left: 180),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BusTicketDetailPage(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
