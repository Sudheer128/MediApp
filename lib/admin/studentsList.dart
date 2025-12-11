import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        'course': widget.courseName == 'MBBS' ? 'MBBS' : widget.courseName,
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
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final applicationId = student['application'];
        final studentName = student['name'] ?? '';

        if (kIsWeb) {
          context.go(
            '/student-details/'
            '${applicationId.toString()}/'
            '${Uri.encodeComponent(studentName)}/'
            '${Uri.encodeComponent(widget.degree)}/'
            '${Uri.encodeComponent(widget.courseName)}',
          );
        } else {
          context.push(
            '/student-details/'
            '${applicationId.toString()}/'
            '${Uri.encodeComponent(studentName)}/'
            '${Uri.encodeComponent(widget.degree)}/'
            '${Uri.encodeComponent(widget.courseName)}',
          );
        }
      },
      child: StudentCard(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0A66C2)),
        title: Text(
          '${widget.courseName} Students',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body:
          isLoading
              ? _buildShimmerLoading()
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(error!, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              )
              : Column(
                children: [
                  // Search Bar
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: _filterStudents,
                      decoration: InputDecoration(
                        hintText: 'Search students by name...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEEF3F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Results count
                  if (filteredStudents.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        '${filteredStudents.length} ${filteredStudents.length == 1 ? 'student' : 'students'} found',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Student List/Grid
                  Expanded(
                    child:
                        filteredStudents.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No students found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 600;

                                if (kIsWeb || isWide) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children:
                                            filteredStudents.map((s) {
                                              return SizedBox(
                                                width: 380,
                                                child: buildStudentCard(
                                                  context,
                                                  s,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: filteredStudents.length,
                                    itemBuilder: (ctx, i) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
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

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Search bar shimmer
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: _ShimmerBox(
            height: 48,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildShimmerCard(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _ShimmerBox(
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.circular(36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(height: 16, width: 150),
                      const SizedBox(height: 8),
                      _ShimmerBox(height: 14, width: 120),
                      const SizedBox(height: 6),
                      _ShimmerBox(height: 14, width: 100),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ShimmerBox(height: 12, width: double.infinity),
            const SizedBox(height: 8),
            _ShimmerBox(height: 12, width: double.infinity),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const _ShimmerBox({this.width, required this.height, this.borderRadius});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops:
                  [
                    _animation.value - 0.3,
                    _animation.value,
                    _animation.value + 0.3,
                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
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
    final uri = Uri.parse('$baseurl/userstatus').replace(
      queryParameters: {
        'user_id': widget.student['application'].toString(),
        'status': statusInt.toString(),
      },
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => _isVisible = !newValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update visibility: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hd = widget.student['highest_degree'] ?? {};
    final le = widget.student['latest_experience'] ?? {};

    final name = widget.student['name'] ?? 'Unknown';
    final degree = hd['degree'] ?? '-';
    final degreeStart = hd['start_date'] ?? '';
    final degreeEnd = hd['end_date'] ?? '';

    final hospital = le['hospital_name'] ?? '';
    final expFrom = le['from_date'] ?? '';
    final expTo = le['to_date'] ?? '';
    final role = le['role'] ?? '';

    // You can add these fields to your backend later
    final email = widget.student['email'] ?? 'email@example.com';
    final phone = widget.student['phone'] ?? '+91 XXXXXXXXXX';
    final location = widget.student['location'] ?? 'Location';
    final profileImage = widget.student['profile_image']; // null for now

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A66C2),
                        const Color(0xFF0A66C2).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child:
                      profileImage != null
                          ? ClipOval(
                            child: Image.network(
                              profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    _getInitials(name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          : Center(
                            child: Text(
                              _getInitials(name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                ),
                const SizedBox(width: 16),

                // Name and Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        degree != '-' ? degree : 'Medical Student',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 16),

            // Education Section
            _buildSection(
              icon: Icons.school,
              title: 'Education',
              content:
                  degree != '-'
                      ? '$degree${degreeStart.isNotEmpty && degreeEnd.isNotEmpty ? '\n$degreeStart - $degreeEnd' : ''}'
                      : 'No education details available',
            ),

            const SizedBox(height: 16),

            // Experience Section
            _buildSection(
              icon: Icons.work_outline,
              title: 'Experience',
              content:
                  role.isNotEmpty && hospital.isNotEmpty
                      ? '$role at $hospital${expFrom.isNotEmpty && expTo.isNotEmpty ? '\n$expFrom - $expTo' : ''}'
                      : 'No experience listed',
            ),

            const SizedBox(height: 16),

            // Contact Info Section
            // _buildSection(
            //   icon: Icons.contact_mail_outlined,
            //   title: 'Contact',
            //   content: '$email\n$phone',
            // ),

            // const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 12),

            // Visibility Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isVisible ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isVisible ? 'Profile Visible' : 'Profile Hidden',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isVisible,
                  onChanged: _toggleVisibility,
                  activeColor: const Color(0xFF0A66C2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0A66C2)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
