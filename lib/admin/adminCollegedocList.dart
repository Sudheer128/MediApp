import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/studentsList.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminCollegeDegreesScreen extends StatefulWidget {
  const AdminCollegeDegreesScreen({super.key});

  @override
  _AdminDegreesScreenState createState() => _AdminDegreesScreenState();
}

class _AdminDegreesScreenState extends State<AdminCollegeDegreesScreen> {
  late Future<List<dynamic>> degreesFuture;

  String searchQuery = '';
  int _selectedStatus = 1; // 1 = Active, 0 = Inactive

  @override
  void initState() {
    super.initState();
    degreesFuture = fetchDegrees();
  }

  Future<List<dynamic>> fetchDegrees() async {
    final uri = Uri.parse(
      '$baseurl/degree-course-counts',
    ).replace(queryParameters: {'status': _selectedStatus.toString()});

    final response = await http.get(uri);

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
              (degree['courses'] as List<dynamic>)
                  .where(
                    (course) => (course['course_name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()),
                  )
                  .toList();

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
      appBar: AppBar(title: Text("Degrees & Courses"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: Colors.blue, size: 20),
                      SizedBox(width: 6),
                      Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSearchAndFilterBar(),

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
                        valueColor: AlwaysStoppedAnimation(Color(0xFF0A66C2)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorUI(snapshot.error);
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyUI();
                  }

                  final filteredData = filterCourses(snapshot.data!);

                  if (filteredData.isEmpty) {
                    return _buildEmptySearchUI();
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

  // ------------------------------------------------------------------------------------------------
  //  SEARCH + STATUS DROPDOWN
  // ------------------------------------------------------------------------------------------------
  Widget _buildSearchAndFilterBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          /// Search box
          Expanded(
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
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          /// Active/Inactive dropdown
          DropdownButton<int>(
            value: _selectedStatus,
            underline: SizedBox(),
            items: const [
              DropdownMenuItem(value: 1, child: Text("Active")),
              DropdownMenuItem(value: 0, child: Text("Inactive")),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedStatus = value;
                degreesFuture = fetchDegrees();
              });
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------------------------------
  // EMPTY STATES / ERROR STATES
  // ------------------------------------------------------------------------------------------------
  Widget _buildErrorUI(error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "Error loading data",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text("$error", style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildEmptyUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No degrees available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchUI() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No courses found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------------------------------
  // MAIN CONTENT (same as CollegeDegreesScreen)
  // ------------------------------------------------------------------------------------------------
  Widget _buildContent(List<dynamic> data, bool isWeb) {
    final content = ListView(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 16, vertical: 20),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Available Doctors",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        ...data.map((degreeData) {
          final degree = degreeData['degree'];
          final courses = degreeData['courses'] as List<dynamic>;

          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildDegreeCard(degree, courses),
          );
        }),
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

  // -----------------------------------------------------------------------------------------------
  // DEGREE CARD (same as College UI)
  // -----------------------------------------------------------------------------------------------
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
          Divider(),
          SizedBox(height: 16),

          if (courses.isEmpty)
            Center(
              child: Text(
                "No courses for $degree",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  courses.map<Widget>((course) {
                    final courseName = (course['course_name'] ?? "").trim();
                    final studentCount = course['student_count'] ?? 0;

                    return _buildCourseCard(degree, courseName, studentCount);
                  }).toList(),
            ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------------------------------
  // COURSE CARD (same as college UI)
  // -----------------------------------------------------------------------------------------------
  Widget _buildCourseCard(String degree, String courseName, int studentCount) {
    return InkWell(
      onTap: () {
        context.go(
          '/course-details/'
          '${Uri.encodeComponent(degree)}/'
          '${Uri.encodeComponent(courseName)}/'
          '$_selectedStatus',
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
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE7F3FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.menu_book, size: 20, color: Color(0xFF0A66C2)),
            ),
            SizedBox(height: 12),

            Text(
              courseName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),

            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.people_outline, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "$studentCount Persons",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "View details",
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
