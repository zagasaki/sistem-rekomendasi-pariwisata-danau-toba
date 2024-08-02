import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/FullScreenImageView.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  String formatTimestamp(Timestamp timestamp) {
    DateTime now = DateTime.now();
    DateTime date = timestamp.toDate();
    Duration difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours < 48) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Future<void> toggleLike(BuildContext context, DocumentSnapshot story) async {
    final userId = context.read<UserProvider>().uid;
    List likes = List.from(story['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(story.id)
          .update({'likes': likes});
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var stories = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            var story = stories[index];
            List imageUrls = story['images'];
            List likes = story['likes'] ?? [];
            final userId = context.read<UserProvider>().uid;
            bool isLiked = likes.contains(userId);

            final uid = story['uid'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: getUserData(uid),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                String username = userData['username'] ?? 'Unknown';
                String profilePictureUrl = userData['profilephoto'] ?? '';

                return Card(
                  margin: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(profilePictureUrl),
                            child: profilePictureUrl.isEmpty
                                ? const Icon(Icons.person, size: 80)
                                : null,
                          ),
                          title: Text(username),
                          subtitle: Text(formatTimestamp(story['date'])),
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
                            childAspectRatio: 1.0,
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
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () {
                                print(
                                    'Toggling like for story ID: ${story.id}');
                                toggleLike(context, story);
                              },
                            ),
                            Text('${likes.length} likes'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
