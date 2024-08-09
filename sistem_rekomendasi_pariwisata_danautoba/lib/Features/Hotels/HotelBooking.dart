import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/HotelModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Hotels/VirtualAccountPage.dart';
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
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hotel: ${widget.hotel.name}'),
            Text('Kamar: ${widget.room.type}'),
            Text(
                'Check-in: ${DateFormat('dd MMMM yyyy').format(_checkInDate)}'),
            Text(
                'Check-out: ${DateFormat('dd MMMM yyyy').format(_checkOutDate)}'),
            Text(
                'Harga: ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(price)}'),
            Text('Metode Pembayaran: $_selectedPaymentMethod'),
            if (_selectedPaymentMethod == 'Kartu Kredit')
              Text('Nomor Kartu Kredit: $_creditCardNumber'),
            if (_selectedPaymentMethod == 'Transfer Bank')
              Text('Bank: $_selectedBank'),
            const Text('Anda yakin ingin melakukan booking?')
          ],
        ),
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
    DateTime paymentDeadline = DateTime.now().add(const Duration(hours: 1));
    String virtualAccountNumber = _generateVirtualAccountNumber();

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
      'virtualAccountNumber': virtualAccountNumber,
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
        'virtualAccountNumber': virtualAccountNumber,
        'pay': false,
        'paymentDeadline': paymentDeadline,
      };

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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Terima kasih! Booking Anda telah berhasil.'),
                const SizedBox(height: 10),
                Text('Virtual Account Number: $virtualAccountNumber'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VirtualAccountPage(
                        virtualAccountNumber: virtualAccountNumber,
                      ),
                    ),
                  );
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

  String _generateVirtualAccountNumber() {
    final random = Random();
    final accountNumber =
        List.generate(15, (index) => random.nextInt(10)).join();
    return accountNumber;
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
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

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
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Kamar:',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Card(
                margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Column(
                  children: [
                    if (widget.room.imageUrl.isNotEmpty)
                      Image.network(
                        widget.room.imageUrl,
                        height: screenWidth * 0.5,
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
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                              'Fasilitas: ${widget.room.facilities.join(', ')}'),
                          SizedBox(height: screenWidth * 0.01),
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
              SizedBox(height: screenWidth * 0.04),
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'Check-in:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: () =>
                            _selectDate(context, _selectCheckInDate),
                        child: Text(
                            DateFormat('dd MMMM yyyy').format(_checkInDate)),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                    ],
                  ),
                  const Icon(Icons.keyboard_double_arrow_right_rounded),
                  Column(
                    children: [
                      Text(
                        'Check-out:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: () =>
                            _selectDate(context, _selectCheckOutDate),
                        child: Text(
                            DateFormat('dd MMMM yyyy').format(_checkOutDate)),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                    ],
                  )
                ],
              ),
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
                    _selectedEwallet = 'OVO';
                  });
                },
                items: <String>['Transfer Bank', 'Kartu Kredit', 'E-Wallet']
                    .map((String value) {
                  IconData icon;
                  switch (value) {
                    case 'Transfer Bank':
                      icon = Icons.account_balance;
                      break;
                    case 'Kartu Kredit':
                      icon = Icons.credit_card;
                      break;
                    case 'E-Wallet':
                      icon = Icons.account_balance_wallet;
                      break;
                    default:
                      icon = Icons.payment;
                  }
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.grey),
                        SizedBox(width: screenWidth * 0.03),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (_selectedPaymentMethod == 'Transfer Bank')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Bank Tujuan:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    DropdownButtonFormField<String>(
                      value: _selectedBank,
                      onChanged: (value) {
                        setState(() {
                          _selectedBank = value!;
                        });
                      },
                      items: <String>['BCA', 'BRI', 'BNI', 'Mandiri']
                          .map((String bank) {
                        String imagePath;
                        switch (bank) {
                          case 'BCA':
                            imagePath = 'assets/bca_logo.png';
                            break;
                          case 'BRI':
                            imagePath = 'assets/bri_logo.png';
                            break;
                          case 'BNI':
                            imagePath = 'assets/bni_logo.png';
                            break;
                          case 'Mandiri':
                            imagePath = 'assets/mandiri_logo.png';
                            break;
                          default:
                            imagePath = 'assets/bca_logo.png';
                        }
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Row(
                            children: [
                              Image.asset(imagePath, width: 20, height: 20),
                              const SizedBox(width: 10),
                              Text(bank),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              if (_selectedPaymentMethod == 'E-Wallet')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'E-Wallet:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    DropdownButtonFormField<String>(
                      value: _selectedEwallet,
                      onChanged: (value) {
                        setState(() {
                          _selectedEwallet = value!;
                        });
                      },
                      items: <String>['DANA', 'OVO', 'Doku', 'Gopay']
                          .map((String eWallet) {
                        String imagePath;
                        switch (eWallet) {
                          case 'DANA':
                            imagePath = 'assets/dana_logo.jpg';
                            break;
                          case 'OVO':
                            imagePath = 'assets/ovo_logo.jpg';
                            break;
                          case 'Doku':
                            imagePath = 'assets/doku_logo.png';
                            break;
                          case 'Gopay':
                            imagePath = 'assets/gopay_logo.jpg';
                            break;
                          default:
                            imagePath = 'assets/dana_logo.jpg';
                        }
                        return DropdownMenuItem<String>(
                          value: eWallet,
                          child: Row(
                            children: [
                              Image.asset(imagePath, width: 20, height: 20),
                              const SizedBox(width: 10),
                              Text(eWallet),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              if (_selectedPaymentMethod == 'Kartu Kredit')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Nomor Kartu Kredit:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
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
              SizedBox(height: screenWidth * 0.04),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: mediaQuery.size.height * 0.06,
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
              blurStyle: BlurStyle.outer,
              color: Colors.black,
              blurRadius: 2,
              offset: Offset(0, 0),
              spreadRadius: 1)
        ]),
        child: Row(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.center,
              child: Text(
                currencyFormatter.format(price),
                style: TextStyle(fontSize: screenWidth * 0.05),
              ),
            )),
            Expanded(
                child: InkWell(
              onTap: _confirmBooking,
              child: Container(
                decoration: const BoxDecoration(
                    color: color2,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                alignment: Alignment.center,
                child: Text(
                  "Confirm Booking",
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.05),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
