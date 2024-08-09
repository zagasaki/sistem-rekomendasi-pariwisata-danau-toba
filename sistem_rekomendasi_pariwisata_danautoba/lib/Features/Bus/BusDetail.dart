import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Bus/BusModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Bus/VirtualAccountPage.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class BusTicketDetailPage extends StatefulWidget {
  final BusTicket ticket;

  const BusTicketDetailPage({super.key, required this.ticket});

  @override
  _BusTicketDetailPageState createState() => _BusTicketDetailPageState();
}

class _BusTicketDetailPageState extends State<BusTicketDetailPage> {
  String? _selectedDepartureTime;
  String? _selectedPaymentMethod;
  String? _selectedPaymentOption;
  String? _selectedPaymentOptionImage;
  DateTime? _selectedDate;
  int _selectedNumberOfPeople = 1;
  final TextEditingController _dateController = TextEditingController();

  final Map<String, List<Map<String, String>>> paymentOptions = {
    'E-Wallet': [
      {'name': 'Dana', 'image': 'assets/dana_logo.jpg'},
      {'name': 'OVO', 'image': 'assets/ovo_logo.jpg'},
      {'name': 'Doku', 'image': 'assets/dana_logo.jpg'},
    ],
    'Bank Transfer': [
      {'name': 'BRI', 'image': 'assets/bri_logo.png'},
      {'name': 'BCA', 'image': 'assets/bca_logo.png'},
      {'name': 'Mandiri', 'image': 'assets/mandiri_logo.png'},
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.ticket.departTime.isNotEmpty) {
      _selectedDepartureTime = widget.ticket.departTime.first;
    }
  }

