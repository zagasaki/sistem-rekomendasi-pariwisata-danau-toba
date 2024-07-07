import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/History/HistoryModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

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
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('history')
            .orderBy('date',
                descending: true) // Mengurutkan berdasarkan tanggal paling baru
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
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            leading: Icon(
              historyItem.historyType == 'hotel'
                  ? Icons.hotel
                  : Icons.restaurant,
              color: Colors.white,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
              historyItem.historyType == 'hotel'
                  ? historyItem.hotelName
                  : historyItem.kulinerName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              historyItem.historyType == 'hotel'
                  ? historyItem.roomType
                  : 'notes: ${historyItem.notes}',
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
                  historyItem.date.toString(),
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
}
