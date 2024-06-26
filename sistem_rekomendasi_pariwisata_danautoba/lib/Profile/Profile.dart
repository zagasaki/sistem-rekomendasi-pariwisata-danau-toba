import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://example.com/profile.jpg', // Replace with actual image URL
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'WILLY PIETER JULIUS SITUMORANG',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '081266088224',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const Text(
                'willypieter8@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle edit profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle change password
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
                  // Handle logout
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
