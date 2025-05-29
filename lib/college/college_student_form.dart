import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetailScreen extends StatefulWidget {
  final int applicationId;
  final String? StudentName;
  final String degree;
  final String courseName;

  const StudentDetailScreen({
    Key? key,
    required this.applicationId,
    required this.StudentName,
    required this.degree,
    required this.courseName,
  }) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseurl/studentscompletedetails?user_id=${widget.applicationId}',
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            data = json.decode(response.body);
            loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            error = 'Failed to load data';
            loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error: $e';
          loading = false;
        });
      }
    }
  }

  bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 || kIsWeb;
  }

  Widget buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.deepPurple.shade700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              height: 1,
              color: Colors.deepPurple.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildKeyValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade900, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Card(
      elevation: 5,
      shadowColor: Colors.deepPurple.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Container(
        width: 600, // fixed width for cards on web for nice row wrapping
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget buildCardsList(BuildContext context, List<Widget> cards) {
    if (isWideScreen(context)) {
      // For web or wide screen, wrap cards horizontally with spacing, wrap to new line if needed
      return Wrap(spacing: 12, runSpacing: 12, children: cards);
    } else {
      // Mobile: stack vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards,
      );
    }
  }

  Widget buildEducationSection(
    List<dynamic> educationList,
    BuildContext context,
  ) {
    final cards =
        educationList.map((edu) {
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildKeyValueRow('Degree', edu['type'] ?? ''),
                buildKeyValueRow('Course Name', edu['courseName'] ?? ''),
                buildKeyValueRow('College Name', edu['collegeName'] ?? ''),
                buildKeyValueRow(
                  'Duration',
                  '${edu['fromDate'] ?? ''} to ${edu['toDate'] ?? ''}',
                ),
              ],
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Education', Icons.school),
        buildCardsList(context, cards),
      ],
    );
  }

  Widget buildFellowshipsSection(
    List<dynamic> fellowships,
    BuildContext context,
  ) {
    final cards =
        fellowships.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var fellowship = entry.value;
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fellowship $idx',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Divider(
                  color: Colors.deepPurple,
                  thickness: 1,
                  height: 16,
                ),
                buildKeyValueRow('Course Name', fellowship['courseName'] ?? ''),
                buildKeyValueRow(
                  'College Name',
                  fellowship['collegeName'] ?? '',
                ),
                buildKeyValueRow(
                  'Duration',
                  '${fellowship['fromDate'] ?? ''} to ${fellowship['toDate'] ?? ''}',
                ),
              ],
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Fellowships', Icons.workspace_premium),
        buildCardsList(context, cards),
      ],
    );
  }

  Widget buildPapersSection(List<dynamic> papers, BuildContext context) {
    final cards =
        papers.map((paper) {
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildKeyValueRow('Title', paper['name'] ?? ''),
                buildKeyValueRow('Description', paper['description'] ?? ''),
                buildKeyValueRow('Submission Date', paper['submittedOn'] ?? ''),
              ],
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Papers', Icons.menu_book),
        buildCardsList(context, cards),
      ],
    );
  }

  Widget buildWorkExperienceSection(
    List<dynamic> workExperiences,
    BuildContext context,
  ) {
    final cards =
        workExperiences.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var work = entry.value;
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Experience $idx',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Divider(
                  color: Colors.deepPurple,
                  thickness: 1,
                  height: 16,
                ),
                buildKeyValueRow('Role', work['role'] ?? ''),
                buildKeyValueRow('Hospital Name', work['name'] ?? ''),
                buildKeyValueRow(
                  'Duration',
                  '${work['from'] ?? ''} to ${work['to'] ?? ''}',
                ),
                buildKeyValueRow('Place', work['place'] ?? ''),
                buildKeyValueRow('Description', work['description'] ?? ''),
              ],
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Work Experience', Icons.work),
        buildCardsList(context, cards),
      ],
    );
  }

  Widget buildCertificatesSection(dynamic certificates) {
    if (certificates == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(
          'Currently Active Medical Council Certificate',
          Icons.verified,
        ),
        buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildKeyValueRow('Course Name', certificates['courseName'] ?? ''),
              buildKeyValueRow(
                'Counsel Name',
                certificates['counselName'] ?? '',
              ),
              buildKeyValueRow(
                'Duration',
                '${certificates['validFrom'] ?? ''} to ${certificates['validTo'] ?? ''}',
              ),
              buildKeyValueRow(
                'Reg. No.',
                certificates['registrationNumber'] ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> showExpressInterestDialog() async {
    final _formKey = GlobalKey<FormState>();
    String? message;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Express Interest'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Message (Optional)',
                      hintText:
                          "Describe the position and why you're interested in this doctor...",
                    ),
                    maxLines: 3,
                    onSaved: (value) => message = value?.trim(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _sendInterestRequest(message);
                  }
                },
                child: const Text('Send Interest'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendInterestRequest(String? message) async {
    // Close the form dialog first
    Navigator.of(context).pop();

    // Check if widget is still mounted
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Sending...'),
              ],
            ),
          ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userid') ?? 0;
      final userName = prefs.getString('name') ?? "";

      final response = await http.post(
        Uri.parse('$baseurl/add-interest'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'college_id': userId,
          'college_name': userName,
          'student_id': widget.applicationId,
          'student_name': widget.StudentName,
          'message': message,
          'degree': widget.degree,
          'course_name': widget.courseName,
        }),
      );
      print(widget.courseName);
      print(widget.degree);
      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Show result
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Interest expressed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to send interest. Status: ${response.statusCode}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      // Dismiss loading dialog if it's still showing
      Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open document')));
    }
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple.shade400),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResumeSection(List<dynamic> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Resume', Icons.description),
        ...documents.map((doc) {
          return buildCard(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(doc['name'] ?? 'Unnamed Document')),
                TextButton(
                  onPressed: () {
                    final url = doc['url'] ?? '';
                    if (url.isNotEmpty) {
                      _launchURL(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No URL provided')),
                      );
                    }
                  },
                  child: const Text('View'),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Student Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Student Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(child: Text(error!)),
      );
    }

    final name = data?['name'] ?? '';

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Student Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade200.withOpacity(0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (data?['education'] != null)
              buildEducationSection(data!['education'], context),
            if (data?['fellowships'] != null)
              buildFellowshipsSection(data!['fellowships'], context),
            if (data?['papers'] != null)
              buildPapersSection(data!['papers'], context),
            if (data?['workExperiences'] != null)
              buildWorkExperienceSection(data!['workExperiences'], context),
            if (data?['certificate'] != null)
              buildCertificatesSection(data!['certificate']),
            if (data?['documents'] != null)
              buildResumeSection(data!['documents']),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: showExpressInterestDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Express Interest',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
