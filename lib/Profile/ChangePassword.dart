import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/ResetPasswordProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  _ChangepasswordState createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _message = '';

  void _resetPassword() async {
    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() {
        _message = 'Email cannot be Empty';
      });
      Fluttertoast.showToast(
          msg: _message,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }

    final emailValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    ).hasMatch(email);

    if (!emailValid) {
      setState(() {
        _message = 'Email invalid';
      });
      Fluttertoast.showToast(
          msg: _message,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }

    try {
      if (email != context.read<UserProvider>().email) {
        setState(() {
          _message = 'This is not your email, enter your email';
        });
        Fluttertoast.showToast(
            msg: _message,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _message = 'A reset password link has been sent to your email.';
      });
      Fluttertoast.showToast(
          msg: _message,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white);
      context.read<ResetPasswordProvider>().startTimer();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailSentScreen(email: email),
        ),
      );
    } catch (e) {
      setState(() {
        _message = 'there is an error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ResetPasswordProvider>(
              builder: (context, resetPasswordProvider, child) {
                return ElevatedButton(
                  onPressed: resetPasswordProvider.canResendEmail
                      ? _resetPassword
                      : null,
                  child: Text(
                    resetPasswordProvider.canResendEmail
                        ? 'Send Password Reset Link'
                        : 'wait ${resetPasswordProvider.secondsRemaining}',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class EmailSentScreen extends StatefulWidget {
  final String email;

  const EmailSentScreen({super.key, required this.email});

  @override
  _EmailSentScreenState createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends State<EmailSentScreen> {
  String _message = '';

  void _resendEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      setState(() {
        _message = 'The password reset link has been resent to your email.';
      });
      Fluttertoast.showToast(
          msg: _message,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white);
      context.read<ResetPasswordProvider>().startTimer();
    } catch (e) {
      setState(() {
        _message = 'There is an error: $e';
      });
      Fluttertoast.showToast(
          msg: _message,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Sent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                'A password reset link has been sent to your email: ${widget.email}.'),
            const SizedBox(height: 16),
            Consumer<ResetPasswordProvider>(
              builder: (context, resetPasswordProvider, child) {
                return ElevatedButton(
                  onPressed: resetPasswordProvider.canResendEmail
                      ? _resendEmail
                      : null,
                  child: Text(
                    resetPasswordProvider.canResendEmail
                        ? 'Resend Link'
                        : 'wait ${resetPasswordProvider.secondsRemaining} ',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
