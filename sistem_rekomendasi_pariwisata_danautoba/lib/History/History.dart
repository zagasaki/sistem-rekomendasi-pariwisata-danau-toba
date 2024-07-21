import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;

    return Scaffold(
      backgroundColor: color1,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color2,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
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

          return ListView(
            children: snapshot.data!.docs.map((document) {
              try {
                HistoryItem historyItem = HistoryItem.fromFirestore(document);
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
      default:
        return 'Unknown';
    }
  }
}
