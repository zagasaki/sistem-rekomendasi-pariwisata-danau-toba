import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/UserModel.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/providers/UserProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart'; // Sesuaikan path-nya
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  Future<void> _login(BuildContext context) async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Ambil data pengguna dari Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (snapshot.exists) {
          // Buat objek UserModel dari data Firestore
          UserModel user = UserModel.fromMap(snapshot.data()!);

          // Simpan data pengguna di UserProvider
          Provider.of<UserProvider>(context, listen: false).setUser(user);

          // Navigasi ke halaman utama setelah login berhasil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data pengguna tidak ditemukan')));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          // Handle jika email atau password salah
          setState(() {
            if (e.code == 'user-not-found') {
              emailError = 'Email tidak terdaftar';
            } else {
              passwordError = 'Password salah';
            }
          });
        } else {
          // Handle kesalahan lainnya
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
        }
      } catch (e) {
        // Tangani kesalahan lainnya
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
      }
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
          child: Form(
            key: _formKey,
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
                            errorText: emailError,
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
                            errorText: passwordError,
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
                        onPressed: () => _login(context),
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
