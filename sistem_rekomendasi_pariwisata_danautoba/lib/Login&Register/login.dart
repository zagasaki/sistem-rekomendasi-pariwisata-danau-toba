import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/ForgotPassword.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/MainPage.dart'; // Sesuaikan path-nya
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/register.dart'; // Import halaman forgot password
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isloading = true;
      });
      try {
        UserCredential userCredential =
            await firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String uid = userCredential.user?.uid ?? "";
        context.read<UserProvider>().setUid(uid);
        await prefs.setString("uid", uid);

        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        userSnapshot.data() as Map<String, dynamic>;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );

        Fluttertoast.showToast(
          msg: 'Login successful',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } on FirebaseAuthException catch (error) {
        _handleFirebaseAuthError(error);
      } catch (error) {
        Fluttertoast.showToast(
          msg: 'An error occurred during login: $error',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        await prefs.setBool('login', true);
        setState(() {
          isloading = false;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields correctly',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Future<void> _loginWithGoogle() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   GoogleSignIn googleSignIn = GoogleSignIn();

  //   try {
  //     GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       return;
  //     }
  //     GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential userCredential =
  //         await firebaseAuth.signInWithCredential(credential);
  //     String uid = userCredential.user?.uid ?? "";
  //     context.read<UserProvider>().setUid(uid);
  //     await prefs.setString("uid", uid);

  //     DocumentSnapshot userSnapshot =
  //         await FirebaseFirestore.instance.collection('users').doc(uid).get();
  //     if (!userSnapshot.exists) {
  //       await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //         'email': googleUser.email,
  //         'name': googleUser.displayName,
  //         'tags': ['parapat'],
  //         'vacationtags': ['pemandangandanau'],
  //         'phone': ''
  //       });
  //     }

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const MainPage()),
  //     );

  //     Fluttertoast.showToast(
  //       msg: 'Login successful with Google',
  //       gravity: ToastGravity.TOP,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //     );
  //   } on FirebaseAuthException catch (error) {
  //     _handleFirebaseAuthError(error);
  //   } catch (error) {
  //     Fluttertoast.showToast(
  //       msg: 'An error occurred during Google login: $error',
  //       gravity: ToastGravity.TOP,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //     );
  //   }
  // }

  // Future<void> _loginWithFacebook() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       final AccessToken accessToken = result.accessToken!;
  //       AuthCredential credential =
  //           FacebookAuthProvider.credential(accessToken.tokenString);

  //       UserCredential userCredential =
  //           await firebaseAuth.signInWithCredential(credential);
  //       String uid = userCredential.user?.uid ?? "";
  //       context.read<UserProvider>().setUid(uid);
  //       await prefs.setString("uid", uid);

  //       DocumentSnapshot userSnapshot =
  //           await FirebaseFirestore.instance.collection('users').doc(uid).get();
  //       if (!userSnapshot.exists) {
  //         await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //           'email': userCredential.user?.email,
  //           'name': userCredential.user?.displayName,
  //         });
  //       }

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const MainPage()),
  //       );

  //       Fluttertoast.showToast(
  //         msg: 'Login successful with Facebook',
  //         gravity: ToastGravity.TOP,
  //         backgroundColor: Colors.green,
  //         textColor: Colors.white,
  //       );
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: 'Facebook login was cancelled',
  //         gravity: ToastGravity.TOP,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //       );
  //     }
  //   } on FirebaseAuthException catch (error) {
  //     _handleFirebaseAuthError(error);
  //   } catch (error) {
  //     Fluttertoast.showToast(
  //       msg: 'An error occurred during Facebook login: $error',
  //       gravity: ToastGravity.TOP,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //     );
  //   }
  // }

  void _handleFirebaseAuthError(FirebaseAuthException error) {
    String message;
    print('FirebaseAuthException caught: ${error.code}');
    switch (error.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message =
            'The user corresponding to the given email has been disabled.';
        break;
      case 'user-not-found':
        message = 'There is no user corresponding to the given email.';
        break;
      case 'wrong-password':
        message = 'The password is invalid for the given email.';
        break;
      case 'account-exists-with-different-credential':
        message =
            'An account already exists with the same email address but different sign-in credentials.';
        break;
      case 'operation-not-allowed':
        message = 'Signing in with this provider is not enabled.';
        break;
      case 'network-request-failed':
        message = 'Network error, please try again later.';
        break;
      default:
        message = 'An undefined error occurred: ${error.message}';
    }
    print('Error message: $message');
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/laketoba.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey, // Assign the form key here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 260),
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Column(
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: Colors.white),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Password",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Colors.white)),
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
                            hintText: "Minimum 8 characters",
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      isloading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              child: const Text("Login"),
                            ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromARGB(255, 0, 255, 8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text("Forgot Password?",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(height: 10),
                      // Uncomment these lines if you want to enable social login buttons
                      // ElevatedButton.icon(
                      //   onPressed: _loginWithGoogle,
                      //   icon: Image.asset(
                      //     'assets/google_logo.png',
                      //     height: 24,
                      //     width: 24,
                      //   ),
                      //   label: const Text('Login with Google'),
                      // ),
                      // const SizedBox(height: 10),
                      // ElevatedButton.icon(
                      //   onPressed: _loginWithFacebook,
                      //   icon: Image.asset(
                      //     'assets/facebook_logo.png',
                      //     height: 24,
                      //     width: 24,
                      //   ),
                      //   label: const Text('Login with Facebook'),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
