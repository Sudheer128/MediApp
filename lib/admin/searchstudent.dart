import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/Adminedit_form.dart';
import 'package:medicalapp/pdf.dart';
import 'package:medicalapp/url.dart';
import 'package:shimmer/shimmer.dart';
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

  // LinkedIn-style Profile Header with Cover and Profile Picture
  Widget buildProfileHeader(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    final email = data['email'] ?? '';
    final phone = data['phone']?.toString() ?? '';
    final address = data['address'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Edit Button (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (data != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AdminEditApplicationForm(
                                existingData: data,
                                userId: int.tryParse(widget.userId ?? ''),
                              ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              // Profile Picture
              Positioned(
                bottom: -50,
                left: 24,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.grey.shade300,
                  ),
                  child: ClipOval(
                    child:
                        data['profile_image'] != null &&
                                data['profile_image'].toString().isNotEmpty
                            ? Image.network(
                              data['profile_image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey.shade600,
                                );
                              },
                            )
                            : Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey.shade600,
                            ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Profile Info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Medical Professional',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$email • $phone',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LinkedIn-style Section Card
  Widget buildLinkedInSection({
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // About Section
  Widget buildAboutSection() {
    return buildLinkedInSection(
      title: 'About',
      content: Text(
        'Experienced medical professional dedicated to providing quality healthcare and continuous professional development.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          height: 1.5,
        ),
      ),
    );
  }

  // Experience Item
  Widget buildExperienceItem(Map<String, dynamic> work, bool isLast) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.business, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work['role'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    work['name'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${work['from'] ?? ''} - ${work['to'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    work['place'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (work['description'] != null &&
                      work['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      work['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Work Experience Section
  Widget buildWorkExperienceSection(List<dynamic> workExperiences) {
    return buildLinkedInSection(
      title: 'Work Experience',
      content: Column(
        children:
            workExperiences.asMap().entries.map((entry) {
              return buildExperienceItem(
                entry.value,
                entry.key == workExperiences.length - 1,
              );
            }).toList(),
      ),
    );
  }

  // Fellowship Item
  Widget buildFellowshipItem(Map<String, dynamic> fellowship, bool isLast) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fellowship['courseName'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fellowship['collegeName'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fellowship['fromDate'] ?? ''} - ${fellowship['toDate'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Fellowship Section
  Widget buildFellowshipSection(List<dynamic> fellowships) {
    return buildLinkedInSection(
      title: 'Fellowships',
      content: Column(
        children:
            fellowships.asMap().entries.map((entry) {
              return buildFellowshipItem(
                entry.value,
                entry.key == fellowships.length - 1,
              );
            }).toList(),
      ),
    );
  }

  // Education Item
  Widget buildEducationItem(Map<String, dynamic> edu, bool isLast) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.school, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu['collegeName'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${edu['type'] ?? ''}, ${edu['courseName'] ?? ''}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${edu['fromDate'] ?? ''} - ${edu['toDate'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Education Section
  Widget buildEducationSection(List<dynamic> education) {
    return buildLinkedInSection(
      title: 'Education',
      content: Column(
        children:
            education.asMap().entries.map((entry) {
              return buildEducationItem(
                entry.value,
                entry.key == education.length - 1,
              );
            }).toList(),
      ),
    );
  }

  // Licenses & Certifications
  Widget buildLicensesSection(dynamic certificate) {
    return buildLinkedInSection(
      title: 'Licenses & Certifications',
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.verified, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate['courseName'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  certificate['counselName'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registration No: ${certificate['registrationNumber'] ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valid: ${certificate['validFrom'] ?? ''} - ${certificate['validTo'] ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Publications Section
  Widget buildPublicationsSection(List<dynamic> papers) {
    return buildLinkedInSection(
      title: 'Publications',
      content: Column(
        children:
            papers.asMap().entries.map((entry) {
              final paper = entry.value;
              final isLast = entry.key == papers.length - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paper['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Published: ${paper['submittedOn'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
      ),
    );
  }

  // Resume/Documents Section
  Future<void> _launchURL(BuildContext context, String url) async {
    if (kIsWeb) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(url: url, color: Colors.blue),
        ),
      );
    }
  }

  Widget buildResumeSection(List<dynamic> documents) {
    return buildLinkedInSection(
      title: 'Resume & Documents',
      content: Column(
        children:
            documents.asMap().entries.map((entry) {
              final doc = entry.value;
              final isLast = entry.key == documents.length - 1;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.description,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name'] ?? 'Unnamed Document',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc['type'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
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
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: linkedInProfileShimmer(),
      );
    }

    if (loading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (data != null) buildProfileHeader(data!),
                    buildAboutSection(),
                    if (data?['workExperiences'] != null &&
                        (data!['workExperiences'] as List).isNotEmpty)
                      buildWorkExperienceSection(data!['workExperiences']),
                    if (data?['fellowships'] != null &&
                        (data!['fellowships'] as List).isNotEmpty)
                      buildFellowshipSection(data!['fellowships']),
                    if (data?['education'] != null)
                      buildEducationSection(data!['education']),
                    if (data?['certificate'] != null)
                      buildLicensesSection(data!['certificate']),
                    if (data?['papers'] != null &&
                        (data!['papers'] as List).isNotEmpty)
                      buildPublicationsSection(data!['papers']),
                    if (data?['documents'] != null &&
                        (data!['documents'] as List).isNotEmpty)
                      buildResumeSection(data!['documents']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget shimmerBox({
  double height = 16,
  double width = double.infinity,
  double radius = 8,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

Widget linkedInProfileShimmer() {
  return SingleChildScrollView(
    child: Column(
      children: [
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER CARD
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Cover Image Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Profile Info
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmerBox(height: 25, width: 200),
                            const SizedBox(height: 12),

                            shimmerBox(height: 18, width: 150),
                            const SizedBox(height: 12),

                            shimmerBox(height: 14, width: 250),
                            const SizedBox(height: 8),

                            shimmerBox(height: 14, width: 180),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ABOUT SECTION
                shimmerSection(),

                // EXPERIENCE SECTION
                shimmerSection(),

                // EDUCATION SECTION
                shimmerSection(),

                //RESUME SECTION
                shimmerSection(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget shimmerSection() {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shimmerBox(height: 20, width: 160),
        const SizedBox(height: 20),
        shimmerBox(height: 14),
        const SizedBox(height: 12),
        shimmerBox(height: 14, width: 220),
        const SizedBox(height: 12),
        shimmerBox(height: 14),
      ],
    ),
  );
}
