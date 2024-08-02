import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class CulinaryRecommendationPage extends StatefulWidget {
  final String userId;

  const CulinaryRecommendationPage({super.key, required this.userId});

  @override
  _CulinaryRecommendationPageState createState() =>
      _CulinaryRecommendationPageState();
}

class _CulinaryRecommendationPageState
    extends State<CulinaryRecommendationPage> {
  List<KulinerModel> recommendedCulinaries = [];
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchCulinaries();
  }

  Future<List<KulinerModel>> fetchRecommendedCulinary(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getCulinaryTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('kuliner')
        .where('tags', arrayContainsAny: userTags)
        .get();

    List<KulinerModel> recommendedCulinary = [];
    for (var doc in snapshot.docs) {
      recommendedCulinary.add(KulinerModel.fromDocSnapshot(doc));
    }
    return recommendedCulinary;
  }

  Future<List<String>> getCulinaryTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('culinarytags') ?? []);
      return userTags;
    } else {
      return [];
    }
  }

  Future<void> fetchCulinaries() async {
    setState(() {
      isFetching = true;
    });

    try {
      List<KulinerModel> culinaires =
          await fetchRecommendedCulinary(widget.userId);
      setState(() {
        recommendedCulinaries = culinaires;
      });
    } catch (e) {
      print('Error fetching culinaires: $e');
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: color2,
        title: const Text(
          'Culinary Recomendation',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isFetching
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: recommendedCulinaries.length,
                itemBuilder: (context, index) {
                  final culinary = recommendedCulinaries[index];
                  return GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              KulinerDetail(kuliner: culinary),
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
                              culinary.imageUrl,
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
                                    culinary.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    currencyFormatter.format(culinary.price),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < culinary.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
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
      ),
    );
  }
}
