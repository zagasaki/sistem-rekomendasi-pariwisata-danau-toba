import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Features/Kuliner/KulinerModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

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
  String _selectedPaymentMethod = 'Cash';
  String _selectedEWallet = 'Gopay';
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
                      labelText: 'Detail Bangunan (No Unit, Warna)'),
                ),
                TextField(
                  controller: _noHpController,
                  decoration: const InputDecoration(labelText: 'No HP'),
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
                  setState(() {
                    _completeAddressController.text = completeAddress;
                  });
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
              onPressed: () {
                Navigator.pop(context);
                _buyItem();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _buyItem() async {
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
        .then((purchaseDoc) {
      _addToHistory(purchaseDoc.id);
    }).catchError((error) {
      print('Error buying item: $error');
    });
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _addToHistory(String purchaseId) async {
    final user = context.read<UserProvider>();

    String address = _completeAddressController.text;
    String notes = _notesController.text;

    Map<String, dynamic> historyData = {
      'historyType': 'kuliner',
      'date': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()).toString(),
      'paymentMethod': _selectedPaymentMethod,
      'price': widget.kuliner.price * _quantity,
      'username': user.username,
      'kulinerID': widget.kuliner.id,
      'kulinerName': widget.kuliner.name,
      'quantity': _quantity,
      'address': address,
      'notes': notes,
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add(historyData)
        .then((historyDoc) {
      print('Added to history: ${historyDoc.id}');
    }).catchError((error) {
      print('Error adding to history: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = widget.kuliner.price * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuliner Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _completeAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
              readOnly: true,
              onTap: _showAddressDialog,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Image.network(widget.kuliner.imageUrl,
                  width: 50, height: 50, fit: BoxFit.cover),
              title: Text(widget.kuliner.name),
              subtitle: Text('Rp ${widget.kuliner.price}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
                    },
                  ),
                  Text('$_quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Payment Method',
              ),
              value: _selectedPaymentMethod,
              items: ['Cash', 'E-Wallet', 'Credit Card']
                  .map((method) => DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            if (_selectedPaymentMethod == 'E-Wallet')
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'E-Wallet',
                ),
                value: _selectedEWallet,
                items: ['Gopay', 'Ovo', 'Dana']
                    .map((ewallet) => DropdownMenuItem<String>(
                          value: ewallet,
                          child: Text(ewallet),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEWallet = value!;
                  });
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: Rp $totalPrice'),
              ElevatedButton(
                onPressed: _confirmPurchase,
                child: const Text('Beli'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
