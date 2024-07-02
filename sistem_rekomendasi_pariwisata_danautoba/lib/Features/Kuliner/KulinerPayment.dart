import 'package:flutter/material.dart';
import 'KulinerModel.dart'; // Import the KulinerModel if necessary

class KulinerPayment extends StatefulWidget {
  final KulinerModel kuliner;

  const KulinerPayment({super.key, required this.kuliner});

  @override
  State<KulinerPayment> createState() => _KulinerPaymentState();
}

class _KulinerPaymentState extends State<KulinerPayment> {
  final List<Map<String, String>> paymentMethods = [
    {
      'id': '1',
      'name': 'Credit Card',
      'iconUrl':
          'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png'
    },
    {
      'id': '2',
      'name': 'PayPal',
      'iconUrl':
          'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png'
    },
    {
      'id': '3',
      'name': 'Google Pay',
      'iconUrl':
          'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png'
    },
    {
      'id': '4',
      'name': 'Apple Pay',
      'iconUrl':
          'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png'
    },
    {
      'id': '5',
      'name': 'Bank Transfer',
      'iconUrl':
          'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png'
    },
  ];

  String? selectedMethod;

  void selectPaymentMethod(String? id) {
    setState(() {
      selectedMethod = id;
    });
  }

  void proceedToPay() {
    if (selectedMethod != null) {
      // Proceed with the payment process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Payment successful with method ID: $selectedMethod')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for ${widget.kuliner.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return ListTile(
                    leading: Image.network(method['iconUrl']!,
                        width: 40, height: 40),
                    title: Text(method['name']!),
                    trailing: Radio<String>(
                      value: method['id']!,
                      groupValue: selectedMethod,
                      onChanged: selectPaymentMethod,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: proceedToPay,
              child: const Text('Proceed to Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
