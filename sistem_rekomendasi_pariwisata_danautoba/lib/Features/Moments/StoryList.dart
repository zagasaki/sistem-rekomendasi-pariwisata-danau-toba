import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/FullScreenImageView.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('stories').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var stories = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            var story = stories[index];
            List imageUrls = story['images'];
            return Card(
              margin: const EdgeInsets.fromLTRB(8, 3, 8, 3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(story['profilePictureUrl']),
                      ),
                      title: Text(story['username']),
                      subtitle: Text(DateFormat('dd MMM yyyy')
                          .format(story['date'].toDate())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(story['caption']),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio:
                            1.0, // Sesuaikan dengan kebutuhan Anda
                      ),
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        String url = imageUrls[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageView(
                                  imageUrls: imageUrls.cast<String>(),
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Image.network(url, fit: BoxFit.cover),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
