import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/college/homepage.dart';
import 'package:medicalapp/myrankUser/homepage.dart';
import 'package:medicalapp/myrank_cm/home_page.dart';
import 'package:medicalapp/newUser.dart';
import 'package:medicalapp/student/home.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === Colors ===
const medical = Color(0xFF007FFF);
const medicalLight = Color(0xFFE0F7FF);
const medicalDark = Color(0xFF005F9E);
const medicalAccent = Color(0xFF00B4FF);

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email ?? '';
      if (email.isEmpty) {
        setState(() => _isCheckingAuth = false);
        return;
      }

      try {
        // Fetch role and user info from backend
        final response = await http.post(
          Uri.parse(
            '$baseurl/api/user/check-or-insert',
          ), // or your role endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'name': user.displayName ?? ''}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final prefs = await SharedPreferences.getInstance();
          final userId = data['userid'];
          final userName = data['name'];
          final role = data['role'];

          await prefs.setString('name', userName ?? '');
          await prefs.setString('role', role ?? '');
          if (userId != null) {
            await prefs.setInt('userid', userId);
          }

          Widget destinationPage;
          switch (role) {
            case 'admin':
              destinationPage = AdminDashboard();
              break;
            case 'college':
              destinationPage = CollegeDashboard();
              break;
            case 'doctor':
              destinationPage = DoctorDashboardApp();
              break;
            case 'myrank_user':
              destinationPage = UserHomePage();
              break;
            case 'myrank_cm':
              destinationPage = MyRankCMHomePage();
              break;
            default:
              destinationPage = ApprovalScreen();
          }

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => destinationPage),
            );
          }
        } else {
          setState(() => _isCheckingAuth = false);
        }
      } catch (e) {
        print('Error fetching user role: $e');
        setState(() => _isCheckingAuth = false);
      }
    } else {
      // No user logged in, show login screen
      setState(() => _isCheckingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return const HomePage();
    }
  }
}

