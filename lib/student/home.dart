import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/edit_formAfterSave.dart';
import 'package:medicalapp/extranew/alljobs.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/student/form_page.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardApp extends StatelessWidget {
  const DoctorDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(0),
        ),
      ),
      home: const DoctorDashboard(),
    );
  }
}

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  bool _isActive = false;
  String? _username;
  int _currentIndex = 0;
  String _statusValue = "0"; // store exact status from backend

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('name') ?? "Doctor";
    });
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    final uri = Uri.parse('$baseurl/getuserstatus?userid=$userId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final statusValue = data['status']?.toString() ?? "0";
        _isActive = statusValue == "1";
        setState(() {
          _statusValue = statusValue;
        });

        await prefs.setString('statusValue', statusValue);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch status')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching status: $e')));
    }
  }

  Future<void> _updateStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    final statusValue = isActive ? 1 : 0;
    final uri = Uri.parse(
      '$baseurl/userstatus?user_id=$userId&status=$statusValue',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          _isActive = isActive;
        });
        await prefs.setBool('isActive', isActive);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status updated: ${isActive ? "Active" : "Inactive"}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update status: ${response.statusCode}, Create your profile first',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    Color iconColor = Colors.blue,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    enabled ? Color(0xFF0A66C2) : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF0A66C2)),
              SizedBox(width: 8),
              Text(
                "Complete Your Profile",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "A complete profile helps you stand out to potential employers. Make sure to include:",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                _buildProfileItem("Educational background"),
                _buildProfileItem("Professional experience"),
                _buildProfileItem("Specialties and skills"),
                _buildProfileItem("Certifications and credentials"),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApplicationForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                "Create Profile",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
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
              text,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    final isWeb = MediaQuery.of(context).size.width > 900;

    Widget content = RefreshIndicator(
      onRefresh: () async {
        await _loadStatus();
        await _loadUsername();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isWeb ? 0 : 16),
        child: Column(
          children: [
            _buildCard(
              icon: Icons.person_outline,
              title: "Your Profile",
              subtitle:
                  "Complete and manage your professional profile to increase visibility to medical institutions.",
              buttonText: "Edit Profile",
              iconColor: Color(0xFF0A66C2),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('userid') ?? 0;
                if (kIsWeb) {
                  context.go('/edit-form/$userId');
                } else {
                  context.push('/edit-form/$userId');
                }
              },
            ),

            SizedBox(height: 16),

            // 🚀 SHOW ONLY IF STATUS != 0 and != 1
            if (!(_statusValue == "0" || _statusValue == "1"))
              _buildCompleteProfileSection(context),

            SizedBox(height: 16),

            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility, color: Color(0xFF0A66C2)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Enable Profile Visibility",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "If you are looking for new opportunities or wish for your profile to be visible to potential employers or institutions, enabling this setting will allow your profile to be shown to colleges and organizations actively seeking candidates.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F2EF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isActive
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _isActive ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _isActive
                                    ? 'Your profile is visible'
                                    : 'Your profile is hidden',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (bool value) {
                            _updateStatus(value);
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isWeb) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1128),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildJobsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Jobs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Text('Coming soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Text('No notifications yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    final isWeb = MediaQuery.of(context).size.width > 900;

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 0 : 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                // Profile header with background
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A66C2), Color(0xFF004182)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -40),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF0A66C2),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _username ?? 'Doctor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Medical Professional',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        Icons.person_outline,
                        'Edit Profile',
                        'Update your professional information',
                        () async {
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getInt('userid') ?? 0;
                          if (kIsWeb) {
                            context.go('/edit-form/$userId');
                          } else {
                            context.push('/edit-form/$userId');
                          }
                        },
                      ),
                      Divider(height: 1),
                      _buildProfileOption(
                        Icons.settings_outlined,
                        'Settings',
                        'Manage your account settings',
                        () {},
                      ),
                      Divider(height: 1),
                      _buildProfileOption(
                        Icons.help_outline,
                        'Help & Support',
                        'Get help with your account',
                        () {},
                      ),
                      Divider(height: 1),
                      _buildProfileOption(
                        Icons.logout,
                        'Log Out',
                        'Sign out of your account',
                        () {
                          signOutGoogle();
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => Index()),
                          //   (Route<dynamic> route) => false,
                          // );
                          context.go('/login');
                        },
                        textColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isWeb) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.grey.shade700),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTitle() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF0A66C2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.medical_services, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildWebNavBar() {
    return Container(
      constraints: BoxConstraints(maxWidth: 1128),
      child: Row(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF0A66C2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.medical_services, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          // Search bar
          Container(
            width: 280,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                filled: true,
                fillColor: Color(0xFFEEF3F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SizedBox(width: 24),
          // Navigation items
          Expanded(
            child: Row(
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.work_outline, 'Jobs', 1),
                _buildNavItem(Icons.notifications_outlined, 'Notifications', 2),
                _buildNavItem(Icons.person_outline, 'Me', 3),
                Spacer(),
                // Right side icons
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                  onPressed: () {},
                  tooltip: 'Messaging',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black87 : Colors.grey.shade600,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black87 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 4),
                height: 2,
                width: 40,
                color: Colors.black87,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Doctor Dashboard",
      pages: [
        _buildHomePage(),
        AllJobsPage(),
        _buildNotificationsPage(),
        _buildProfilePage(),
      ],
    );
  }
}
