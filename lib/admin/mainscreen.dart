import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medicalapp/admin/adminCollegedocList.dart';
import 'package:medicalapp/admin/adminintreststatus.dart';
import 'package:medicalapp/admin/adminloginlogs.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/admin/search.dart';
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/admin/userstable.dart';
import 'package:medicalapp/college/college_profile.dart';
import 'package:medicalapp/college/collegeintrests.dart';
import 'package:medicalapp/extranew/alljobs.dart';
import 'package:medicalapp/extranew/jobdetails.dart';
import 'package:medicalapp/extranew/jobnotification.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
import 'package:medicalapp/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const Color primaryBlue = Color(0xFF007FFF);

  String _username = "Admin";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('name') ?? "Admin";
    });
  }

  void _logout(BuildContext context) async {
    await signOutGoogle();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Index()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> signOutGoogle() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    print('User signed out');
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
        splashColor: primaryBlue.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryBlue.withOpacity(0.15),
                child: Icon(icon, size: 32, color: primaryBlue),
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
      // appBar: AppBar(
      //   backgroundColor: primaryBlue,
      //   title: const Text('Admin Dashboard'),
      //   automaticallyImplyLeading: true,
      // ),
      // drawer: Drawer(
      //   child: SafeArea(
      //     child: SingleChildScrollView(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.stretch,
      //         children: [
      //           DrawerHeader(
      //             decoration: const BoxDecoration(color: primaryBlue),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 const Text(
      //                   'Admin Menu',
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 28,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 const SizedBox(height: 8),
      //                 Text(
      //                   'Welcome, $_username',
      //                   style: const TextStyle(
      //                     color: Colors.white70,
      //                     fontSize: 18,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.home_filled, color: primaryBlue),
      //             title: const Text('Home'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => AdminHomePage()),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.group, color: primaryBlue),
      //             title: const Text('Manage Users'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => UserManagementPage(),
      //                 ),
      //               );
      //             },
      //           ),

      //           ListTile(
      //             leading: Icon(Icons.school, color: primaryBlue),
      //             title: const Text('College Interests'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => InterestsPage()),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.school, color: primaryBlue),
      //             title: const Text('Search Student'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => SearchPage()),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(
      //               Icons.format_align_left_sharp,
      //               color: primaryBlue,
      //             ),
      //             title: const Text('New Student Form'),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => AdminApplicationForm(),
      //                 ),
      //               );
      //             },
      //           ),

      //           ListTile(
      //             leading: Icon(Icons.person_pin_sharp, color: primaryBlue),
      //             title: const Text('Available Doctors'),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => AdminCollegeDegreesScreen(),
      //                 ),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.track_changes, color: primaryBlue),
      //             title: const Text('Login Tracks'),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => LoginLogsPage()),
      //               );
      //             },
      //           ),
      //           SizedBox(height: 24), // or whatever spacing you want
      //           const Divider(),
      //           ListTile(
      //             leading: const Icon(Icons.logout, color: Colors.red),
      //             title: const Text(
      //               'Logout',
      //               style: TextStyle(color: Colors.red),
      //             ),
      //             onTap: () {
      //               _logout(context);
      //             },
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720, // You can adjust the width: 600–900 is ideal
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    context,
                    title: 'Create New Student Form',
                    icon: Icons.analytics,
                    subtitle: 'Add new student application',
                    onTap: () {
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
                      if (kIsWeb) {
                        context.go('/available-doctors');
                      } else {
                        context.push('/available-doctors');
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildCard(
                    context,
                    title: 'Add New Job Notification',
                    icon: Icons.analytics,
                    subtitle: 'Add here',
                    onTap: () {
                      if (kIsWeb) {
                        context.go('/add_job');
                      } else {
                        context.push('/add_job');
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                  _buildCard(
                    context,
                    title: 'User Management',
                    icon: Icons.analytics,
                    subtitle: 'Manage useres',
                    onTap: () {
                      if (kIsWeb) {
                        context.go('/manage_users');
                      } else {
                        context.push('/manage_users');
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                  _buildCard(
                    context,
                    title: 'College Interests',
                    icon: Icons.analytics,
                    subtitle: 'College Interests',
                    onTap: () {
                      if (kIsWeb) {
                        context.go('/college_interests');
                      } else {
                        context.push('/college_interests');
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildCard(
                    context,
                    title: 'Manage Login Tracks',
                    icon: Icons.analytics,
                    subtitle: 'Manage logins',
                    onTap: () {
                      if (kIsWeb) {
                        context.go('/login-tracks');
                      } else {
                        context.push('/login-tracks');
                      }
                    },
                  ),
                  //               const SizedBox(height: 30),
                  // _buildCard(
                  //   context,
                  //   title: 'User Management',
                  //   icon: Icons.analytics,
                  //   subtitle: 'Manage useres',
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => InterestsPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Admin Dashboard",

      pages: [
        AdminHomePage(), // Page 1
        AllJobsPage(),
        AdminCollegeDegreesScreen(), // Page 2
        // CollegeDegreesScreen(), // Page 1
        // AdminHomePage(),
        // StudentListPage(),          // Page 3
        HospitalProfilePage(), // Page 4 (optional)
      ],
    );
  }
}
