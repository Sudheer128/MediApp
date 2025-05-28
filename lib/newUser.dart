import 'package:flutter/material.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wait for Admin Approval',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                signOutGoogle();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Index()),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
