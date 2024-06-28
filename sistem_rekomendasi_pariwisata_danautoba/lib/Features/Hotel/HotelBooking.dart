import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import package intl untuk formatting tanggal
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotel/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart'; // Import model hotel

class BookingPage extends StatefulWidget {
  final Room room;

  const BookingPage({super.key, required this.room});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int _totalHarga;

  @override
  void initState() {
    super.initState();
    // Set default check-in dan check-out date (misalnya check-in hari ini, check-out besok)
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now()
        .add(const Duration(days: 1)); // Tambah 1 hari dari check-in date
    _hitungTotalHarga();
  }

  void _hitungTotalHarga() {
    // Hitung total harga berdasarkan harga per malam dan durasi menginap
    int jumlahHari = _checkOutDate.difference(_checkInDate).inDays;
    _totalHarga = widget.room.pricePerNight * jumlahHari;
  }

  void _ubahCheckInDate(DateTime selectedDate) {
    setState(() {
      _checkInDate = selectedDate;
      // Pastikan check-out date tidak sebelum check-in date
      if (_checkOutDate.isBefore(_checkInDate)) {
        _checkOutDate = _checkInDate
            .add(const Duration(days: 1)); // Tambah 1 hari dari check-in date
      }
      _hitungTotalHarga();
    });
  }

  void _ubahCheckOutDate(DateTime selectedDate) {
    setState(() {
      _checkOutDate = selectedDate;
      _hitungTotalHarga();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Kamar:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // Check if the room image URL is valid
                  if (widget.room.imageUrl.isNotEmpty)
                    Image.network(
                      widget.room.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ListTile(
                    title: Text(widget.room.type),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Harga per malam: Rp ${widget.room.pricePerNight}'),
                        const SizedBox(height: 4),
                        Text('Fasilitas: ${widget.room.facilities.join(', ')}'),
                        const SizedBox(height: 4),
                        Text(
                          'Ketersediaan: ${widget.room.available ? 'Tersedia' : 'Penuh'}',
                          style: TextStyle(
                            color: widget.room.available
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tanggal Check-in:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pilihTanggal(context, _ubahCheckInDate),
              child: Text(DateFormat('dd MMMM yyyy').format(_checkInDate)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tanggal Check-out:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pilihTanggal(context, _ubahCheckOutDate),
              child: Text(DateFormat('dd MMMM yyyy').format(_checkOutDate)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Total Harga:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp $_totalHarga',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _konfirmasiBooking(); // Fungsi untuk melakukan booking
              },
              child: const Text('Konfirmasi Booking'),
            ),
          ],
        ),
      ),
    );
  }

  void _pilihTanggal(
      BuildContext context, Function(DateTime) onDateSelected) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
          const Duration(days: 365)), // Batas maksimal 1 tahun dari hari ini
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  void _konfirmasiBooking() {
    final id = context.read<UserProvider>().uid;
    // Implementasi fungsi untuk melakukan booking
    // Misalnya, tambahkan data booking ke koleksi 'bookings' di Firestore
    FirebaseFirestore.instance.collection('bookings').add({
      'roomId': widget.room.id,
      'roomType': widget.room.type,
      'checkInDate': _checkInDate,
      'checkOutDate': _checkOutDate,
      'totalHarga': _totalHarga,
      'bookDate': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
      'user': id
    }).then((value) {
      // Tambahkan data history ke koleksi 'users' di Firestore
      Map<String, dynamic> historyData = {
        'historyType': "Hotel",
        'roomId': widget.room.id,
        'roomType': widget.room.type,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
        'totalHarga': _totalHarga,
        'bookDate': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
      };

      FirebaseFirestore.instance.collection('users').doc(id).update({
        'history': FieldValue.arrayUnion([historyData])
      }).then((_) {
        // Tampilkan notifikasi atau arahkan pengguna ke halaman konfirmasi
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Berhasil'),
            content: const Text('Terima kasih! Booking Anda telah berhasil.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        );
      }).catchError((error) {
        // Handle error jika gagal update history user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content:
                Text('Terjadi kesalahan saat mengupdate history user: $error'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
    }).catchError((error) {
      // Handle error jika booking gagal
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Terjadi kesalahan saat melakukan booking: $error'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }
}
