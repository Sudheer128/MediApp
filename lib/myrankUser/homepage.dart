import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicalapp/college/collegeintrests.dart';
import 'package:medicalapp/extranew/alljobs.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
              ), // Set max width for the content
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UserApplicationForm(),
                      //   ),
                      // );
                      if (kIsWeb) {
                        context.go('/create-student-form');
                      } else {
                        context.push('/create-student-form');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    context,
                    title: 'Search and Find Student Details',
                    icon: Icons.search,
                    subtitle: 'Locate student information',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => UserSearchPage()),
                      // );
                      if (kIsWeb) {
                        context.go('/search-doctors');
                      } else {
                        context.push('/search-doctors');
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildCard(
                    context,
                    title: 'Available Doctors',
                    icon: Icons.medical_services_outlined,
                    subtitle: 'List of Doctors in Particular Courses',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UserCollegeDegreesScreen(),
                      //   ),
                      // );
                      if (kIsWeb) {
                        context.go('/available-doctors');
                      } else {
                        context.push('/available-doctors');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    context,
                    title: 'Manage Users',
                    icon: Icons.medical_services_outlined,
                    subtitle: 'Manage registered users',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UserCollegeDegreesScreen(),
                      //   ),
                      // );
                      if (kIsWeb) {
                        context.go('/user_manageusers');
                      } else {
                        context.push('/user_manageusers');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserMainPage extends StatelessWidget {
  const UserMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "MyRank User Dashboard",

      pages: [
        UserHomePage(),
        AllJobsPage(),
        CollegeInterestsPage(),
        AllJobsPage(),

        // CollegeDegreesScreen(), // Page 1
        // AllJobsPage(),
        // CollegeInterestsPage(), // Page 2
        // HospitalProfilePage(),
      ],
    );
  }
}
