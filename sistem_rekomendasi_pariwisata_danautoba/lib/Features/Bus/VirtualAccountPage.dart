import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart';

class VirtualAccountPage extends StatelessWidget {
  const VirtualAccountPage({super.key, required String virtualAccountNumber});

  String _generateVirtualAccountNumber() {
    final random = Random();
    final accountNumber =
        List.generate(15, (index) => random.nextInt(10)).join();
    return accountNumber;
  }

  @override
  Widget build(BuildContext context) {
    final virtualAccountNumber = _generateVirtualAccountNumber();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Virtual Account Number is:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                virtualAccountNumber,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainPage()));
                  },
                  child: const Text("return Home"))
            ],
          ),
        ),
      ),
    );
  }
}
