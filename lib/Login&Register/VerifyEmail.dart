import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isVerified = false;
  bool canResendEmail = false;
  bool isChecking = false;
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    isVerified = user.emailVerified;
    if (!isVerified) {
      sendVerificationEmail();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      setState(() {
        canResendEmail = false;
      });
      await user.sendEmailVerification();
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkEmailVerified() async {
    user = FirebaseAuth.instance.currentUser!;
    await user.reload();
    setState(() {
      isVerified = user.emailVerified;
    });

    if (isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: isVerified
            ? const Text('Email has been verified. Redirecting...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'A verification email has been sent. Please check your inbox.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    child: const Text('Resend Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isChecking ? null : checkEmailVerified,
                    child: isChecking
                        ? const CircularProgressIndicator()
                        : const Text('I have verified my email'),
                  ),
                ],
              ),
      ),
    );
  }
}
