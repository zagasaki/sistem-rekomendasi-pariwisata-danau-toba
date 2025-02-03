import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/addCulinaryData.dart';
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
  }

  Future<void> readData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var data = await db.collection('kuliner').get();
    setState(() {
      kuliner =
          data.docs.map((doc) => KulinerModel.fromDocSnapshot(doc)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fontSizeTitle = screenWidth * 0.03;
    final double fontSizePrice = screenWidth * 0.03;
    final double iconSize = screenWidth * 0.03;
    final double padding = screenWidth * 0.02;
    final double spacing = screenHeight * 0.01;

    return Scaffold(
      // floatingActionButton: ElevatedButton(
      //     onPressed: () {
      //       Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => const AddKulinerPage()));
      //     },
      //     child: const Icon(Icons.add)),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: color1),
        centerTitle: true,
        backgroundColor: color2,
        title: Text(
          'Culinary',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
          ),
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
                    margin: EdgeInsets.all(padding),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        children: [
                          Image.network(
                            item.imageUrl,
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: fontSizeTitle,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: spacing),
                                Text(
                                  currencyFormatter.format(item.price),
                                  style: TextStyle(
                                      fontSize: fontSizePrice,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: spacing),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < item.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: iconSize,
                                    );
                                  }),
                                ),
                                SizedBox(height: spacing),
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
