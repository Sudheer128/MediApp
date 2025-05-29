import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/adminintreststatus.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/admin/studentsList.dart';
import 'package:medicalapp/admin/userstable.dart';
import 'package:medicalapp/college/collegeintrests.dart';
import 'package:medicalapp/college/studentList.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/url.dart';

class AdminCollegeDegreesScreen extends StatefulWidget {
  const AdminCollegeDegreesScreen({super.key});

  @override
  _DegreesScreenState createState() => _DegreesScreenState();
}

class _DegreesScreenState extends State<AdminCollegeDegreesScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> degreesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  static const Color primaryBlue = Color(0xFF007FFF);

  // Track selected status: 1 = Active, 0 = Inactive
  int _selectedStatus = 1;

  @override
  void initState() {
    super.initState();
    degreesFuture = fetchDegrees(status: _selectedStatus);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchDegrees({required int status}) async {
    final uri = Uri.parse(
      '$baseurl/degree-course-counts',
    ).replace(queryParameters: {'status': status.toString()});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      _animationController.forward();
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load degrees');
    }
  }

  void _logout(BuildContext context) {
    signOutGoogle();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Index()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 4,
        centerTitle: true,
        title: Text(
          'Degrees & Courses',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            fontSize: 22,
          ),
        ),
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
                      MaterialPageRoute(builder: (context) => AdminHomePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.group, color: primaryBlue),
                  title: const Text('Manage Users'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserManagementPage(),
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
                      MaterialPageRoute(builder: (context) => InterestsPage()),
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
                        builder: (context) => AdminApplicationForm(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: primaryBlue),
                  title: const Text('Search Student'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminEditForm()),
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
                        builder: (context) => AdminCollegeDegreesScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24), // or whatever spacing you want
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
      body: Column(
        children: [
          // Dropdown at top-right of page
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Align(
              alignment: Alignment.topRight,
              child: DropdownButton<int>(
                value: _selectedStatus,
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: primaryBlue),
                items: [
                  DropdownMenuItem(child: Text('Active'), value: 1),
                  DropdownMenuItem(child: Text('Inactive'), value: 0),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedStatus = value;
                    degreesFuture = fetchDegrees(status: _selectedStatus);
                  });
                },
              ),
            ),
          ),

          // The list (or loader / error / empty state)
          Expanded(
            child: RefreshIndicator(
              color: primaryBlue,
              onRefresh: () async {
                // Trigger a refresh by updating the future
                setState(() {
                  degreesFuture = fetchDegrees(status: _selectedStatus);
                });

                // Wait for the new data to load
                await degreesFuture;
              },
              child: FutureBuilder<List<dynamic>>(
                future: degreesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 4.2,
                          color: primaryBlue,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return FadeTransition(
                    opacity: _fadeInAnimation,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final degree = data[index]['degree'];
                        final courses = data[index]['courses'] as List<dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Degree heading with underline accent
                              Container(
                                padding: EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: primaryBlue.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  degree,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005BBB),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),

                              if (courses.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    "No Data available for $degree Degree",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children:
                                      courses.map<Widget>((course) {
                                        final courseName =
                                            (course['course_name'] ?? '')
                                                .trim();
                                        final studentCount =
                                            course['student_count'] ?? 0;

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        AdminCourseDetailsScreen(
                                                          degree: degree,
                                                          courseName:
                                                              courseName,
                                                          status:
                                                              _selectedStatus,
                                                        ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            constraints: BoxConstraints(
                                              minWidth: 120,
                                              maxWidth: 180,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  primaryBlue.withOpacity(0.7),
                                                  primaryBlue,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryBlue
                                                      .withOpacity(0.4),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  courseName,
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.people,
                                                      size: 18,
                                                      color: Colors.white70,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      '$studentCount students',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
