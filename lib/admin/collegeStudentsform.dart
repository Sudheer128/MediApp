import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/myrankUser/studentList.dart';
import 'package:medicalapp/pdf.dart';
import 'package:medicalapp/student/edit.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminStudentDetailScreen extends StatefulWidget {
  final int applicationId;
  final String? StudentName;
  final String degree;
  final String courseName;

  const AdminStudentDetailScreen({
    Key? key,
    required this.applicationId,
    required this.StudentName,
    required this.degree,
    required this.courseName,
  }) : super(key: key);

  @override
  State<AdminStudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<AdminStudentDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Widget buildGeneralCertificatesSection(List<dynamic> certificates) {
    return buildLinkedInSection(
      title: 'Licenses & Certifications',
      onEdit: () {
        // Edit general certificates
      },
      content: Column(
        children:
            certificates.asMap().entries.map((entry) {
              final cert = entry.value;
              final isLast = entry.key == certificates.length - 1;
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
                          Icons.card_membership,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cert['certificateName'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cert['issuingAuthority'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Valid: ${cert['from'] ?? ''} - ${cert['to'] ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (cert['officialLink'] != null &&
                                cert['officialLink'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final url = cert['officialLink'];
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Could not open link'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'View Certificate',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
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
            }).toList(),
      ),
    );
  }

  // Conferences Section
  Widget buildConferencesSection(List<dynamic> conferences) {
    return buildLinkedInSection(
      title: 'CONFERENCES AND CME',
      onEdit: () {
        // Edit conferences
      },
      content: Column(
        children:
            conferences.asMap().entries.map((entry) {
              final conference = entry.value;
              final isLast = entry.key == conferences.length - 1;
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
                        child: Icon(Icons.event, color: Colors.purple.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conference['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              conference['activityType'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Organized by: ${conference['organizer'] ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${conference['date'] ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (conference['uploadLink'] != null &&
                                conference['uploadLink']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final url = conference['uploadLink'];
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Could not open link'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.open_in_new,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
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
            }).toList(),
      ),
    );
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

  String? encodeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return Uri.encodeFull(url);
  }

  // LinkedIn-style Profile Header with Cover and Profile Picture
  Widget buildProfileHeader(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    final email = data['email'] ?? '';
    final phone = data['phone']?.toString() ?? '';
    final address = data['address'] ?? '';
    final profileImageUrl = encodeUrl(data['profile_url']);
    final coverImageUrl = encodeUrl(data['cover_url']);

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
                  gradient:
                      coverImageUrl == null || coverImageUrl.toString().isEmpty
                          ? LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                ),
                child:
                    coverImageUrl != null && coverImageUrl.toString().isNotEmpty
                        ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            coverImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.blue.shade400,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : null,
              ),

              // Edit Button (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // print(data);
                    if (data != null) {
                      if (kIsWeb) {
                        context.go('/edit-application', extra: data);
                      } else {
                        context.push('/edit-application', extra: data);
                      }
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
              // Loading overlay
              // if (_uploadingImage)
              //   Container(
              //     height: 200,
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //       color: Colors.black.withOpacity(0.5),
              //       borderRadius: const BorderRadius.only(
              //         topLeft: Radius.circular(8),
              //         topRight: Radius.circular(8),
              //       ),
              //     ),
              //     child: const Center(
              //       child: CircularProgressIndicator(color: Colors.white),
              //     ),
              //   ),
              // Edit Cover Button
              // Positioned(
              //   top: 12,
              //   right: 12,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: IconButton(
              //       icon: const Icon(Icons.camera_alt, size: 20),
              //       onPressed:
              //           _uploadingImage
              //               ? null
              //               : () => _showImageOptionsDialog(false),
              //       tooltip: 'Edit cover photo',
              //     ),
              //   ),
              // ),
              // Profile Picture
              Positioned(
                bottom: -50,
                left: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --------------------
                    // PROFILE IMAGE (clickable)
                    // --------------------
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.grey.shade300,
                      ),
                      child: ClipOval(
                        child:
                            (profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty)
                                ? Image.network(
                                  profileImageUrl!,
                                  fit: BoxFit.cover,
                                )
                                : Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey.shade600,
                                ),
                      ),
                    ),

                    // --------------------
                    // CAMERA ICON BUTTON
                    // --------------------
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: GestureDetector(
                    //     // onTap: () => _showImageOptionsDialog(true),
                    //     child: Tooltip(
                    //       message: "Change Profile Photo",
                    //       child: Container(
                    //         padding: const EdgeInsets.all(6),
                    //         decoration: BoxDecoration(
                    //           color: Colors.white,
                    //           borderRadius: BorderRadius.circular(30),
                    //           boxShadow: [
                    //             BoxShadow(
                    //               color: Colors.black26,
                    //               blurRadius: 6,
                    //               offset: Offset(0, 2),
                    //             ),
                    //           ],
                    //         ),
                    //         child: const Icon(
                    //           Icons.camera_alt,
                    //           size: 20,
                    //           color: Colors.black87,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    VoidCallback? onEdit,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // if (onEdit != null)
                //   IconButton(
                //     icon: const Icon(Icons.edit, size: 20),
                //     onPressed: onEdit,
                //     color: Colors.grey.shade700,
                //   ),
              ],
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
      onEdit: () {
        // Edit about
      },
      content: Text(
        'Experienced medical professional specializing in ${widget.courseName}. Passionate about delivering quality healthcare and continuous learning in the medical field.',
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

  // Professional Work Experience Section
  Widget buildProfessionalExperienceSection(List<dynamic> workExperiences) {
    return buildLinkedInSection(
      title: 'Professional Work Experience',
      onEdit: () {
        // Edit professional experience
      },
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

  // Fellowship Experience Item
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

  // Fellowship Experience Section
  Widget buildFellowshipExperienceSection(List<dynamic> fellowships) {
    return buildLinkedInSection(
      title: 'Fellowship Experience',
      onEdit: () {
        // Edit fellowship experience
      },
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
      onEdit: () {
        // Edit education
      },
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

  // Memberships Section
  Widget buildMembershipsSection(List<dynamic> memberships) {
    return buildLinkedInSection(
      title: 'Professional Memberships',
      onEdit: () {
        // Edit memberships
      },
      content: Column(
        children:
            memberships.asMap().entries.map((entry) {
              final membership = entry.value;
              final isLast = entry.key == memberships.length - 1;
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
                          Icons.groups,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              membership['association_name'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (membership['role'] != null &&
                                membership['role'].toString().isNotEmpty)
                              Text(
                                membership['role'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            const SizedBox(height: 4),
                            if (membership['membership_id'] != null &&
                                membership['membership_id']
                                    .toString()
                                    .isNotEmpty)
                              Text(
                                'Member ID: ${membership['membership_id']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (membership['leadership_roles'] != null &&
                                membership['leadership_roles']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Leadership: ${membership['leadership_roles']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
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
            }).toList(),
      ),
    );
  }

  // Skills Section
  Widget buildSkillsSection(List<dynamic> skills) {
    return buildLinkedInSection(
      title: 'Skills & Expertise',
      onEdit: () {
        // Edit skills
      },
      content: Column(
        children:
            skills.asMap().entries.map((entry) {
              final skill = entry.value;
              final isLast = entry.key == skills.length - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Skill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          skill['skill_name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (skill['endorsements_count'] != null &&
                          skill['endorsements_count'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up,
                                size: 14,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${skill['endorsements_count']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Soft Skills
                  if (skill['soft_skills'] != null &&
                      skill['soft_skills'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Soft Skills:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (skill['soft_skills'] as String)
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .map(
                                (softSkill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    softSkill,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],

                  // Interests
                  if (skill['interests'] != null &&
                      skill['interests'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Interests:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (skill['interests'] as String)
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .map(
                                (interest) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    interest,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],

                  if (!isLast) ...[
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 20),
                  ],
                ],
              );
            }).toList(),
      ),
    );
  }

  // Licenses & Certifications
  Widget buildLicensesSection(dynamic certificate) {
    return buildLinkedInSection(
      title: 'Licenses & Certifications',
      onEdit: () {
        // Edit licenses
      },
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
      onEdit: () {
        // Edit publications
      },
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
    Navigator.of(context).pop();

    if (!mounted) return;

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

      if (!mounted) return;

      Navigator.of(context).pop();

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
      if (!mounted) return;

      Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Resume/Documents Section
  Future<void> _launchURL(BuildContext context, String url) async {
    if (kIsWeb) {
      // Open in external application on the web
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
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
    return buildLinkedInSection(
      title: 'Resume & Documents',
      onEdit: () {
        // Edit documents
      },
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
        body: Center(child: Text(error!)),
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
            // Main Content
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (data != null) buildProfileHeader(data!),
                    buildAboutSection(),
                    // Skills Section - Add early in profile
                    if (data?['skills'] != null &&
                        (data!['skills'] as List).isNotEmpty)
                      buildSkillsSection(data!['skills']),
                    if (data?['workExperiences'] != null &&
                        (data!['workExperiences'] as List).isNotEmpty)
                      buildProfessionalExperienceSection(
                        data!['workExperiences'],
                      ),
                    if (data?['fellowships'] != null &&
                        (data!['fellowships'] as List).isNotEmpty)
                      buildFellowshipExperienceSection(data!['fellowships']),
                    if (data?['education'] != null)
                      buildEducationSection(data!['education']),
                    if (data?['certificate'] != null)
                      buildLicensesSection(data!['certificate']),
                    // NEW: General Certificates Section
                    if (data?['certificates'] != null &&
                        (data!['certificates'] as List).isNotEmpty)
                      buildGeneralCertificatesSection(data!['certificates']),
                    // NEW: Conferences Section
                    if (data?['conferences'] != null &&
                        (data!['conferences'] as List).isNotEmpty)
                      buildConferencesSection(data!['conferences']),
                    // Memberships Section
                    if (data?['memberships'] != null &&
                        (data!['memberships'] as List).isNotEmpty)
                      buildMembershipsSection(data!['memberships']),
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
