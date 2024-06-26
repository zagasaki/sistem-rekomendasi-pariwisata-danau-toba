import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/UserModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/login.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isChecked = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _checkboxToggle(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  }

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled')),
      );
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is not valid')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be numeric')),
      );
      return;
    }
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        username: _usernameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      // Save additional user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      // Set user data in provider
      Provider.of<UserProvider>(context, listen: false).setUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already in use';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else {
        errorMessage = e.message ?? 'Registration failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/LoginPage.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text("Ready To\nGo?Let's\nGooo",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: "roboto")),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "Username",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _usernameController,
                              showCursor: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.5),
                                hintText: "Username",
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "Email",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _emailController,
                              showCursor: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.5),
                                hintText: "Email",
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "No Hp",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _phoneController,
                              showCursor: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.5),
                                hintText: "No Hp",
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              showCursor: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.5),
                                hintText: "Min.8 Charactere",
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            "Confirm Password",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              showCursor: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.5),
                                hintText: "min.8 Character",
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.green,
                    value: isChecked,
                    onChanged: _checkboxToggle,
                  ),
                  const Text(
                    "I agree with the terms of use and privacy policy",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  )
                ],
              ),
              Row(
                children: [
                  const Text(
                    "Have Any Account?",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text("Sign In",
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
