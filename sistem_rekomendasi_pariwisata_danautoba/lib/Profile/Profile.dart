import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Login&Register/login.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Profile/ChangePassword.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Profile/EditProfile.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/NavBarProv.dart';
import 'package:sistem_rekomendasi_pariwisata_danautoba/Providers/UserProv.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('uid');
    context.read<NavBarProv>().logout();

    prefs.setBool("login", false);
    print(prefs.get("login"));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 50,
                backgroundImage: NetworkImage(
                  user.profilephoto ?? '',
                ),
                child: user.profilephoto == null
                    ? const Icon(Icons.person, size: 80)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.phone,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Changepassword()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle language change
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms and Conditions'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle terms and conditions
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.support),
                title: const Text('Customer Service'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle customer service
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Linked Account'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle linked account
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.arrow_forward, color: Colors.red),
                onTap: () {
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
