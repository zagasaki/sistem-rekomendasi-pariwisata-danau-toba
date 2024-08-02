import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'KulinerModel.dart';
import 'KulinerDetail.dart';

class KulinerWidget extends StatefulWidget {
  const KulinerWidget({super.key});

  @override
  State<KulinerWidget> createState() => _KulinerWidgetState();
}

class _KulinerWidgetState extends State<KulinerWidget> {
  List<KulinerModel> kuliner = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('culinarytags') ?? []);

        for (String tag in newTags) {
          if (!existingTags.contains(tag)) {
            if (existingTags.length >= 5) {
              existingTags.removeAt(0);
            }
            existingTags.add(tag);
          }
        }

        await userDoc
            .set({'culinarytags': existingTags}, SetOptions(merge: true));
      } else {
        List<String> uniqueNewTags = newTags.toSet().toList();
        List<String> initialTags = uniqueNewTags.length > 5
            ? uniqueNewTags.sublist(0, 5)
            : uniqueNewTags;
        await userDoc.set({'culinarytags': initialTags});
      }

      print('Tags updated successfully.');
    } catch (e) {
      print('Error updating tags: $e');
    }
  }

  Future<void> readData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var data = await db.collection('kuliner').get();
    setState(() {
      kuliner =
          data.docs.map((doc) => KulinerModel.fromDocSnapshot(doc)).toList();
      isLoading = false;
    });
    print("ini adalah data$data");
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: color1),
        centerTitle: true,
        backgroundColor: color2,
        title: const Text(
          'Culinary',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: kuliner.length,
              itemBuilder: (context, index) {
                final item = kuliner[index];
                return InkWell(
                  onTap: () {
                    updateUserTags(userId!, item.tags);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KulinerDetail(kuliner: item),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Image.network(
                            item.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  currencyFormatter.format(item.price),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < item.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
