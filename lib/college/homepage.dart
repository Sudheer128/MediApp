import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/college/college_profile.dart';
import 'package:medicalapp/college/collegeintrests.dart';
import 'package:medicalapp/college/studentList.dart';
import 'package:medicalapp/extranew/alljobs.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeDegreesScreen extends StatefulWidget {
  @override
  _DegreesScreenState createState() => _DegreesScreenState();
}

class _DegreesScreenState extends State<CollegeDegreesScreen> {
  late Future<List<dynamic>> degreesFuture;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    degreesFuture = fetchDegrees();
  }

  Future<List<dynamic>> fetchDegrees() async {
    final response = await http.get(
      Uri.parse('$baseurl/degree-course-counts?status=1'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load degrees');
    }
  }

  List<dynamic> filterCourses(List<dynamic> data) {
    if (searchQuery.isEmpty) return data;

    return data
        .map((degree) {
          final courses =
              (degree['courses'] as List<dynamic>).where((course) {
                final courseName =
                    (course['course_name'] ?? '').toString().toLowerCase();
                return courseName.contains(searchQuery.toLowerCase());
              }).toList();

          return {'degree': degree['degree'], 'courses': courses};
        })
        .where((degree) => (degree['courses'] as List).isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Color(0xFFF3F2EF),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0A66C2),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Error loading data",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${snapshot.error}",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No degrees available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredData = filterCourses(snapshot.data!);

                  if (filteredData.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No courses found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Try a different search term",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildContent(filteredData, isWeb);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Color(0xFFEEF3F8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search courses',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<dynamic> data, bool isWeb) {
    Widget content = ListView(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 16, vertical: 16),
      children: [
        // ⭐ NEW HEADING ADDED HERE ⭐
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            "Available Doctors",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // Build all degrees + courses
        ...data.map((degreeData) {
          final degree = degreeData['degree'];
          final courses = degreeData['courses'] as List<dynamic>;
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildDegreeCard(degree, courses),
          );
        }).toList(),
      ],
    );

    if (isWeb) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1128),
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildDegreeCard(String degree, List<dynamic> courses) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Degree title
          Row(
            children: [
              Icon(Icons.school, color: Color(0xFF0A66C2), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  degree,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade300),
          SizedBox(height: 16),

          // Courses
          if (courses.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No courses available for $degree",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  courses.map<Widget>((course) {
                    final courseName = (course['course_name'] ?? '').trim();
                    final studentCount = course['student_count'] ?? 0;

                    return _buildCourseCard(degree, courseName, studentCount);
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String degree, String courseName, int studentCount) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CourseDetailsScreen(degree: degree, courseName: courseName),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(minWidth: 140, maxWidth: 200),
        decoration: BoxDecoration(
          color: Color(0xFFF3F2EF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE7F3FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 20,
                    color: Color(0xFF0A66C2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              courseName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "$studentCount student${studentCount != 1 ? 's' : ''}",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0A66C2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: Color(0xFF0A66C2)),
              ],
            ),
          ],
        ),
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
        AllJobsPage(),
        // CollegeInterestsPage(), // Page 2
        CollegeDegreesScreen(), // Page 1
        HospitalProfilePage(),
        // StudentListPage(),          // Page 3
        // CollegeProfilePage(),       // Page 4 (optional)
      ],
    );
  }
}
