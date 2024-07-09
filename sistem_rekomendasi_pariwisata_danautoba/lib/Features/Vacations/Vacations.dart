import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vacations extends StatefulWidget {
  const Vacations({super.key});

  @override
  State<Vacations> createState() => _VacationsState();
}

class _VacationsState extends State<Vacations> {
  late GoogleMapController mapController;
  final LatLng _center =
      const LatLng(37.7749, -122.4194); // Pusat peta (San Francisco)
  final Set<Marker> _markers = {}; // Set marker untuk menyimpan titik lokasi

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Tambahkan marker di sini sesuai lokasi wisata
    _addMarkers();
  }

  void _addMarkers() {
    // Contoh: Menambahkan marker untuk lokasi wisata
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('1'),
          position: const LatLng(37.7749, -122.4194),
          infoWindow: const InfoWindow(
            title: 'Golden Gate Bridge',
            snippet: 'Iconic bridge in San Francisco',
          ),
          onTap: () {
            // Ketika marker diklik, tampilkan deskripsi atau action lainnya
            // Misalnya, tampilkan dialog dengan deskripsi
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Golden Gate Bridge'),
                content: const Text('Iconic bridge in San Francisco'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacations Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 10.0,
        ),
      ),
    );
  }
}
