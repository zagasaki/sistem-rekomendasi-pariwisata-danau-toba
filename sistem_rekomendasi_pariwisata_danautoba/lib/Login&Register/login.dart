// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart'; // Sesuaikan path-nya
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/register.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Map<String, dynamic> userData = {};
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user?.uid ?? "";
      context.read<UserProvider>().setUid(uid);

      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Simpan data pengguna di shared preferences
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      await prefs.setString('uid', uid);
      await prefs.setString('username', userData['username']);
      await prefs.setString('email', userData['email']);
      await prefs.setString('phone', userData['phone']);
      // Mengatasi profilephoto yang mungkin null dengan nilai default
      String profilePhoto = userData['profilephoto'] ?? "";
      await prefs.setString('profilephoto', profilePhoto);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );

      Fluttertoast.showToast(
        msg: 'Login berhasil',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
        msg: error.message ?? "Terjadi kesalahan saat login",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      await prefs.setBool('login', true);
    }
    print(prefs.get("login"));
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
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text("Siap\nUntuk\nMulai?",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: "roboto")),
                const SizedBox(height: 180),
                // FORM LOGIN
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Column(
                    children: [
                      // EMAIL
                      const Text(
                        "Email",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusColor: Colors.white,
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.5),
                            hintText: "Email",
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan alamat email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Masukkan alamat email yang valid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // PASSWORD
                      const Text("Password",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15)),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.5),
                            hintText: "Minimal 8 Karakter",
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan kata sandi Anda';
                            } else if (value.length < 8) {
                              return 'Kata sandi minimal harus 8 karakter';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // TOMBOL LOGIN
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text("Daftar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
