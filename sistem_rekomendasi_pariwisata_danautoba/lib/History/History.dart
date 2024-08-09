import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _checkAndRemoveExpiredPayments();
  }

  void _checkAndRemoveExpiredPayments() {
    final userId = context.read<UserProvider>().uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('history')
        .where('pay', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final historyItem = HistoryItem.fromFirestore(doc);
        if (historyItem.paymentDeadline.isBefore(DateTime.now())) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('history')
              .doc(doc.id)
              .delete();
          Fluttertoast.showToast(
            msg: 'Deadline exceeded. Booking has been canceled.',
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;

    return Scaffold(
      backgroundColor: color1,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History'),
        backgroundColor: color1,
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('history')
                .where('pay', isEqualTo: false)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container();
              }

              var expiredPayments = snapshot.data!.docs;

              return Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.red.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waiting for Payments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...expiredPayments.map((document) {
                      try {
                        HistoryItem historyItem =
                            HistoryItem.fromFirestore(document);
                        return CustomCard(historyItem: historyItem);
                      } catch (e) {
                        return ListTile(
                          title: Text('Error loading item: ${document.id}'),
                          subtitle: Text('$e'),
                        );
                      }
                    }),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterButton(
                  text: 'All',
                  selected: selectedType == 'All',
                  onTap: () {
                    setState(() {
                      selectedType = 'All';
                    });
                  },
                ),
                FilterButton(
                  text: 'Hotel',
                  selected: selectedType == 'hotel',
                  onTap: () {
                    setState(() {
                      selectedType = 'hotel';
                    });
                  },
                ),
                FilterButton(
                  text: 'Kuliner',
                  selected: selectedType == 'kuliner',
                  onTap: () {
                    setState(() {
                      selectedType = 'kuliner';
                    });
                  },
                ),
                FilterButton(
                  text: 'Bus',
                  selected: selectedType == 'bus',
                  onTap: () {
                    setState(() {
                      selectedType = 'bus';
                    });
                  },
                ),
                FilterButton(
                  text: 'Ship',
                  selected: selectedType == 'Ship',
                  onTap: () {
                    setState(() {
                      selectedType = 'Ship';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('history')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No History Data Available'));
                }

                var historyDocs = snapshot.data!.docs;

                if (selectedType != 'All') {
                  historyDocs = historyDocs
                      .where((doc) =>
                          HistoryItem.fromFirestore(doc).historyType ==
                          selectedType)
                      .toList();
                }

                if (historyDocs.isEmpty) {
                  return const Center(child: Text('No History Data Available'));
                }

                return ListView(
                  children: historyDocs.map((document) {
                    try {
                      HistoryItem historyItem =
                          HistoryItem.fromFirestore(document);
                      return CustomCard(historyItem: historyItem);
                    } catch (e) {
                      return ListTile(
                        title: Text('Error loading item: ${document.id}'),
                        subtitle: Text('$e'),
                      );
                    }
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color2 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final HistoryItem historyItem;

  const CustomCard({super.key, required this.historyItem});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetail(historyItem: historyItem),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.025,
          vertical: screenSize.height * 0.01,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color2,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            leading: Icon(
              _getIcon(historyItem.historyType),
              color: Colors.white,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            title: Text(
              _getTitle(historyItem),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _getSubtitle(historyItem),
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${historyItem.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
                Text(
                  historyItem.date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String historyType) {
    switch (historyType) {
      case 'hotel':
        return Icons.hotel;
      case 'kuliner':
        return Icons.restaurant;
      case 'bus':
        return Icons.directions_bus;
      case 'Ship':
        return Icons.directions_boat;
      default:
        return Icons.help_outline;
    }
  }

  String _getTitle(HistoryItem historyItem) {
    switch (historyItem.historyType) {
      case 'hotel':
        return historyItem.hotelName;
      case 'kuliner':
        return historyItem.kulinerName;
      case 'bus':
        return historyItem.transportName;
      case 'Ship':
        return historyItem.destination;
      default:
        return 'Unknown';
    }
  }

  String _getSubtitle(HistoryItem historyItem) {
    switch (historyItem.historyType) {
      case 'hotel':
        return historyItem.roomType;
      case 'kuliner':
        return 'notes: ${historyItem.notes}';
      case 'bus':
        return 'Departure: ${historyItem.departTime} ${historyItem.departDate}\nFrom: ${historyItem.origin} To: ${historyItem.destination}';
      case 'Ship':
        return 'Departure: ${historyItem.departTime} ${historyItem.departDate}\nFrom: ${historyItem.origin} To: ${historyItem.destination}';
      default:
        return 'Unknown';
    }
  }
}
