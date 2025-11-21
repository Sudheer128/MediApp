import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/extranew/jobdetails.dart';
import 'package:medicalapp/extranew/jobnotification.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class Job {
  final int id;
  final String organization;
  final String jobTitle;
  final String location;
  final String category;
  final String department;
  final String jobType;
  final int salaryMin;
  final int salaryMax;
  final String applicationDeadline;

  Job({
    required this.id,
    required this.organization,
    required this.jobTitle,
    required this.location,
    required this.category,
    required this.department,
    required this.jobType,
    required this.salaryMin,
    required this.salaryMax,
    required this.applicationDeadline,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,
      organization: json['organization'] ?? '',
      jobTitle: json['job_title'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      department: json['department'] ?? '',
      jobType: json['job_type'] ?? '',
      salaryMin: json['salary_min'] ?? 0,
      salaryMax: json['salary_max'] ?? 0,
      applicationDeadline: json['application_deadline'] ?? '',
    );
  }
}

class OrganizationProfile {
  final int id;
  final int userId;
  final String name;
  final int estYear;
  final String totalEmp;
  final String location;
  final String overview;

  OrganizationProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.estYear,
    required this.totalEmp,
    required this.location,
    required this.overview,
  });

  factory OrganizationProfile.fromJson(Map<String, dynamic> json) {
    return OrganizationProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      estYear: json['est_year'] ?? 0,
      totalEmp: json['total_emp'] ?? 0,
      location: json['location'] ?? '',
      overview: json['overview'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "name": name,
      "est_year": estYear,
      "total_emp": totalEmp,
      "location": location,
      "overview": overview,
    };
  }
}

class ProfileData {
  final List<Job> availableJobs;
  final OrganizationProfile organizationProfile;

  ProfileData({required this.availableJobs, required this.organizationProfile});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      availableJobs:
          (json['available_jobs'] as List? ?? [])
              .map((job) => Job.fromJson(job))
              .toList(),
      organizationProfile: OrganizationProfile.fromJson(
        json['organization_profile'] ?? {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class OrgService {
  static Future<ProfileData?> getProfileData(int userId) async {
    try {
      // Simulating your JSON response - replace this with your actual API call
      final response = await http.get(
        Uri.parse("$baseurl/organization-profile/$userId"),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProfileData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      // For demo purposes, using your provided JSON data
      final demoJson = {
        "available_jobs": [
          {
            "id": 3,
            "organization": "Elluru General Hospital",
            "job_title": "Junior Doctor",
            "location": "Elluru, Andhra Pradesh",
            "category": "MBBS",
            "department": "Other",
            "job_type": "Internship",
            "salary_min": 10000,
            "salary_max": 12000,
            "application_deadline": "2025-12-19",
          },
        ],
        "organization_profile": {
          "id": 1,
          "user_id": 10,
          "name": "Appollo Hospitals",
          "est_year": 1923,
          "total_emp": 1000000,
          "location": "Hyderabad, Telangana",
          "overview":
              "Apollo Hospitals is one of Asia's largest and most trusted healthcare groups, known for its advanced medical technology and exceptional patient care.",
        },
      };

      return ProfileData.fromJson(demoJson);
    }
  }

  static Future<bool> saveProfile(OrganizationProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse("$baseurl/organization-profile/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profile.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("SAVE ERROR: $e");
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI PAGE
// ─────────────────────────────────────────────────────────────────────────────

class CMHospitalProfilePage extends StatefulWidget {
  const CMHospitalProfilePage({Key? key}) : super(key: key);

  @override
  State<CMHospitalProfilePage> createState() => _CMHospitalProfilePageState();
}

class _CMHospitalProfilePageState extends State<CMHospitalProfilePage> {
  ProfileData? profileData;
  bool loading = true;
  int userId = 0;

  // User info from SharedPreferences
  String userName = '';
  String userPhone = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("userid") ?? 0;
    userName = prefs.getString("name") ?? "Not specified";
    userPhone = prefs.getString("phone") ?? "Not specified";
    userEmail = prefs.getString("email") ?? "Not specified";

    print("Loading user_id: $userId");
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final data = await OrgService.getProfileData(userId);

    if (data != null) {
      profileData = data;
    }

    setState(() => loading = false);
  }

  String _formatSalary(int min, int max) {
    if (min >= 100000 || max >= 100000) {
      return '₹${(min / 100000).toStringAsFixed(1)}L - ₹${(max / 100000).toStringAsFixed(1)}L per month';
    } else if (min >= 1000 || max >= 1000) {
      return '₹${(min / 1000).toStringAsFixed(1)}K - ₹${(max / 1000).toStringAsFixed(1)}K per month';
    }
    return '₹$min - ₹$max per month';
  }

  String _formatDeadline(String deadline) {
    final date = DateTime.tryParse(deadline);
    if (date == null) return deadline;

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 30) {
      return 'Closes on ${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'Closes in ${difference.inDays} days';
    } else {
      return 'Closing today';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 8),
                // _buildUserInfoSection(),
                // const SizedBox(height: 8),
                _buildJobsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HEADER SECTION
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildHeaderSection() {
    final orgName = userName;
    final totalEmp = userEmail;
    final location = userPhone;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 50,
                    color: Color(0xFF0A66C2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orgName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Email • $totalEmp",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // USER INFO SECTION
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildUserInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(Icons.person, "Name", userName),
          const SizedBox(height: 12),

          _buildInfoRow(Icons.phone, "Phone Number", userPhone),
          const SizedBox(height: 12),

          _buildInfoRow(Icons.email, "Email", userEmail),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // JOBS SECTION
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildJobsSection() {
    final jobs = profileData?.availableJobs ?? [];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Jobs",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobNotificationForm(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${jobs.length} job${jobs.length != 1 ? 's' : ''} available",
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 20),

          if (jobs.isEmpty) ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No job openings currently",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...jobs.map((job) => _buildJobCard(job)),
          ],
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.jobTitle,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF0A66C2),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            job.organization,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(job.location, style: const TextStyle(color: Colors.black54)),
              const SizedBox(width: 12),
              const Icon(Icons.work_outline, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(job.jobType, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                _formatSalary(job.salaryMin, job.salaryMax),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                _formatDeadline(job.applicationDeadline),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsPage(jobId: job.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Apply Now",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
