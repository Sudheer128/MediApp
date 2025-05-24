import 'package:flutter/material.dart';
import 'package:medicalapp/edit_formAfterSave.dart';
import 'package:medicalapp/googlesignin.dart';

import 'package:medicalapp/student/form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardApp extends StatelessWidget {
  const DoctorDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DoctorDashboard(),
    );
  }
}

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: enabled ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        enabled ? Colors.blue : Colors.grey.shade300,
                    foregroundColor: enabled ? Colors.white : Colors.grey,
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteProfileSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Complete Your Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "A complete profile helps you stand out to potential employers. Make sure to include:",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• Educational background"),
                Text("• Professional experience"),
                Text("• Specialties and skills"),
                Text("• Certifications and credentials"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApplicationForm()),
                );
              },
              child: const Text("Create Profile"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // close drawer

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorDashboardApp()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('userid') ?? 0;
                Navigator.pop(context); // close drawer

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditForm(applicationId: userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('LogOut'),
              onTap: () {
                Navigator.pop(context); // close drawer
                signOutGoogle();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),

            // You can add more menu items here...
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Welcome, doctor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your doctor dashboard",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                _buildCard(
                  title: "Your Profile",
                  subtitle: "Complete and manage your professional profile",
                  description:
                      "A complete profile increases your visibility to medical institutions looking for qualified professionals.",
                  buttonText: "Edit Profile",
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getInt('userid') ?? 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditForm(applicationId: userId),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildCard(
                  title: "Interests",
                  subtitle: "Manage institutions interested in your profile",
                  description:
                      "You currently have no interest requests from institutions.",
                  buttonText: "View Interests",
                  onPressed: () {},
                  enabled: false,
                ),
                const SizedBox(width: 12),
              ],
            ),
            _buildCompleteProfileSection(context),
          ],
        ),
      ),
    );
  }
}
