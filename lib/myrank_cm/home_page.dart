import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/college/college_profile.dart';
import 'package:medicalapp/extranew/alljobs.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
import 'package:medicalapp/myrank_cm/CmusersTable.dart';
import 'package:medicalapp/myrank_cm/cmCollegeDocList.dart';
import 'package:medicalapp/myrank_cm/cmForm.dart';
import 'package:medicalapp/myrank_cm/cm_profile.dart';
import 'package:medicalapp/myrank_cm/collegeInterests.dart';
import 'package:medicalapp/myrank_cm/search.dart';
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
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => Index()),
    //   (Route<dynamic> route) => false, // Remove all previous routes
    // );
    context.go('/login');
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
      //                   'MyRank CM',
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 28,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 const SizedBox(height: 8),
      //                 Text(
      //                   'Welcome, $userName',
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
      //                 MaterialPageRoute(builder: (context) => CmHomePage()),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(
      //               Icons.manage_accounts_outlined,
      //               color: primaryBlue,
      //             ),
      //             title: const Text('Manage Users'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => CmManagementPage(),
      //                 ),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.group, color: primaryBlue),
      //             title: const Text('College Interests'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => CmInterestsPage(),
      //                 ),
      //               );
      //             },
      //           ),
      //           ListTile(
      //             leading: Icon(Icons.person, color: primaryBlue),
      //             title: const Text('Search Students'),
      //             onTap: () {
      //               Navigator.pop(context);
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => CmSearchPage()),
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
      //                   builder: (context) => CmApplicationForm(),
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
      //                   builder: (context) => CmCollegeDegreesScreen(),
      //                 ),
      //               );
      //             },
      //           ),
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => AdminApplicationForm(),
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
                      //   MaterialPageRoute(builder: (context) => CmSearchPage()),
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
                    title: 'Manage Users',
                    icon: Icons.manage_accounts_outlined,
                    subtitle: 'Manage users assigned to you',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => CmManagementPage(),
                      //   ),
                      // );
                      if (kIsWeb) {
                        context.go('/cm_manageusers');
                      } else {
                        context.push('/cm_manageusers');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    context,
                    title: 'College Interests',
                    icon: Icons.group,
                    subtitle: 'Colleges that are interested in doctors',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => CmInterestsPage(),
                      //   ),
                      // );
                      if (kIsWeb) {
                        context.go('/cm_collegeinterspage');
                      } else {
                        context.push('/cm_collegeinterspage');
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
                      //     builder: (context) => CmCollegeDegreesScreen(),
                      //   ),
                      // );
                      if (kIsWeb) {
                        context.go('/cm_collegedegreescreen');
                      } else {
                        context.push('/cm_collegedegreescreen');
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

class MyRankCMHomePage extends StatelessWidget {
  const MyRankCMHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "CM Dashboard",

      pages: [
        CmHomePage(),
        AllJobsPage(),
        // AdminCollegeDegreesScreen(), // Page 2
        // // CollegeDegreesScreen(), // Page 1
        // // AdminHomePage(),
        // // StudentListPage(),          // Page 3
        CmCollegeDegreesScreen(),
        CMHospitalProfilePage(), // Page 4 (optional)
      ],
    );
  }
}
