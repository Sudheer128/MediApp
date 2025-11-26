import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medicalapp/url.dart';

class JobDetailsPage extends StatefulWidget {
  final int jobId;
  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  Map<String, dynamic>? job;
  bool loading = true;
  bool isSaved = false;
  bool isApplied = false;
  String Roleee = "";

  @override
  void initState() {
    super.initState();
    fetchJobDetails();
  }

  Future<void> loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? "";
    setState(() {
      Roleee = role;
    });
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userid');
  }

  Future<void> applyJob() async {
    final userId = await getUserId();
    final jobId = widget.jobId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }

    final response = await http.post(
      Uri.parse("$baseurl/applyJob"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "job_id": jobId, // int
        "user_id": userId, // int
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isApplied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Applied successfully"),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to apply")));
    }
  }

  Future<void> fetchJobDetails() async {
    final userId = await getUserId();

    final response = await http.get(
      Uri.parse("$baseurl/getJobDetails?id=${widget.jobId}&user_id=$userId"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final data = body["data"]; // job details
      final applied = body["applied"]; // 0 or 1

      print("Applied Status = $applied");

      setState(() {
        job = data;
        isApplied = applied == 1; // <-- USE THIS (correct)
        loading = false;
      });
    }
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Job saved' : 'Job unsaved'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    if (loading) {
      return Scaffold(
        backgroundColor: Color(0xFFF3F2EF),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF3F2EF),
      appBar: _buildAppBar(isWeb),
      body: isWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWeb) {
    if (isWeb) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Color(0xFF0A66C2),
          ),
          onPressed: _toggleSave,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(color: Colors.grey[300], height: 1),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1128),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMainJobCard(),
                    SizedBox(height: 16),
                    _buildDescriptionCard(),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            // Right sidebar
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildCompanyCard(),
                  SizedBox(height: 16),
                  _buildApplyCard(isBottomBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              _buildMainJobCard(),
              SizedBox(height: 8),
              _buildDescriptionCard(),
              SizedBox(height: 8),
              _buildCompanyCard(),
              SizedBox(height: 24),
            ],
          ),
        ),
        // if (Roleee == 'doctor')
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildApplyCard(isBottomBar: true),
        ),
      ],
    );
  }

  Widget _buildMainJobCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 36,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job!["job_title"],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          InkWell(
                            onTap: () {},
                            child: Text(
                              job!["organization"],
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0A66C2),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  job!["location"],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Posted 2 days ago • ${job!["vacancies"]} applicants',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPillBadge(Icons.work_outline, job!["job_type"]),
                    _buildPillBadge(
                      Icons.people_outline,
                      '${job!["vacancies"]} vacancies',
                    ),
                    _buildPillBadge(
                      Icons.schedule_outlined,
                      '${job!["experience_required"]} yrs exp',
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(height: 1, color: Colors.grey[300]),
                SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Salary',
                      value:
                          '₹${job!["salary_min"]} - ₹${job!["salary_max"]}/mo',
                    ),
                    _buildInfoItem(
                      icon: Icons.event_outlined,
                      label: 'Apply by',
                      value: job!["application_deadline"],
                    ),
                    _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Join by',
                      value: job!["joining_date"],
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

  Widget _buildPillBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFE7F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF0A66C2)),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF0A66C2),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the job',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            job!["description"],
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey[300]),
          SizedBox(height: 24),
          Text(
            'Qualifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildQualifications(job!["qualifications"]),
          SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey[300]),
          SizedBox(height: 24),
          Text(
            'Job details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Department', job!["department"]),
          _buildDetailRow('Category', job!["category"]),
          _buildDetailRow('Employment Type', job!["job_type"]),
          if (job!["benefits"] != null &&
              job!["benefits"].toString().isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'Benefits',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            _buildBenefits(job!["benefits"]),
          ],
        ],
      ),
    );
  }

  Widget _buildQualifications(dynamic raw) {
    List<String> qualifications = [];
    try {
      qualifications = List<String>.from(jsonDecode(raw));
    } catch (_) {
      qualifications = raw.toString().split(",");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          qualifications.map((qualification) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      qualification.trim(),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(dynamic raw) {
    List<String> benefits = [];
    try {
      benefits = List<String>.from(jsonDecode(raw));
    } catch (_) {
      benefits = raw.toString().split(",");
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          benefits.map((benefit) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                benefit.trim(),
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            );
          }).toList(),
    );
  }

  Future<void> openApplicationLink(String url) async {
    final uri = Uri.parse(url);

    // For Web: open in new tab
    if (Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.fuchsia ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS) {
      // Desktop also opens new tab
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Mobile + Web (official way)
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // forces new tab on Web
        webOnlyWindowName: '_blank', // **critical for Web**
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot open link")));
    }
  }

  Widget _buildCompanyCard() {
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
          Text(
            'About ${job!["organization"]}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildContactRow(Icons.email_outlined, job!["contact_email"]),
          SizedBox(height: 8),
          _buildContactRow(Icons.phone_outlined, job!["contact_phone"]),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final link = job!["application_link"]; // <-- from JSON
                if (link != null && link.toString().isNotEmpty) {
                  openApplicationLink(link);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No application link available")),
                  );
                }
              },

              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF0A66C2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'View organization page',
                style: TextStyle(
                  color: Color(0xFF0A66C2),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyCard({required bool isBottomBar}) {
    if (isBottomBar) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              OutlinedButton(
                onPressed: _toggleSave,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF0A66C2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Color(0xFF0A66C2),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),

              /// APPLY BUTTON (BOTTOM BAR)
              Expanded(
                child: ElevatedButton(
                  onPressed: isApplied ? null : applyJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isApplied ? Colors.green : Color(0xFF0A66C2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ---------- WEB SIDEBAR CARD ----------
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          /// APPLY BUTTON (WEB)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isApplied ? null : applyJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? Colors.green : Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isApplied ? 'Applied' : 'Apply',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          SizedBox(height: 12),

          /// SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _toggleSave,
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
              ),
              label: Text(isSaved ? 'Saved' : 'Save'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF0A66C2),
                side: BorderSide(color: Color(0xFF0A66C2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
