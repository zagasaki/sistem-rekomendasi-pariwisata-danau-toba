import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerModel.dart';

class AddKulinerPage extends StatefulWidget {
  const AddKulinerPage({super.key});

  @override
  _AddKulinerPageState createState() => _AddKulinerPageState();
}

class _AddKulinerPageState extends State<AddKulinerPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _gmapsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Function to add kuliner to Firestore
  Future<void> _addKuliner() async {
    if (_formKey.currentState!.validate()) {
      final kuliner = KulinerModel(
        id: '',
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        price: int.parse(_priceController.text),
        rating: int.parse(_ratingController.text),
        deskripsi: _deskripsiController.text,
        gmaps: _gmapsController.text,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      );

      try {
        await FirebaseFirestore.instance.collection('kuliner').add({
          'name': kuliner.name,
          'imageUrl': kuliner.imageUrl,
          'price': kuliner.price,
          'rating': kuliner.rating,
          'deskripsi': kuliner.deskripsi,
          'gmaps': kuliner.gmaps,
          'tags': kuliner.tags,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data kuliner berhasil ditambahkan!')),
        );

        // Reset form
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kuliner'),
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
                  decoration: const InputDecoration(labelText: 'Nama Kuliner'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kuliner tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL Gambar'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL gambar tidak boleh kosong';
                    }
                    return null;
                  },
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
                  controller: _deskripsiController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gmapsController,
                  decoration:
                      const InputDecoration(labelText: 'URL Google Maps'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL Google Maps tidak boleh kosong';
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addKuliner,
                  child: const Text('Tambah Kuliner'),
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
    _imageUrlController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _deskripsiController.dispose();
    _gmapsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
