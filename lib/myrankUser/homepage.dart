import 'package:flutter/material.dart';
import 'package:medicalapp/admin/adminintreststatus.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/admin/userstable.dart';

import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/myrankUser/userSearchStudent.dart';
import 'package:medicalapp/myrankUser/useredit_form.dart';
import 'package:medicalapp/myrankUser/userform_page.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

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

            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserApplicationForm(),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Create New student form'),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserEditForm()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Search and find student details'),
            ),
            const SizedBox(height: 15),

            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  signOutGoogle();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Index()),
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
