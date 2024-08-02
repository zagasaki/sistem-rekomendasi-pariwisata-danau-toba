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
  DateTime? _selectedDate;
  int _selectedNumberOfPeople = 1;
  final TextEditingController _dateController = TextEditingController();

  final Map<String, List<String>> paymentOptions = {
    'E-Wallet': ['Dana', 'OVO', 'Doku'],
    'Bank Transfer': ['BRI', 'BCA', 'Mandiri'],
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
          title: const Text('Confirm Transaction'),
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
                Text('Payment Option: $_selectedPaymentOption'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ticket Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  widget.ticket.from,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color2),
                ),
                const Icon(Icons.arrow_right),
                Text(
                  widget.ticket.to,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color2),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Depart Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Departure Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Depart Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),
            const Text(
              'Number of People:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),
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
                });
              },
              items: paymentOptions.keys
                  .map((method) => DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
            ),
            if (_selectedPaymentMethod != null) const SizedBox(height: 20),
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
                  });
                },
                items: paymentOptions[_selectedPaymentMethod]!
                    .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 20),
            Text(
              'Total Price:${currencyFormatter.format(widget.ticket.price * _selectedNumberOfPeople)}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedDate != null &&
                    _selectedDepartureTime != null &&
                    _selectedPaymentMethod != null &&
                    (_selectedPaymentOption != null ||
                        _selectedPaymentMethod == 'E-Wallet' ||
                        _selectedPaymentMethod == 'Bank Transfer')) {
                  {
                    _showConfirmationDialog();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please select all required fields.'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Book Ticket',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
