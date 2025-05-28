import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Your shared primary color
const Color kPrimaryColor = Color(0xFF00897B);

class UserStudentDetailScreen extends StatefulWidget {
  final int applicationId;
  final String? StudentName;
  final String degree;
  final String courseName;

  const UserStudentDetailScreen({
    Key? key,
    required this.applicationId,
    required this.StudentName,
    required this.degree,
    required this.courseName,
  }) : super(key: key);

  @override
  State<UserStudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<UserStudentDetailScreen> {
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
          'http://192.168.0.103:8080/studentscompletedetails?user_id=${widget.applicationId}',
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

  bool isWideScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 || kIsWeb;

  Widget buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kPrimaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              height: 1,
              color: kPrimaryColor.withOpacity(0.2),
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
      shadowColor: kPrimaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget buildCardsList(BuildContext ctx, List<Widget> cards) {
    return isWideScreen(ctx)
        ? Wrap(spacing: 12, runSpacing: 12, children: cards)
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: cards);
  }

  Widget buildEducationSection(List<dynamic> educationList, BuildContext ctx) {
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
        buildCardsList(ctx, cards),
      ],
    );
  }

  Widget buildFellowshipsSection(List<dynamic> fellowships, BuildContext ctx) {
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
                Divider(color: kPrimaryColor, thickness: 1, height: 16),
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
        buildCardsList(ctx, cards),
      ],
    );
  }

  Widget buildPapersSection(List<dynamic> papers, BuildContext ctx) {
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
        buildCardsList(ctx, cards),
      ],
    );
  }

  Widget buildWorkExperienceSection(
    List<dynamic> workExperiences,
    BuildContext ctx,
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
                Divider(color: kPrimaryColor, thickness: 1, height: 16),
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
        buildCardsList(ctx, cards),
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
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
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
    Navigator.of(context).pop();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
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
        Uri.parse('http://192.168.0.103:8080/add-interest'),
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
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interest expressed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send interest. Status: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: kPrimaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: kPrimaryColor,
        ),
        body: Center(child: Text(error!)),
      );
    }
    final name = data?['name'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: kPrimaryColor,
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
                  colors: [kPrimaryColor.withOpacity(0.6), kPrimaryColor],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