// === HomePage with Google Sign-In popup on button clicks ===
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    User? user = await signInWithGoogle();
    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in cancelled or failed')),
      );
      return;
    }

    final email = user.email ?? "";
    final name = user.displayName ?? "";

    final prefs = await SharedPreferences.getInstance();
    final photourl = user.photoURL ?? "";
    await prefs.setString('photourl', photourl);

    print("photourlssssss$photourl");

    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/user/check-or-insert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        final userId = data['userid'];
        final userName = data['name'];
        final role = data['role'];
        await prefs.setString('name', userName);
        await prefs.setString('role', role); // ← Add this
        if (userId != null) {
          await prefs.setInt('userid', userId);
        }
        await prefs.setString('name', userName);
        if (userId != null) {
          await prefs.setInt('userid', userId);
        }

        print(role);
        Widget destinationPage;

        switch (role) {
          case 'admin':
            destinationPage = AdminDashboard();
            break;
          case 'college':
            destinationPage = CollegeDashboard();
            break;
          case 'doctor':
            destinationPage = DoctorDashboardApp();
            break;
          case 'myrank_user':
            destinationPage = UserHomePage();
            break;
          case 'myrank_cm':
            destinationPage = MyRankCMHomePage();
            break;
          default:
            destinationPage = ApprovalScreen();
        }

        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destinationPage),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('API failed: ${response.body}')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: medical, // Your primary color
        elevation: 0,
        title: Row(
          children: [
            // ✅ Logo inside a white, rounded container
            Container(
              decoration: BoxDecoration(
                // color: Colors.white, // White background
                borderRadius: BorderRadius.circular(8), // Rounded edges
              ),
              padding: const EdgeInsets.all(4), // Padding around the image
              child: Image.asset(
                'assets/logo.png',
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MedConnect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSignIn,
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                HeroSection(handleSignIn: _handleSignIn),
                FeaturesSection(),
                ForDoctorsSection(handleSignIn: _handleSignIn),
                ForCollegesSection(handleSignIn: _handleSignIn),
                CTASection(handleSignIn: _handleSignIn),
                const FooterSection(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: Text(content)),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          dialogContext,
                        ).pop(), // ✅ Use dialogContext
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
      child: Column(
        children: [
          const Divider(),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed:
                    () => _showDialog(
                      context,
                      'Terms & Conditions',
                      'These are the terms and conditions of using MedConnect.\n\n1. Use the platform ethically.\n2. Respect data privacy.\n3. Do not impersonate others.\n',
                    ),
                child: const Text('Terms & Conditions'),
              ),
              TextButton(
                onPressed:
                    () => _showDialog(
                      context,
                      'Privacy & Policy',
                      'These are the Privacy & Policy of using MedConnect.\n\n1. Use the platform ethically.\n2. Respect data privacy.\n3. Do not impersonate others.\n',
                    ),
                child: const Text('Privacy & Policy'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} MedConnect. All rights reserved.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// === Below are your sections: HeroSection, FeaturesSection, etc. ===
// For brevity, I’m including only HeroSection here — just add your existing widgets.

class HeroSection extends StatelessWidget {
  final VoidCallback handleSignIn;

  const HeroSection({required this.handleSignIn, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [medicalLight, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.center : CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isWide ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isWide ? 48 : 0,
                    bottom: isWide ? 0 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isWide
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Company Logo
                      Image.asset(
                        'assets/logo.png',
                        width: isWide ? 450 : 200, // Adjust size as needed
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),

                      // Headline
                      Text(
                        'Connecting Medical Talent With Opportunities',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          fontSize: isWide ? 42 : 32,
                          fontWeight: FontWeight.w800,
                          color: medicalDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Subheadline
                      Text(
                        'MedConnect helps medical professionals showcase their qualifications and connects hospitals and institutions with the talent they need.',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment:
                            isWide ? WrapAlignment.start : WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: medical,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: handleSignIn,
                            child: const Text('Get Started'),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: medical, width: 2),
                              foregroundColor: medical,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('Learn More'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isWide)
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&q=80&w=800',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// === Google Sign-In function ===
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle() async {
  try {
    // Ensure previous session is signed out
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Check tokens before proceeding
    if (googleAuth.accessToken == null && googleAuth.idToken == null) {
      debugPrint("Missing both accessToken and idToken");
      return null; // or throw error
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );

    return userCredential.user;
  } catch (e) {
    debugPrint('Error with Google sign-in: $e');
    return null;
  }
}

class FeaturesSection extends StatelessWidget {
  final features = const [
    {
      'icon': Icons.person,
      'title': 'Professional Profiles',
      'desc':
          'Create detailed profiles showcasing your medical education, experience, and specialties.',
    },
    {
      'icon': Icons.search,
      'title': 'Advanced Search',
      'desc':
          'Find the perfect candidates with powerful filtering by specialty, education, and experience.',
    },
    {
      'icon': Icons.folder,
      'title': 'Document Management',
      'desc':
          'Securely store and share medical credentials, publications, and certifications.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    final cardWidth = isWide ? (screenWidth - 104) / 3 : screenWidth - 48;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Platform Features',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: medicalDark,
            ),
          ),
          SizedBox(height: 16),
          Container(width: 80, height: 4, color: medicalAccent),
          SizedBox(height: 48),
          isWide
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    features
                        .map(
                          (f) => SizedBox(
                            width: cardWidth,
                            child: FeatureCard(
                              icon: f['icon'] as IconData,
                              title: f['title'] as String,
                              description: f['desc'] as String,
                            ),
                          ),
                        )
                        .toList(),
              )
              : Column(
                children:
                    features
                        .map(
                          (f) => Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: FeatureCard(
                              icon: f['icon'] as IconData,
                              title: f['title'] as String,
                              description: f['desc'] as String,
                            ),
                          ),
                        )
                        .toList(),
              ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: medicalLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: medical),
            ),
            SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: medicalDark,
              ),
            ),
            SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === For Doctors Section ===
class ForDoctorsSection extends StatelessWidget {
  final VoidCallback handleSignIn;
  final bullets = const [
    'Create a comprehensive professional profile to highlight your qualifications',
    'Showcase your education, experience, and specialties',
    'Receive interest from leading medical institutions',
    'Manage all your professional documents in one secure place',
  ];

  const ForDoctorsSection({required this.handleSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth > 800;
          return Column(
            children: [
              isWide
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildContentSection(isWide)),
                      SizedBox(width: 48),
                      Expanded(child: _buildImageSection()),
                    ],
                  )
                  : Column(
                    children: [
                      _buildContentSection(isWide),
                      SizedBox(height: 40),
                      _buildImageSection(),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentSection(bool isWide) {
    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'For Medical Professionals',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: medicalDark,
          ),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 24),
        ...bullets.map(
          (b) => Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: medicalLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: medical, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    b,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: medical,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: handleSignIn,
          child: Text(
            'Create Your Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&q=80&w=800',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// === For Colleges Section ===
class ForCollegesSection extends StatelessWidget {
  final VoidCallback handleSignIn;
  final bullets = const [
    'Search for qualified medical professionals based on specific criteria',
    'Review detailed profiles with verified credentials',
    'Express interest directly to potential candidates',
    'Streamline your recruitment process for medical positions',
  ];

  const ForCollegesSection({required this.handleSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth > 800;
          return Column(
            children: [
              isWide
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildImageSection()),
                      SizedBox(width: 48),
                      Expanded(child: _buildContentSection(isWide)),
                    ],
                  )
                  : Column(
                    children: [
                      _buildImageSection(),
                      SizedBox(height: 40),
                      _buildContentSection(isWide),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentSection(bool isWide) {
    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'For Institutions',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: medicalDark,
          ),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 24),
        ...bullets.map(
          (b) => Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: medicalLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: medical, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    b,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: medical,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: handleSignIn,
          child: Text(
            'Find Candidates',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://images.unsplash.com/photo-1504439468489-c8920d796a29?auto=format&fit=crop&q=80&w=800',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// === CTA Section ===
class CTASection extends StatelessWidget {
  final VoidCallback handleSignIn;

  const CTASection({required this.handleSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [medical, medicalDark],
        ),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(width: 80, height: 4, color: Colors.white),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Join our platform today and connect with the right opportunities or candidates in the medical field.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white, height: 1.6),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: medical,
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            onPressed: handleSignIn,
            child: Text('Join Now'),
          ),
        ],
      ),
    );
  }
}
