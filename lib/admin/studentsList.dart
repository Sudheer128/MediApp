import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:medicalapp/admin/collegeStudentsform.dart';
import 'package:medicalapp/college/college_student_form.dart';
import 'package:medicalapp/url.dart';

class AdminCourseDetailsScreen extends StatefulWidget {
  final String degree;
  final String courseName;
  final int status;

  const AdminCourseDetailsScreen({
    Key? key,
    required this.degree,
    required this.courseName,
    required this.status,
  }) : super(key: key);

  @override
  State<AdminCourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<AdminCourseDetailsScreen> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final url = Uri.parse('$baseurl/students-by-course').replace(
      queryParameters: {
        'degree': widget.degree,
        'course': widget.courseName == 'MBBS' ? ' ' : widget.courseName,
        'status': widget.status.toString(),
      },
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(resp.body);
        setState(() {
          students = jsonResponse;
          filteredStudents = students;
          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          error = 'Failed to load students: ${resp.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching students: $e';
        isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      searchQuery = query;
      filteredStudents =
          students
              .where(
                (s) => (s['name'] as String).toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  Widget buildStudentCard(BuildContext context, Map<String, dynamic> student) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final applicationId = student['application'];
        final studentName = student['name'] ?? '';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => AdminStudentDetailScreen(
                  applicationId: applicationId,
                  StudentName: studentName,
                  courseName: widget.courseName,
                  degree: widget.degree,
                ),
          ),
        );
      },
      child: StudentCard(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseName} Details'),
        backgroundColor: Colors.blue.shade700,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : Column(
                children: [
                  // --- Search Bar ---
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: _filterStudents,
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  // --- Filtered List / Grid ---
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;

                        if (kIsWeb || isWide) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children:
                                    filteredStudents.map((s) {
                                      return SizedBox(
                                        width: 450,
                                        child: buildStudentCard(context, s),
                                      );
                                    }).toList(),
                              ),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredStudents.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: buildStudentCard(
                                  context,
                                  filteredStudents[i],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

class StudentCard extends StatefulWidget {
  final Map<String, dynamic> student;
  const StudentCard({Key? key, required this.student}) : super(key: key);

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = (widget.student['status'] ?? 0) == 1;
  }

  Future<void> _toggleVisibility(bool newValue) async {
    setState(() => _isVisible = newValue);

    final statusInt = newValue ? 1 : 0;
    // build URI with query parameters
    final uri = Uri.parse('$baseurl/userstatus').replace(
      queryParameters: {
        'user_id': widget.student['application'].toString(),
        'status': statusInt.toString(),
      },
    );

    try {
      final resp = await http.get(uri);
      print('GET $uri');
      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }
    } catch (e) {
      // roll back toggle on error
      setState(() => _isVisible = !newValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update visibility: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hd = widget.student['highest_degree'] ?? {};
    final le = widget.student['latest_experience'] ?? {};

    final degree = hd['degree'] ?? '-';
    final ds = hd['start_date'] ?? '-';
    final de = hd['end_date'] ?? '-';

    final hospital = le['hospital_name'] ?? '-';
    final ef = le['from_date'] ?? '-';
    final et = le['to_date'] ?? '-';
    final role = le['role'] ?? '';
    final expText = role.isEmpty ? 'No experience' : '$hospital ($ef to $et)';

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.blue.shade100,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              'Student Name: ${widget.student['name']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
                shadows: [
                  Shadow(
                    color: Colors.blue.shade200,
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Highest Degree
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17, color: Colors.blue.shade800),
                children: [
                  const TextSpan(
                    text: 'Highest Degree: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$degree ($ds to $de)'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Experience
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 17, color: Colors.blue.shade800),
                children: [
                  const TextSpan(
                    text: 'Experience: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: expText),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Visibility Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Visibility',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Switch(value: _isVisible, onChanged: _toggleVisibility),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
