import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/college/college_profile.dart';
import 'package:medicalapp/college/collegeintrests.dart';
import 'package:medicalapp/college/studentList.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
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

  @override
  void initState() {
    super.initState();
    degreesFuture = fetchDegrees();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => degreesFuture = fetchDegrees());
        await degreesFuture;
      },
      child: FutureBuilder<List<dynamic>>(
        future: degreesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
                color: Colors.deepPurple.shade600,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No data available",
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
                      /// Degree Title
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

                      /// If no courses
                      if (courses.isEmpty)
                        Text(
                          "No Data available for $degree Degree",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
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
                                    padding: EdgeInsets.all(14),
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
                                              "$studentCount students",
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
    );
  }
}

class CollegeDashboard extends StatelessWidget {
  const CollegeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "College Dashboard",

      pages: [
        CollegeDegreesScreen(), // Page 1
        CollegeInterestsPage(), // Page 2
        CollegeDegreesScreen(), // Page 1
        HospitalProfilePage(),
        // StudentListPage(),          // Page 3
        // CollegeProfilePage(),       // Page 4 (optional)
      ],
    );
  }
}
