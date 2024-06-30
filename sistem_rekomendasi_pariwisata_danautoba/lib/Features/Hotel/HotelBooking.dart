import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotel/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class BookingPage extends StatefulWidget {
  final Room room;
  final Hotel hotel;

  const BookingPage({super.key, required this.room, required this.hotel});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int price;
  String _selectedPaymentMethod = 'Transfer Bank'; // Default payment method
  String _selectedBank = 'BCA'; // Default bank for Transfer Bank option
  String _creditCardNumber = '';
  String _selectedEwallet = "OVO"; // Variable to store credit card number

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 1));
    _calculateTotalPrice();
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDateSelected) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  void _calculateTotalPrice() {
    int numberOfDays = _checkOutDate.difference(_checkInDate).inDays;
    price = widget.room.pricePerNight * numberOfDays;
  }

  void _selectCheckInDate(DateTime selectedDate) {
    setState(() {
      _checkInDate = selectedDate;
      if (_checkOutDate.isBefore(_checkInDate)) {
        _checkOutDate = _checkInDate.add(const Duration(days: 1));
      }
      _calculateTotalPrice();
    });
  }

  void _selectCheckOutDate(DateTime selectedDate) {
    setState(() {
      _checkOutDate = selectedDate;
      _calculateTotalPrice();
    });
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Booking'),
        content: const Text('Anda yakin ingin melakukan booking?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Konfirmasi'),
            onPressed: () {
              Navigator.of(context).pop();
              _prosesBooking(); // Panggil fungsi untuk melanjutkan proses booking
            },
          ),
        ],
      ),
    );
  }

  void _prosesBooking() {
    final userId = context.read<UserProvider>().uid;

    Map<String, dynamic> bookingData = {
      'roomId': widget.room.id,
      'hotelName': widget.hotel.name,
      'roomType': widget.room.type,
      'checkInDate': _checkInDate,
      'checkOutDate': _checkOutDate,
      'price': price,
      'bookingDate': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
      'paymentMethod': _selectedPaymentMethod,
      'user': userId,
    };

    if (_selectedPaymentMethod == 'Kartu Kredit') {
      bookingData['creditCardNumber'] = _creditCardNumber;
    } else {
      bookingData['bankName'] = _selectedBank;
    }

    FirebaseFirestore.instance
        .collection('bookings')
        .add(bookingData)
        .then((value) {
      Map<String, dynamic> historyData = {
        'type': 'hotel',
        'itemId': widget.hotel.id,
        'name': widget.hotel.name,
        'details': widget.room.type,
        'totalHarga': price,
        'date': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
      };

      // Menambahkan data history ke koleksi 'history' di dalam dokumen user
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(historyData)
          .then((_) {
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
        _showErrorDialog('Error', 'Gagal menambahkan data history: $error');
      });
    }).catchError((error) {
      _showErrorDialog('Error', 'Gagal melakukan booking: $error');
    });
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                          Text(
                              'Fasilitas: ${widget.room.facilities.join(', ')}'),
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
                onPressed: () => _selectDate(context, _selectCheckInDate),
                child: Text(DateFormat('dd MMMM yyyy').format(_checkInDate)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tanggal Check-out:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectDate(context, _selectCheckOutDate),
                child: Text(DateFormat('dd MMMM yyyy').format(_checkOutDate)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Metode Pembayaran:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                    // Reset selected bank and credit card number when changing payment method
                    _selectedBank = 'BCA';
                    _creditCardNumber = '';
                    _selectedEwallet = "OVO";
                  });
                },
                items: <String>['Transfer Bank', 'Kartu Kredit', 'E-Wallet']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (_selectedPaymentMethod == 'Transfer Bank')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Bank Tujuan:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBank,
                      onChanged: (value) {
                        setState(() {
                          _selectedBank = value!;
                        });
                      },
                      items: <String>['BCA', 'BRI', 'BNI', 'Mandiri']
                          .map((String bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              if (_selectedPaymentMethod == 'E-Wallet')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'E-Wallet:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedEwallet,
                      onChanged: (value) {
                        setState(() {
                          _selectedEwallet = value!;
                        });
                      },
                      items: <String>['DANA', 'OVO', 'Doku', 'Gopay']
                          .map((String eWallet) {
                        return DropdownMenuItem<String>(
                          value: eWallet,
                          child: Text(eWallet),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              if (_selectedPaymentMethod == 'Kartu Kredit')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Nomor Kartu Kredit:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _creditCardNumber = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nomor kartu kredit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              const Text(
                'Total Harga:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp $price',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text('Konfirmasi Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
