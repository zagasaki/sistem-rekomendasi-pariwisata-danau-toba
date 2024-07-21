import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Home/HomePage.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

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
  String _selectedPaymentMethod = 'Transfer Bank';
  String _selectedBank = 'BCA';
  String _creditCardNumber = '';
  String _selectedEwallet = "OVO";

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
        'historyType': 'hotel',
        'date': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
        'paymentMethod': _selectedPaymentMethod,
        'price': price,
        'username': context.read<UserProvider>().username,
        'reviewed': false,
        'hotelID': widget.hotel.id,
        'hotelName': widget.hotel.name,
        'roomType': widget.room.type,
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: color1,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: color2,
        title: const Text(
          'Booking',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Kamar:',
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // 5% of screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.02), // 2% of screen width
              Card(
                margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Column(
                  children: [
                    if (widget.room.imageUrl.isNotEmpty)
                      Image.network(
                        widget.room.imageUrl,
                        height: screenWidth * 0.5, // 50% of screen width
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
                          SizedBox(
                              height: screenWidth * 0.01), // 1% of screen width
                          Text(
                              'Fasilitas: ${widget.room.facilities.join(', ')}'),
                          SizedBox(
                              height: screenWidth * 0.01), // 1% of screen width
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
              SizedBox(height: screenWidth * 0.04), // 4% of screen width
              Text(
                'Tanggal Check-in:',
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // 5% of screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.02), // 2% of screen width
              ElevatedButton(
                onPressed: () => _selectDate(context, _selectCheckInDate),
                child: Text(DateFormat('dd MMMM yyyy').format(_checkInDate)),
              ),
              SizedBox(height: screenWidth * 0.04), // 4% of screen width
              Text(
                'Tanggal Check-out:',
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // 5% of screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.02), // 2% of screen width
              ElevatedButton(
                onPressed: () => _selectDate(context, _selectCheckOutDate),
                child: Text(DateFormat('dd MMMM yyyy').format(_checkOutDate)),
              ),
              SizedBox(height: screenWidth * 0.04), // 4% of screen width
              Text(
                'Metode Pembayaran:',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
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
                    SizedBox(height: screenWidth * 0.02), // 2% of screen width
                    Text(
                      'Bank Tujuan:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // 4% of screen width
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02), // 2% of screen width
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
                    SizedBox(height: screenWidth * 0.02), // 2% of screen width
                    Text(
                      'E-Wallet:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // 4% of screen width
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02), // 2% of screen width
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
                    SizedBox(height: screenWidth * 0.02), // 2% of screen width
                    Text(
                      'Nomor Kartu Kredit:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // 4% of screen width
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02), // 2% of screen width
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
              SizedBox(height: screenWidth * 0.04), // 4% of screen width
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08), // 8% of screen width
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rp $price',
              style: TextStyle(
                fontSize: screenWidth * 0.06, // 6% of screen width
                fontWeight: FontWeight.bold,
                color: color2,
              ),
            ),
            SizedBox(height: screenWidth * 0.04), // 4% of screen width
            InkWell(
              onTap: _confirmBooking,
              child: Container(
                padding:
                    EdgeInsets.all(screenWidth * 0.02), // 2% of screen width
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: color2,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                height: screenWidth * 0.15, // 15% of screen width
                child: Text(
                  'Konfirmasi Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: screenWidth * 0.04, // 4% of screen width
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