  String _generateVirtualAccountNumber() {
    final random = Random();
    final accountNumber =
        List.generate(15, (index) => random.nextInt(10)).join();
    return accountNumber;
  }

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat("dd-MM-yyyy").format(pickedDate);
      });
    }
  }

  void _showConfirmationDialog() {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    final user = context.read<UserProvider>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Transaction',
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${widget.ticket.from}'),
              Text('To: ${widget.ticket.to}'),
              Text(
                  'Departure Date: ${_selectedDate != null ? DateFormat("dd-MM-yyyy").format(_selectedDate!) : 'Not selected'}'),
              Text('Departure Time: $_selectedDepartureTime'),
              Text('Number of People: $_selectedNumberOfPeople'),
              Text(
                  'Total Price: ${currencyFormatter.format(widget.ticket.price * _selectedNumberOfPeople)}'),
              Text('Payment Method: $_selectedPaymentMethod'),
              if (_selectedPaymentOption != null)
                Row(
                  children: [
                    Image.asset(
                      _selectedPaymentOptionImage!,
                      width: MediaQuery.of(context).size.width * 0.05,
                      height: MediaQuery.of(context).size.width * 0.05,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 8),
                    Text(_selectedPaymentOption!),
                  ],
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04),
              ),
              onPressed: () {
                DateTime paymentDeadline =
                    DateTime.now().add(const Duration(minutes: 30));
                String virtualAccountNumber = _generateVirtualAccountNumber();
                FirebaseFirestore.instance
                    .collection('bus_ticket_bookings')
                    .add({
                  'totalPassanger': _selectedNumberOfPeople,
                  'ticketID': widget.ticket.id,
                  'transportName': widget.ticket.transportName,
                  'userId': user.uid,
                  'username': user.username,
                  'bookingDate':
                      DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
                  'origin': widget.ticket.from,
                  'destination': widget.ticket.to,
                  'departDate': _selectedDate != null
                      ? DateFormat("dd-MM-yyyy").format(_selectedDate!)
                      : null,
                  'departTime': _selectedDepartureTime,
                  'price': widget.ticket.price * _selectedNumberOfPeople,
                  'paymentMethod': _selectedPaymentMethod,
                  'paymentOption': _selectedPaymentOption,
                  'virtualAccountNumber': virtualAccountNumber
                });

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('history')
                    .add({
                  'totalPassanger': _selectedNumberOfPeople,
                  'historyType': 'bus',
                  'ticketID': widget.ticket.id,
                  'transportName': widget.ticket.transportName,
                  'userId': user.uid,
                  'username': user.username,
                  'date': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
                  'origin': widget.ticket.from,
                  'destination': widget.ticket.to,
                  'departDate': _selectedDate != null
                      ? DateFormat("dd-MM-yyyy").format(_selectedDate!)
                      : null,
                  'departTime': _selectedDepartureTime,
                  'price': widget.ticket.price * _selectedNumberOfPeople,
                  'paymentMethod': _selectedPaymentMethod,
                  'paymentOption': _selectedPaymentOption,
                  'pay': false,
                  'virtualAccountNumber': virtualAccountNumber,
                  'paymentDeadline': paymentDeadline,
                });

                setState(() {
                  _selectedDate = null;
                  _selectedDepartureTime = null;
                  _selectedPaymentMethod = null;
                  _selectedPaymentOption = null;
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VirtualAccountPage(
                      virtualAccountNumber: virtualAccountNumber,
                    ),
                  ),
                );
                Fluttertoast.showToast(
                    msg: "Booking Success",
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    textColor: Colors.white);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Bus Ticket Booking'),
          backgroundColor: color1,
        ),
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date:',
                style: TextStyle(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: _showDatePicker,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Date',
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Select Departure Time:',
                style: TextStyle(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedDepartureTime,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDepartureTime = newValue;
                  });
                },
                items: widget.ticket.departTime
                    .map((time) => DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        ))
                    .toList(),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Number of People:',
                style: TextStyle(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                value: _selectedNumberOfPeople,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
                  setState(() {
                    _selectedNumberOfPeople = newValue!;
                  });
                },
                items: List.generate(6, (index) => index + 1)
                    .map((number) => DropdownMenuItem<int>(
                          value: number,
                          child: Text(number.toString()),
                        ))
                    .toList(),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Payment Method:',
                style: TextStyle(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                    _selectedPaymentOption = null;
                    _selectedPaymentOptionImage = null;
                  });
                },
                items: paymentOptions.keys
                    .map((method) => DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
              ),
              if (_selectedPaymentMethod != null)
                SizedBox(height: screenHeight * 0.02),
              if (_selectedPaymentMethod != null)
                DropdownButtonFormField<String>(
                  value: _selectedPaymentOption,
                  decoration: const InputDecoration(
                    labelText: 'Payment Option',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPaymentOption = newValue;
                      _selectedPaymentOptionImage =
                          paymentOptions[_selectedPaymentMethod!]!.firstWhere(
                              (option) => option['name'] == newValue)['image'];
                    });
                  },
                  items: paymentOptions[_selectedPaymentMethod!]!
                      .map((option) => DropdownMenuItem<String>(
                            value: option['name'],
                            child: PaymentOptionWidget(
                              name: option['name']!,
                              imagePath: option['image']!,
                            ),
                          ))
                      .toList(),
                ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                currencyFormatter
                    .format(widget.ticket.price * _selectedNumberOfPeople),
                style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedDate != null &&
                      _selectedDepartureTime != null &&
                      _selectedPaymentMethod != null &&
                      (_selectedPaymentOption != null ||
                          _selectedPaymentMethod == 'E-Wallet' ||
                          _selectedPaymentMethod == 'Bank Transfer')) {
                    _showConfirmationDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select all required fields.'),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color2,
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenHeight * 0.05),
                  textStyle: TextStyle(fontSize: screenWidth * 0.045),
                ),
                child: const Text(
                  'Book Ticket',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ));
  }
}

class PaymentOptionWidget extends StatelessWidget {
  final String name;
  final String imagePath;

  const PaymentOptionWidget(
      {super.key, required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 30,
          height: 30,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class PaymentMethodWidget extends StatelessWidget {
  final String name;
  final IconData icon;

  const PaymentMethodWidget(
      {super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 40,
          color: Colors.black,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
