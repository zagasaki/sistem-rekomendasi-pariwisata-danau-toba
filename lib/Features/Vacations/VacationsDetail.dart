import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Vacations/VacationsModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DestinationDetailPage extends StatefulWidget {
  final Destination destination;

  const DestinationDetailPage({super.key, required this.destination});

  @override
  _DestinationDetailPageState createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  void _openGoogleMaps() async {
    final url = widget.destination.gmaps;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 250.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.destination.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80.0),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(widget.destination.description),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              iconSize: 30,
              color: Colors.white70.withOpacity(1),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: color2,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.destination.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: color1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 0, 208, 255),
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          widget.destination.location,
                          maxLines: null,
                          style: const TextStyle(color: color1),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InkWell(
                      onTap: () {
                        _openGoogleMaps();
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: color1,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Row(
                          children: [
                            Image(
                              image: AssetImage("assets/googlemaps_logo.png"),
                              height: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Open on Maps")
                          ],
                        ),
                      )),
                  const SizedBox(height: 8.0),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.destination.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.yellow,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
