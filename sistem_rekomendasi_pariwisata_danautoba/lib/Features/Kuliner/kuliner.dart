import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuliner'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: kuliner.length,
              itemBuilder: (context, index) {
                final item = kuliner[index];
                return Card(
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
                              Text('Price: Rp ${item.price}'),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow[700],
                                  ),
                                  Text('${item.rating}'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          KulinerDetail(kuliner: item),
                                    ),
                                  );
                                },
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
