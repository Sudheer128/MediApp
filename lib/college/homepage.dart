import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/college/collegeintrests.dart';
import 'package:medicalapp/college/studentList.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeDegreesScreen extends StatefulWidget {
  @override
  _DegreesScreenState createState() => _DegreesScreenState();
}

class _DegreesScreenState extends State<CollegeDegreesScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> degreesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  late Future<Map<String, String>> _userProfileFuture;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    degreesFuture = fetchDegrees();
    _userProfileFuture = _loadUserProfile();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  Future<Map<String, String>> _loadUserProfile() async {
    _prefs = await SharedPreferences.getInstance();
    return {
      'name': _prefs.getString('name') ?? 'Admin',
      'email': _prefs.getString('email') ?? '',
      'photourl': _prefs.getString('photourl') ?? '',
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchDegrees() async {
    final response = await http.get(
      Uri.parse('$baseurl/degree-course-counts?status=1'),
    );

    if (response.statusCode == 200) {
      _animationController.forward();
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load degrees');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple.shade50,
          child: Column(
            children: [
              FutureBuilder<Map<String, String>>(
                future: _userProfileFuture,
                builder: (context, snapshot) {
                  final name = snapshot.data?['name'] ?? 'Admin';
                  final email = snapshot.data?['email'] ?? '';
                  final photoUrl = snapshot.data?['photourl'] ?? '';

                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade700,
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade800,
                          Colors.deepPurple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    accountName: Text(
                      'Welcome, ${name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail:
                        email.isNotEmpty
                            ? Text(email, style: TextStyle(fontSize: 14))
                            : null,
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child:
                          photoUrl.isEmpty
                              ? Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.deepPurple.shade700,
                              )
                              : null,
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.home,
                        color: Colors.deepPurple.shade700,
                      ),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.deepPurple.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollegeDegreesScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.deepPurple.shade700,
                      ),
                      title: Text(
                        'Interests Sent',
                        style: TextStyle(
                          color: Colors.deepPurple.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollegeInterestsPage(),
                          ),
                        );
                      },
                    ),

                    // You can add more menu items here...
                  ],
                ),
              ),
              // Logout button at the bottom
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.deepPurple.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.deepPurple.shade700,
                  ),
                  title: Text(
                    'LogOut',
                    style: TextStyle(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    signOutGoogle();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => Index(),
                      ),
                      (Route<dynamic> route) =>
                          false, // Remove all previous routes
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Degrees & Courses',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            degreesFuture = fetchDegrees(); // Trigger a reload of the degrees
          });
          await degreesFuture; // Ensure the fetch completes
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
                    color: Colors.deepPurple.shade600,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              );
            }

            final data = snapshot.data!;
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final degree = data[index]['degree'];
                  final courses = data[index]['courses'] as List<dynamic>;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Degree heading with underline accent
                        Container(
                          padding: EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.deepPurple.shade300,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            degree,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade800,
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
                                      (course['course_name'] ?? '').trim();
                                  final studentCount =
                                      course['student_count'] ?? 0;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CourseDetailsScreen(
                                                degree: degree,
                                                courseName: courseName,
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
                                            Colors.deepPurple.shade400,
                                            Colors.deepPurple.shade700,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.deepPurple.shade200
                                                .withOpacity(0.6),
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
                                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
