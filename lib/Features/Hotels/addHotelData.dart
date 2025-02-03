import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';

class AddHotelPage extends StatefulWidget {
  const AddHotelPage({super.key});

  @override
  _AddHotelPageState createState() => _AddHotelPageState();
}

class _AddHotelPageState extends State<AddHotelPage> {
  final _formKey = GlobalKey<FormState>();

  // Hotel Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController(); // Controller for single image URL
  final TextEditingController _imageUrlsController =
      TextEditingController(); // Controller for multiple image URLs
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Address fields
  final List<TextEditingController> _addressControllers = [];

  // List for multiple image URLs
  final List<String> _imageUrls = [];

  // Rooms List
  List<Room> rooms = [];

  // Function to add an image URL to the list
  void _addImageUrl() {
    setState(() {
      if (_imageUrlController.text.isNotEmpty) {
        _imageUrls.add(_imageUrlController.text);
        _imageUrlController.clear();
      }
    });
  }

  void _addRoom() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController typeController = TextEditingController();
        final TextEditingController pricePerNightController =
            TextEditingController();
        final TextEditingController facilitiesController =
            TextEditingController();
        final TextEditingController imageUrlController =
            TextEditingController();

        bool available = true;

        return AlertDialog(
          title: const Text('Tambah Kamar'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Tipe Kamar'),
                ),
                TextFormField(
                  controller: pricePerNightController,
                  decoration:
                      const InputDecoration(labelText: 'Harga per Malam'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: facilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Fasilitas (Pisahkan dengan koma)',
                  ),
                ),
                TextFormField(
                  controller: imageUrlController,
                  decoration:
                      const InputDecoration(labelText: 'URL Gambar Kamar'),
                ),
                CheckboxListTile(
                  title: const Text('Tersedia'),
                  value: available,
                  onChanged: (value) {
                    setState(() {
                      available = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newRoom = Room(
                  id: '',
                  type: typeController.text,
                  pricePerNight: int.parse(pricePerNightController.text),
                  facilities: facilitiesController.text
                      .split(',')
                      .map((facility) => facility.trim())
                      .toList(),
                  available: available,
                  imageUrl: imageUrlController.text,
                );

                setState(() {
                  rooms.add(newRoom);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  // Function to add hotel to Firestore
  Future<void> _addHotel() async {
    if (_formKey.currentState!.validate()) {
      final hotel = Hotel(
        id: '',
        name: _nameController.text,
        imageUrl: _imageUrlController.text, // Single image URL
        imageUrls: _imageUrls, // List of image URLs
        price: int.parse(_priceController.text),
        address:
            _addressControllers.map((controller) => controller.text).toList(),
        contact: _contactController.text,
        rating: int.parse(_ratingController.text),
        facilities: _facilitiesController.text
            .split(',')
            .map((facility) => facility.trim())
            .toList(),
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      );

      try {
        DocumentReference hotelRef = await FirebaseFirestore.instance
            .collection('hotels')
            .add(hotel.toMap());

        for (var room in rooms) {
          await hotelRef.collection('rooms').add(room.toMap());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data hotel berhasil ditambahkan!')),
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          rooms.clear();
          _imageUrls.clear(); // Clear the image URLs list
          _addressControllers.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan data: $e')),
        );
      }
    }
  }

  // Function to add address field
  void _addAddressField() {
    setState(() {
      _addressControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Hotel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Hotel'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama hotel tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                      labelText: 'URL Gambar Hotel (satu gambar)'),
                ),
                ElevatedButton(
                  onPressed: _addImageUrl,
                  child: const Text('Tambah Gambar'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _imageUrls.map((url) {
                    return Chip(
                      label: Text(url),
                      onDeleted: () {
                        setState(() {
                          _imageUrls.remove(url);
                        });
                      },
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Kontak'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kontak tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rating tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Rating harus berupa angka';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _facilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Fasilitas (Pisahkan dengan koma)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Fasilitas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (Pisahkan dengan koma)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tags tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alamat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._addressControllers.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  );
                }),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addAddressField,
                  child: const Text('Tambah Alamat'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kamar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...rooms.map((room) {
                  return ListTile(
                    title: Text(room.type),
                    subtitle: Text(
                        'Harga: ${room.pricePerNight}, Tersedia: ${room.available ? 'Ya' : 'Tidak'}'),
                  );
                }),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addRoom,
                  child: const Text('Tambah Kamar'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addHotel,
                  child: const Text('Tambah Hotel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose(); // Dispose single image URL controller
    _imageUrlsController.dispose(); // Dispose multiple image URLs controller
    _priceController.dispose();
    _contactController.dispose();
    _ratingController.dispose();
    _facilitiesController.dispose();
    _tagsController.dispose();
    for (var controller in _addressControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
