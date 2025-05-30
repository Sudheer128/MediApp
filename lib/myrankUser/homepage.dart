import 'package:flutter/material.dart';
import 'package:medicalapp/myrankUser/UserCollegeDocList.dart';
import 'package:medicalapp/myrankUser/UsersTable.dart';
import 'package:medicalapp/myrankUser/search.dart';
import 'package:shared_preferences/shared_preferences.dart'; // add this import
import 'package:medicalapp/admin/adminintreststatus.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/admin/userstable.dart';

import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/myrankUser/userSearchStudent.dart';
import 'package:medicalapp/myrankUser/useredit_form.dart';
import 'package:medicalapp/myrankUser/userform_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  static const Color primaryBlue = Color(0xFF00897B);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('name') ?? "Doctor";
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
        splashColor: UserHomePage.primaryBlue.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: UserHomePage.primaryBlue.withOpacity(0.15),
                child: Icon(icon, size: 32, color: UserHomePage.primaryBlue),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UserHomePage.primaryBlue,
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  UserHomePage.primaryBlue,
                                  UserHomePage.primaryBlue,
                                ],
                              ),
                            ),
                            padding: EdgeInsets.only(
                              top: 40,
                              left: 16,
                              bottom: 16,
                            ),
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 2),
                                Text(
                                  'Admin User',
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
                          ListTile(
                            leading: Icon(
                              Icons.home_filled,
                              color: UserHomePage.primaryBlue,
                            ),
                            title: const Text('Home'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserHomePage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.manage_accounts_outlined,
                              color: UserHomePage.primaryBlue,
                            ),
                            title: const Text('Manage Users'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManagementPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.group,
                              color: UserHomePage.primaryBlue,
                            ),
                            title: const Text('College Interests'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InterestsPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.format_align_left_sharp,
                              color: UserHomePage.primaryBlue,
                            ),
                            title: const Text('New Student Form'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserApplicationForm(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: UserHomePage.primaryBlue,
                            ),
                            title: const Text('Search Student'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserSearchPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.person_pin_sharp,
                              color: UserHomePage.primaryBlue,
                            ),
                            title: const Text('Available Doctors'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => UserCollegeDegreesScreen(),
                                ),
                              );
                            },
                          ),
                          // Add some space at bottom so Logout is separated on small screens
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _logout(context);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCard(
                context,
                title: 'Create New Student Form',
                icon: Icons.analytics,
                subtitle: 'Add new student application',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserApplicationForm(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildCard(
                context,
                title: 'Search and Find Student Details',
                icon: Icons.search,
                subtitle: 'Locate student information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSearchPage()),
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
                      builder: (context) => UserCollegeDegreesScreen(),
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
