import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/Adminedit_form.dart';
import 'package:medicalapp/pdf.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminEditForm extends StatefulWidget {
  const AdminEditForm({Key? key}) : super(key: key);

  @override
  State<AdminEditForm> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<AdminEditForm> {
  Map<String, dynamic>? data;
  bool loading = false;
  String? error;
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentData(String userId) async {
    setState(() {
      loading = true;
      error = null;
      data = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.0.103:8080/studentscompletedetails?user_id=$userId',
        ),
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

  Widget buildSectionHeader(String title, IconData icon, VoidCallback onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade800),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue.shade800,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: onEdit,
            tooltip: 'Edit $title',
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
    final userIdText = _userIdController.text.trim();
    final userId = int.tryParse(userIdText) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Education', Icons.school, () {
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
        }),

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
        buildSectionHeader('Fellowships', Icons.workspace_premium, () {
          // TODO: Implement edit action for Fellowships
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Fellowships tapped')),
          );
        }),
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

  Widget buildPapersSection(List<dynamic> papers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Papers', Icons.menu_book, () {
          // TODO: Implement edit action for Papers
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Edit Papers tapped')));
        }),
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
        buildSectionHeader('Work Experience', Icons.work, () {
          // TODO: Implement edit action for Work Experience
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Work Experience tapped')),
          );
        }),
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
          () {
            // TODO: Implement edit action for Certificate
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Certificate tapped')),
            );
          },
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

  Widget buildResumeSection(List<dynamic> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Resume', Icons.description, () {
          // You can add edit functionality if needed
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Edit Resume tapped')));
        }),
        ...documents.map((doc) {
          return buildCard(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(doc['name'] ?? 'Unnamed Document')),
                TextButton(
                  onPressed: () {
                    final url = doc['url'] ?? '';
                    print(url);
                    if (url.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PdfViewerPage(
                                url: url,
                                title: doc['name'] ?? 'Document',
                              ),
                        ),
                      );
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Search Student Details by User ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final userId = _userIdController.text.trim();
                    if (userId.isNotEmpty) {
                      fetchStudentData(userId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a User ID')),
                      );
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
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
                margin: const EdgeInsets.only(bottom: 24),
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
