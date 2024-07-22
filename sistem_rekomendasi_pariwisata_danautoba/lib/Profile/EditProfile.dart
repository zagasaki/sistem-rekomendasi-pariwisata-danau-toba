import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  late UserProvider userProvider;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      nameController.text = userProvider.username;
      phoneController.text = userProvider.phone;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadProfilePhoto(File file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  Future<void> _updateProfile(
      String name, String phone, String? photoUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'username': name,
          'phone': phone,
          'profilephoto': photoUrl ?? userProvider.profilephoto,
        });
        userProvider.username = name;
        userProvider.phone = phone;
        userProvider.profilephoto = photoUrl ?? userProvider.profilephoto;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    if (_profileImage != null) {
      final photoUrl = await _uploadProfilePhoto(_profileImage!);
      await _updateProfile(
        nameController.text,
        phoneController.text,
        photoUrl,
      );
    } else {
      await _updateProfile(
        nameController.text,
        phoneController.text,
        userProvider.profilephoto,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : userProvider.profilephoto != null
                            ? NetworkImage(userProvider.profilephoto!)
                                as ImageProvider
                            : null,
                    child: _profileImage == null &&
                            userProvider.profilephoto == null
                        ? const Icon(Icons.person, size: 80)
                        : null,
                  ),
                  Positioned(
                    bottom: -10,
                    right: -5,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 40,
                      ),
                      onPressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera),
                                  title: const Text('Take a Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _takePhoto();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text('Pick from Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveProfile(context),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
