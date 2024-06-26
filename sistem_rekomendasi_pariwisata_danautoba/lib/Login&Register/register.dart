// ignore_for_file: use_build_context_synchronously

import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/login.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late Map<String, dynamic> userData = {};
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool isRegistering = false;

  Future<String?> _register() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRegistering = true;
    });

    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final email = _emailController.text;
      final password = _passwordController.text;

      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user?.uid ?? "";

      context.read<UserProvider>().setUid(uid);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _usernameController.text,
        'phone': _phoneController.text,
        'email': email,
      });

      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      setState(() {
        userData = userSnapshot.data() as Map<String, dynamic>;
      });

      await prefs.setString('uid', uid);
      await prefs.setString('username', userData['username']);
      await prefs.setString('email', userData['email']);
      await prefs.setString('phone', userData['phone']);
      // Mengatasi profilephoto yang mungkin null dengan nilai default
      String profilePhoto = userData['profilephoto'] ?? "";
      await prefs.setString('profilephoto', profilePhoto);

      // Memperbarui data pengguna di UserProvider
      context.read<UserProvider>().updateUserData(
            userData['username'],
            userData['email'],
            userData['phone'],
            profilePhoto, // Menggunakan profilePhoto yang telah ditangani
          );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainPage()));

      return 'Pendaftaran berhasil';
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
          msg: error.message ?? 'Terjadi kesalahan', gravity: ToastGravity.TOP);
    } finally {
      setState(() {
        isRegistering = false;
      });
      await prefs.setBool('login', true);
    }
    print(prefs.get("login"));
    return null;
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
              const Text("Ready To\nGo?Let's\nGooo",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: "roboto")),
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
                    // Container(
                    //   margin: const EdgeInsets.all(10),
                    //   child: Column(
                    //     children: [
                    //       const Text(
                    //         "Confirm Password",
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.w900, fontSize: 15),
                    //       ),
                    //       SizedBox(
                    //         width: 300,
                    //         child: TextField(
                    //           controller: _confirmPasswordController,
                    //           obscureText: true,
                    //           showCursor: true,
                    //           decoration: InputDecoration(
                    //             contentPadding:
                    //                 const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    //             filled: true,
                    //             fillColor: Colors.grey.withOpacity(0.5),
                    //             hintText: "min.8 Character",
                    //             border: const OutlineInputBorder(
                    //                 borderSide: BorderSide.none,
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(10))),
                    //             enabledBorder: const UnderlineInputBorder(
                    //                 borderSide: BorderSide(color: Colors.green),
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(10))),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     Checkbox(
              //       checkColor: Colors.green,
              //       value: isChecked,
              //       onChanged: _checkboxToggle,
              //     ),
              //     const Text(
              //       "I agree with the terms of use and privacy policy",
              //       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              //     )
              //   ],
              // ),
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
