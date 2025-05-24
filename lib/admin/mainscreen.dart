import 'package:flutter/material.dart';
import 'package:medicalapp/admin/userstable.dart';
import 'package:medicalapp/form_page.dart';
import 'package:medicalapp/googlesignin.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false, // Hides the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementPage()),
                );
              },
              icon: const Icon(Icons.group),
              label: const Text('Manage Users'),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApplicationForm()),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Create New student form'),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Settings Page
              },
              icon: const Icon(Icons.settings),
              label: const Text('Search and find student details'),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  signOutGoogle();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
