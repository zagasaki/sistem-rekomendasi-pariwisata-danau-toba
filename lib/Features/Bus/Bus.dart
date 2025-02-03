// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
    'Silangit Airport',
    'Berastagi',
    'Samosir',
  ];
  final List<String> _destinations = [
    'Medan',
    'Pematang Siantar',
    'Parapat',
    'Silangit Airport',
    'Berastagi',
    'Samosir'
  ];

  Future<List<BusTicket>> fetchBusTickets() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('buses').get();
      return snapshot.docs
          .map((doc) => BusTicket.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
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
    return _destinations.where((destination) {
      return _selectedOrigin == null || destination != _selectedOrigin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Bus',
          style: TextStyle(
              color: Colors.white, fontSize: size.width * mediumfontsize),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Order Your Bus Ticket',
                style: TextStyle(
                  fontSize: size.width * mediumfontsize,
                  fontWeight: FontWeight.bold,
                  color: color2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.width * 0.08),
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
              SizedBox(height: size.width * 0.02),
              Icon(
                Icons.arrow_downward_outlined,
                size: size.width * iconsize,
                color: Colors.grey,
              ),
              SizedBox(height: size.width * 0.02),
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
              SizedBox(height: size.height * 0.02),
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
                            padding: EdgeInsets.all(size.height * 0.01),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredBusTickets.length,
                              itemBuilder: (context, index) {
                                var ticket = _filteredBusTickets[index];
                                return Card(
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      vertical: size.height * 0.01),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(size.height * 0.02),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ticket.transportName,
                                          style: TextStyle(
                                              fontSize:
                                                  size.width * normalfontsize,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ticket.from,
                                              style: TextStyle(
                                                  fontSize: size.width *
                                                      normalfontsize,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Icon(Icons.arrow_right),
                                            Text(
                                              ticket.to,
                                              style: TextStyle(
                                                  fontSize: size.width *
                                                      normalfontsize,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.02),
                                        Text(
                                          'Depart Times: ${ticket.departTime.join(', ')}',
                                          style: TextStyle(
                                              fontSize:
                                                  size.width * smallfontsize),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        Text(
                                          currencyFormatter
                                              .format(ticket.price),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.green),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        Container(
                                          alignment: Alignment.centerRight,
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
                                              textStyle: TextStyle(
                                                  fontSize: size.width *
                                                      smallfontsize,
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
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
