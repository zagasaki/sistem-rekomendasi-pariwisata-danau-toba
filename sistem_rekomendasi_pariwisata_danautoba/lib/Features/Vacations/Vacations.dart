import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(-6.2088, 106.8456); // Koordinat Jakarta

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Tempat Wisata'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('monas'),
            position: LatLng(-6.1754, 106.8272),
            infoWindow: InfoWindow(title: 'Monas', snippet: 'Monumen Nasional'),
          ),
          Marker(
            markerId: const MarkerId('tmii'),
            position: const LatLng(-6.3028, 106.8947),
            infoWindow: const InfoWindow(
                title: 'TMII', snippet: 'Taman Mini Indonesia Indah'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
          Marker(
            markerId: const MarkerId('ragunan'),
            position: const LatLng(-6.3086, 106.8279),
            infoWindow: const InfoWindow(
                title: 'Ragunan', snippet: 'Kebun Binatang Ragunan'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          ),
        },
      ),
    );
  }
}
