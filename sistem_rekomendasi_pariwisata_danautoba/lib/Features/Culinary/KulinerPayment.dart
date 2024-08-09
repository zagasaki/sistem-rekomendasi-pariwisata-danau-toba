import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/KulinerModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Culinary/VirtualAccountPage.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/style.dart';

class KulinerPayment extends StatefulWidget {
  final KulinerModel kuliner;

  const KulinerPayment({super.key, required this.kuliner});

  @override
  State<KulinerPayment> createState() => _KulinerPaymentState();
}

class _KulinerPaymentState extends State<KulinerPayment> {
  final TextEditingController _completeAddressController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _detailBangunanController =
      TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedPaymentMethod = 'Transfer Bank';
  String _selectedEWallet = 'Gopay';
  String _selectedBankTransfer = 'BCA';
  int _quantity = 1;

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Address Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _kecamatanController,
                  decoration: const InputDecoration(labelText: 'Kecamatan'),
                ),
                TextField(
                    controller: _detailBangunanController,
                    decoration: const InputDecoration(
                        labelText:
                            'Building Details (Unit Number, Building Color)')),
                TextField(
                  controller: _noHpController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  String completeAddress = '${_addressController.text}, '
                      '${_kecamatanController.text}, '
                      '${_detailBangunanController.text}, '
                      '${_noHpController.text}';
                  _completeAddressController.text = completeAddress;
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmPurchase() {
    int totalPrice = widget.kuliner.price * _quantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kuliner: ${widget.kuliner.name}'),
              Text('Quantity: $_quantity'),
              Text('Total Price: Rp $totalPrice'),
              Text('Payment Method: $_selectedPaymentMethod'),
              if (_selectedPaymentMethod == 'E-Wallet')
                Text('E-Wallet: $_selectedEWallet'),
              Text('Address: ${_completeAddressController.text}'),
              Text('Notes: ${_notesController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String virtualAccountNumber = _generateVirtualAccountNumber();
                final user = context.read<UserProvider>();
                DateTime paymentDeadline =
                    DateTime.now().add(const Duration(hours: 1));
                String address = _completeAddressController.text;
                String notes = _notesController.text;

                Map<String, dynamic> purchaseData = {
                  'kulinerId': widget.kuliner.id,
                  'kulinerName': widget.kuliner.name,
                  'quantity': _quantity,
                  'totalPrice': widget.kuliner.price * _quantity,
                  'date': Timestamp.now(),
                  'userid': context.read<UserProvider>().uid
                };

                await FirebaseFirestore.instance
                    .collection('kuliner_log')
                    .add(purchaseData)
                    .then((purchaseDoc) {})
                    .catchError((error) {});

                Map<String, dynamic> historyData = {
                  'historyType': 'kuliner',
                  'date': DateFormat("dd-MM-yyyy HH:mm")
                      .format(DateTime.now())
                      .toString(),
                  'paymentMethod': _selectedPaymentMethod,
                  'price': widget.kuliner.price * _quantity,
                  'username': user.username,
                  'kulinerID': widget.kuliner.id,
                  'kulinerName': widget.kuliner.name,
                  'quantity': _quantity,
                  'address': address,
                  'notes': notes,
                  'pay': false,
                  'virtualAccountNumber': virtualAccountNumber,
                  'paymentDeadline': paymentDeadline,
                };
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('history')
                    .add(historyData)
                    .then((historyDoc) {})
                    .catchError((error) {});
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VirtualAccountPage(
                      virtualAccountNumber: virtualAccountNumber,
                    ),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  String _generateVirtualAccountNumber() {
    final random = Random();
    final accountNumber =
        List.generate(15, (index) => random.nextInt(10)).join();
    return accountNumber;
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    int totalPrice = widget.kuliner.price * _quantity;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fontSizeTitle = screenWidth * 0.035;
    final double fontSizeSubTitle = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.05;
    final double padding = screenWidth * 0.04;
    final double spacing = screenHeight * 0.02;

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: color1),
          centerTitle: true,
          backgroundColor: color2,
          title: Text(
            'Payment',
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showAddressDialog,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _completeAddressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: padding, horizontal: padding),
                    ),
                    readOnly: true,
                    style: TextStyle(fontSize: fontSizeSubTitle),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              ListTile(
                leading: Image.network(widget.kuliner.imageUrl,
                    width: MediaQuery.of(context).size.width * 0.2,
                    fit: BoxFit.fill),
                title: Text(
                  widget.kuliner.name,
                  style: TextStyle(fontSize: fontSizeTitle),
                ),
                subtitle: Text(
                  currencyFormatter.format(widget.kuliner.price),
                  style: TextStyle(fontSize: fontSizeSubTitle),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: iconSize),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(fontSize: fontSizeSubTitle),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: iconSize),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                style: TextStyle(fontSize: fontSizeSubTitle),
                minLines: 1,
              ),
              SizedBox(height: spacing),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: padding, horizontal: padding),
                ),
                value: _selectedPaymentMethod,
                items: ['Transfer Bank', 'E-Wallet']
                    .map((method) => DropdownMenuItem<String>(
                          value: method,
                          child: Text(method,
                              style: TextStyle(fontSize: fontSizeSubTitle)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              SizedBox(
                height: spacing,
              ),
              if (_selectedPaymentMethod == 'E-Wallet')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'E-Wallet',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: padding, horizontal: padding),
                  ),
                  value: _selectedEWallet,
                  items: ['Gopay', 'Ovo', 'Dana']
                      .map((ewallet) => DropdownMenuItem<String>(
                            value: ewallet,
                            child: Text(ewallet,
                                style: TextStyle(fontSize: fontSizeSubTitle)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEWallet = value!;
                    });
                  },
                ),
              if (_selectedPaymentMethod == 'Transfer Bank')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Transfer Bank',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: padding, horizontal: padding),
                  ),
                  value: _selectedBankTransfer,
                  items: ['BCA', 'BRI', 'BNI', 'Mandiri']
                      .map((bank) => DropdownMenuItem<String>(
                            value: bank,
                            child: Text(bank,
                                style: TextStyle(fontSize: fontSizeSubTitle)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBankTransfer = value!;
                    });
                  },
                ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: screenHeight * 0.07,
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
                blurStyle: BlurStyle.outer,
                color: Colors.black,
                blurRadius: 3,
                offset: Offset(0, 0),
                spreadRadius: 1)
          ]),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                alignment: Alignment.center,
                child: Text(
                  currencyFormatter.format(totalPrice),
                  style: TextStyle(fontSize: fontSizeSubTitle),
                ),
              )),
              Expanded(
                  child: InkWell(
                onTap: _confirmPurchase,
                child: Container(
                  decoration: const BoxDecoration(
                      color: color2,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  alignment: Alignment.center,
                  child: Text(
                    "Buy",
                    style: TextStyle(
                        color: Colors.white, fontSize: fontSizeSubTitle),
                  ),
                ),
              ))
            ],
          ),
        ));
  }
}
