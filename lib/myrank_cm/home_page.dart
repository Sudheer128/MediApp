import 'package:flutter/material.dart';
import 'package:medicalapp/myrank_cm/CmusersTable.dart';
import 'package:medicalapp/myrank_cm/cmCollegeDocList.dart';
import 'package:medicalapp/myrank_cm/cmForm.dart';
import 'package:medicalapp/myrank_cm/collegeInterests.dart';
import 'package:shared_preferences/shared_preferences.dart'; // add this import
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';

class CmHomePage extends StatefulWidget {
  const CmHomePage({super.key});

  static const Color primaryBlue = Color.fromARGB(255, 250, 110, 110);

  @override
  State<CmHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<CmHomePage> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('name') ?? 'Admin'; // key matches here
    setState(() {
      userName = savedName;
    });
  }

  void _logout(BuildContext context) {
    signOutGoogle();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Index()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: CmHomePage.primaryBlue.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: CmHomePage.primaryBlue.withOpacity(0.15),
                child: Icon(icon, size: 32, color: CmHomePage.primaryBlue),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color.fromARGB(255, 250, 110, 110);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: primaryBlue),
                  child: const Center(
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home_filled, color: primaryBlue),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CmHomePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.school, color: primaryBlue),
                  title: const Text('Manage Users'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CmManagementPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.school, color: primaryBlue),
                  title: const Text('College Interests'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CmInterestsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.format_align_left_sharp,
                    color: primaryBlue,
                  ),
                  title: const Text('New Student Form'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CmApplicationForm(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_pin_sharp, color: primaryBlue),
                  title: const Text('Available Doctors'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CmCollegeDegreesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    _logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildCard(
                context,
                title: 'Create New Student Form',
                icon: Icons.analytics,
                subtitle: 'Add new student application',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CmApplicationForm(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              _buildCard(
                context,
                title: 'Available Doctors',
                icon: Icons.medical_services_outlined,
                subtitle: 'List of Doctors in Particular Courses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CmCollegeDegreesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
