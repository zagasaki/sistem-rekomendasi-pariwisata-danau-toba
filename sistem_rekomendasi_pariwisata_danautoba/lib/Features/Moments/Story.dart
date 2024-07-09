import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/FullScreenImageView.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class Story extends StatefulWidget {
  const Story({super.key});

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  TextEditingController captionController = TextEditingController();
  List<File> images = [];

  Future<void> uploadStory(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String username = userProvider.username;
    String profilePictureUrl = userProvider.profilephoto ??
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAd5avdba8EiOZH8lmV3XshrXx7dKRZvhx-A&s';
    DateTime now = DateTime.now();
    String caption = captionController.text;

    List<String> imageUrls = [];

    for (File image in images) {
      String fileName = '${now.millisecondsSinceEpoch}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('stories/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.whenComplete(() => null);
      String imageUrl = await storageReference.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    await FirebaseFirestore.instance.collection('stories').add({
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'date': now,
      'caption': caption,
      'images': imageUrls,
    });

    setState(() {
      captionController.clear();
      images.clear();
    });
  }

  Future<void> pickImages(ImageSource source) async {
    if (await _requestPermission(source)) {
      if (source == ImageSource.gallery) {
        final pickedFiles = await ImagePicker().pickMultiImage();
        setState(() {
          images =
              pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
        });
      } else if (source == ImageSource.camera) {
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            images.add(File(pickedFile.path));
          });
        }
      }
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.gallery) {
      permission = Permission.photos;
    } else {
      permission = Permission.camera;
    }
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Story'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userProvider
                                .profilephoto ??
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAd5avdba8EiOZH8lmV3XshrXx7dKRZvhx-A&s'),
                      ),
                      title: TextField(
                        controller: captionController,
                        decoration: const InputDecoration(
                          hintText: 'Apa yang Anda pikirkan?',
                          border: InputBorder.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_photo_alternate),
                            onPressed: () => pickImages(ImageSource.gallery),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () => pickImages(ImageSource.camera),
                          ),
                        ],
                      ),
                    ),
                    if (images.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: images
                            .map((image) =>
                                Image.file(image, width: 100, height: 100))
                            .toList(),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        onPressed: () => uploadStory(context),
                        child: const Text('Share Story'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const StoryList(),
          ],
        ),
      ),
    );
  }
}

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
              margin: const EdgeInsets.all(8.0),
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
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: imageUrls.asMap().entries.map<Widget>((entry) {
                        int index = entry.key;
                        String url = entry.value;
                        if (index < 5) {
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
                            child: Image.network(url, width: 100, height: 100),
                          );
                        } else if (index == 5) {
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(url, width: 100, height: 100),
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.black54,
                                  child: Center(
                                    child: Text(
                                      '+${imageUrls.length - 5}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }).toList(),
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
