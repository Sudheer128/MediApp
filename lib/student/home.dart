import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/edit_formAfterSave.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/student/form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardApp extends StatelessWidget {
  const DoctorDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(8),
        ),
      ),
      home: const DoctorDashboard(),
    );
  }
}

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  bool _isActive = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('name') ?? "Doctor";
    });
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isActive = prefs.getBool('isActive') ?? false;
    });
  }

  Future<void> _updateStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    final statusValue = isActive ? 1 : 0;
    final uri = Uri.parse('http://192.168.0.103:8080/status');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': statusValue, 'userid': userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isActive = isActive;
        });
        await prefs.setBool('isActive', isActive);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status updated: ${isActive ? "Active" : "Inactive"}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    Color iconColor = Colors.blue,
    bool enabled = true,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enabled ? onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled ? iconColor : Colors.grey.shade300,
                  foregroundColor: enabled ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteProfileSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Complete Your Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "A complete profile helps you stand out to potential employers. Make sure to include:",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                children: [
                  _buildProfileItem("Educational background"),
                  _buildProfileItem("Professional experience"),
                  _buildProfileItem("Specialties and skills"),
                  _buildProfileItem("Certifications and credentials"),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ApplicationForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text("Create Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ),
              ),
              padding: EdgeInsets.only(top: 40, left: 16, bottom: 16),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Doctor Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _username != null
                        ? 'Hello, $_username'
                        : 'Doctor Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.blue),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDashboardApp(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.blue),
                    title: Text('Profile'),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('userid') ?? 0;
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditForm(applicationId: userId),
                        ),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: Text('Active Status'),
                    value: _isActive,
                    onChanged: (bool value) {
                      _updateStatus(value);
                    },
                    secondary: Icon(
                      Icons.toggle_on,
                      color: _isActive ? Colors.green : Colors.grey,
                    ),
                    activeColor: Colors.green,
                  ),
                  Divider(height: 1, thickness: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.blue),
                    title: Text('Log Out'),
                    onTap: () {
                      signOutGoogle();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => Index(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Doctor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Your professional dashboard",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              icon: Icons.person_outline,
              title: "Your Profile",
              subtitle:
                  "Complete and manage your professional profile to increase visibility to medical institutions.",
              buttonText: "Edit Profile",
              iconColor: Colors.blue,
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
            SizedBox(height: 16),
            _buildCompleteProfileSection(context),
          ],
        ),
      ),
    );
  }
}
