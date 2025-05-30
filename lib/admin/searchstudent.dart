import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/Adminedit_form.dart';
import 'package:medicalapp/admin/adminCollegedocList.dart';
import 'package:medicalapp/admin/adminintreststatus.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/admin/userstable.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/pdf.dart';
import 'package:medicalapp/url.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminEditForm extends StatefulWidget {
  final String? userId;
  const AdminEditForm({super.key, this.userId});

  @override
  State<AdminEditForm> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<AdminEditForm> {
  Map<String, dynamic>? data;
  bool loading = false;
  String? error;
  final TextEditingController _userIdController = TextEditingController();
  static const Color primaryBlue = Color(0xFF007FFF);

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchStudentData(widget.userId ?? '');
  }

  Future<void> fetchStudentData(String userId) async {
    setState(() {
      loading = true;
      error = null;
      data = null;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseurl/studentscompletedetails?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = 'No Student Available for that User Id';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 || kIsWeb;
  }

  // Removed onEdit param and edit icon button here
  Widget buildSectionHeader(String title, IconData icon) {
    return Container(
      width: double.infinity, // Make background span full width
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade800),
          const SizedBox(width: 8),
          // Wrap text in Expanded + Text to allow line wrapping
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
        ],
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  Widget buildEducationSection(List<dynamic> educationList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Education', Icons.school),
        ...educationList.map((edu) {
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Degree', edu['type'] ?? ''),
                buildInfoRow('Course Name', edu['courseName'] ?? ''),
                buildInfoRow('College Name', edu['collegeName'] ?? ''),
                buildInfoRow(
                  'Duration',
                  '${edu['fromDate'] ?? ''} to ${edu['toDate'] ?? ''}',
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildFellowshipsSection(List<dynamic> fellowships) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Fellowships', Icons.workspace_premium),
        ...fellowships.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var fellowship = entry.value;
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fellowship $idx',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.blueAccent),
                buildInfoRow('Course Name', fellowship['courseName'] ?? ''),
                buildInfoRow('College Name', fellowship['collegeName'] ?? ''),
                buildInfoRow(
                  'Duration',
                  '${fellowship['fromDate'] ?? ''} to ${fellowship['toDate'] ?? ''}',
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _logout(BuildContext context) {
    signOutGoogle();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Index()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  Widget buildPapersSection(List<dynamic> papers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Papers', Icons.menu_book),
        ...papers.map((paper) {
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Title', paper['name'] ?? ''),
                buildInfoRow('Description', paper['description'] ?? ''),
                buildInfoRow('Submission Date', paper['submittedOn'] ?? ''),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildWorkExperienceSection(List<dynamic> workExperiences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Work Experience', Icons.work),
        ...workExperiences.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var work = entry.value;
          return buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Experience $idx',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.blueAccent),
                buildInfoRow('Role', work['role'] ?? ''),
                buildInfoRow('Hospital Name', work['name'] ?? ''),
                buildInfoRow(
                  'Duration',
                  '${work['from'] ?? ''} to ${work['to'] ?? ''}',
                ),
                buildInfoRow('Place', work['place'] ?? ''),
                buildInfoRow('Description', work['description'] ?? ''),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildCertificatesSection(dynamic certificates) {
    if (certificates == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(
          'Currently Active Medical Council Certificate',
          Icons.verified,
        ),
        buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow('Course Name', certificates['courseName'] ?? ''),
              buildInfoRow('Counsel Name', certificates['counselName'] ?? ''),
              buildInfoRow(
                'Duration',
                '${certificates['validFrom'] ?? ''} to ${certificates['validTo'] ?? ''}',
              ),
              buildInfoRow(
                'Reg. No.',
                certificates['registrationNumber'] ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPersonalDetailsSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Personal Details', Icons.person),
        buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow('Name', data['name'] ?? ''),
              buildInfoRow('Phone', data['phone']?.toString() ?? ''),
              buildInfoRow('Email', data['email'] ?? ''),
              buildInfoRow('Address', data['address'] ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    if (kIsWeb) {
      // Open in external application on the web
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open document')));
      }
    } else {
      // Show PDF in-app for mobile platforms
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(url: url, color: Colors.blue),
        ),
      );
    }
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
                      _launchURL(context, url);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Search Input Row
            const SizedBox(height: 24),

            // Loading Indicator
            if (loading) const Center(child: CircularProgressIndicator()),

            // Error message
            if (error != null)
              Center(
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),

            // Show student details only if data is loaded and no error
            if (!loading && error == null && data != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  data!['name'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Single Edit button on top right above all sections
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor:
                            Colors.white, // text and icon default color
                      ),
                      onPressed: () {
                        final userIdText = _userIdController.text.trim();
                        final userId = int.tryParse(userIdText) ?? 0;
                        if (data != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminEditApplicationForm(
                                    existingData: data,
                                    userId: userId,
                                  ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        color:
                            Colors.white, // explicitly setting icon color white
                      ),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ),
              if (data != null) buildPersonalDetailsSection(data!),
              if (data?['education'] != null)
                buildEducationSection(data!['education']),
              if (data?['fellowships'] != null)
                buildFellowshipsSection(data!['fellowships']),
              if (data?['papers'] != null) buildPapersSection(data!['papers']),
              if (data?['workExperiences'] != null)
                buildWorkExperienceSection(data!['workExperiences']),
              if (data?['certificate'] != null)
                buildCertificatesSection(data!['certificate']),
              if (data?['documents'] != null)
                buildResumeSection(data!['documents']),
            ],
          ],
        ),
      ),
    );
  }
}
