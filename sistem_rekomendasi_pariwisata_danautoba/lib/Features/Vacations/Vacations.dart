import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsDetail.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class Vacations extends StatefulWidget {
  const Vacations({super.key});

  @override
  _VacationsState createState() => _VacationsState();
}

class _VacationsState extends State<Vacations> {
  String searchQuery = '';
  String filterCategory = 'All';
  String filterTag = 'All';

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('vacationtags') ?? []);

        Set<String> updatedTagsSet = {...existingTags, ...newTags};
        List<String> updatedTags =
            updatedTagsSet.toList().sublist(0, min(updatedTagsSet.length, 5));

        await userDoc
            .set({'vacationtags': updatedTags}, SetOptions(merge: true));
      } else {
        await userDoc.set({'vacationtags': newTags});
      }

      print('Tags updated successfully.');
    } catch (e) {
      print('Error updating tags: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          hintText: 'Search destination...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilterButton(
                    text: 'All',
                    selected: filterTag == 'All',
                    onTap: () {
                      setState(() {
                        filterTag = 'All';
                      });
                    },
                  ),
                  FilterButton(
                    text: 'Pemandangan Danau',
                    selected: filterTag == 'pemandangandanau',
                    onTap: () {
                      setState(() {
                        filterTag = 'pemandangandanau';
                      });
                    },
                  ),
                  FilterButton(
                    text: 'Air Terjun',
                    selected: filterTag == 'airterjun',
                    onTap: () {
                      setState(() {
                        filterTag = 'airterjun';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: DestinationList(
                  searchQuery: searchQuery,
                  filterTag: filterTag,
                ),
              ),
            ],
          ),
        ),
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

class DestinationList extends StatelessWidget {
  final String searchQuery;
  final String filterTag;

  const DestinationList({
    super.key,
    required this.searchQuery,
    required this.filterTag,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('destinations').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var destinations = snapshot.data!.docs
            .map((doc) => Destination.fromDocSnapshot(
                doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        if (searchQuery.isNotEmpty) {
          destinations = destinations
              .where((d) =>
                  d.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
        }

        if (filterTag != 'All') {
          destinations =
              destinations.where((d) => d.tags.contains(filterTag)).toList();
        }

        return ListView.builder(
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            return DestinationCard(destination: destinations[index]);
          },
        );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('vacationtags') ?? []);

        Set<String> updatedTagsSet = {...existingTags, ...newTags};
        List<String> updatedTags =
            updatedTagsSet.toList().sublist(0, min(updatedTagsSet.length, 5));

        await userDoc
            .set({'vacationtags': updatedTags}, SetOptions(merge: true));
      } else {
        await userDoc.set({'vacationtags': newTags});
      }

      print('Tags updated successfully.');
    } catch (e) {
      print('Error updating tags: $e');
    }
  }

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await updateUserTags(
            context.read<UserProvider>().uid!, destination.tags);
        await Navigator.push(
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
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Image.network(
                    destination.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
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
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
  }
}
