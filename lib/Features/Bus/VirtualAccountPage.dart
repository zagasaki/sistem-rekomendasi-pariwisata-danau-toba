import 'package:flutter/material.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart';

class VirtualAccountPage extends StatelessWidget {
  const VirtualAccountPage({super.key, required this.virtualAccountNumber});

  final String virtualAccountNumber;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double fontSizeTitle = screenWidth * 0.05;
    final double fontSizeAccountNumber = screenWidth * 0.07;
    final double buttonWidth = screenWidth * 0.6;
    final double padding = screenWidth * 0.05;
    final double spacing = screenHeight * 0.03;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Virtual Account Number is:',
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing),
              Text(
                virtualAccountNumber,
                style: TextStyle(
                  fontSize: fontSizeAccountNumber,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: spacing),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(buttonWidth, 48),
                ),
                child: Text(
                  "Return Home",
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
