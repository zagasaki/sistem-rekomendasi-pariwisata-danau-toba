import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class DestinationRecommendationPage extends StatefulWidget {
  final String userId;

  const DestinationRecommendationPage({super.key, required this.userId});

  @override
  _DestinationRecommendationPageState createState() =>
      _DestinationRecommendationPageState();
}

class _DestinationRecommendationPageState
    extends State<DestinationRecommendationPage> {
  List<Destination> recommendedDestinations = [];
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  Future<List<Destination>> fetchRecommendedDestination(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getDestinationTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('destinations')
        .where('tags', arrayContainsAny: userTags)
        .get();

    List<Destination> recommendedDestination = [];
    for (var doc in snapshot.docs) {
      recommendedDestination.add(Destination.fromDocSnapshot(doc));
    }
    return recommendedDestination;
  }

  Future<List<String>> getDestinationTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('vacationtags') ?? []);
      return userTags;
    } else {
      return [];
    }
  }

  Future<void> fetchDestinations() async {
    setState(() {
      isFetching = true;
    });

    try {
      List<Destination> destinations =
          await fetchRecommendedDestination(widget.userId);
      setState(() {
        recommendedDestinations = destinations;
      });
    } catch (e) {
      print('Error fetching destinations: $e');
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: color2,
        title: const Text(
          'Rekomendasi Destinasi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isFetching
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: recommendedDestinations.length,
                itemBuilder: (context, index) {
                  final destination = recommendedDestinations[index];
                  return GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DestinationDetailPage(destination: destination),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  destination.imageUrl,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: double.infinity,
                                      height: 250,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 250,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          destination.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < destination.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.yellow,
                                            );
                                          }),
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
