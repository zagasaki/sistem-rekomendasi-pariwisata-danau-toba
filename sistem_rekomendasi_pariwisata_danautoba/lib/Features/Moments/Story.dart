import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Moments/StoryList.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class Story extends StatefulWidget {
  const Story({super.key});

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  TextEditingController captionController = TextEditingController();
  List<File> images = [];
  bool uploading = false;

  Future<void> uploadStory(BuildContext context) async {
    DateTime now = DateTime.now();
    String caption = captionController.text;
    final user = Provider.of<UserProvider>(context, listen: false);

    if (caption.isEmpty && images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least fill the caption')),
      );
      return;
    }

    List<String> imageUrls = [];
    var uuid = const Uuid();

    try {
      setState(() {
        uploading = true;
      });

      for (File image in images) {
        String fileName = '${uuid.v4()}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child('stories/$fileName');
        UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() => null);
        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance.collection('stories').add({
        'uid': user.uid,
        'date': now,
        'caption': caption,
        'images': imageUrls,
        'likes': [],
      });

      setState(() {
        captionController.clear();
        images.clear();
        uploading = false;
      });
    } catch (e) {
      print('Error uploading story: $e');
      setState(() {
        uploading = false;
      });
    }
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
      permission = Permission.storage;
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
      backgroundColor: color1,
      appBar: AppBar(
        backgroundColor: color2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Share Story',
          style: TextStyle(color: Colors.white),
        ),
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
                      title: Container(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: TextField(
                          controller: captionController,
                          maxLines: null,
                          minLines: 1,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'Tell us your vacation...',
                            border: InputBorder.none,
                          ),
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
                        child: uploading
                            ? const LinearProgressIndicator()
                            : const Text('Share Story'),
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
