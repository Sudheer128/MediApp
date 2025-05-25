import 'package:flutter/material.dart';
import 'package:medicalapp/googlesignin.dart';

// === Colors ===
const medical = Color(0xFF007FFF);
const medicalLight = Color(0xFFE0F7FF);
const medicalDark = Color(0xFF005F9E);
const medicalAccent = Color(0xFF00B4FF);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedConnect',
      theme: ThemeData(
        primaryColor: medical,
        colorScheme: ColorScheme.light(
          primary: medical,
          secondary: medicalAccent,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return HomePage(
            handleSignIn: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback handleSignIn;

  const HomePage({required this.handleSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MedConnect'),
        backgroundColor: medical,
        actions: [
          TextButton(
            onPressed: handleSignIn,
            child: Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(handleSignIn: handleSignIn),
            FeaturesSection(),
            ForDoctorsSection(handleSignIn: handleSignIn),
            ForCollegesSection(handleSignIn: handleSignIn),
            CTASection(handleSignIn: handleSignIn),
          ],
        ),
      ),
    );
  }
}

// === Hero Section ===
class HeroSection extends StatelessWidget {
  final VoidCallback handleSignIn;

  const HeroSection({required this.handleSignIn});

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
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.center : CrossAxisAlignment.center,
            children: [
              // Text Column
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
                      SizedBox(height: 24),
                      Text(
                        'MedConnect helps medical professionals showcase their qualifications and connects hospitals and institutions with the talent they need.',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 32),
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
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: handleSignIn,
                            child: Text('Get Started'),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: medical, width: 2),
                              foregroundColor: medical,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: handleSignIn,
                            child: Text('Learn More'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Image
              if (isWide) ...[
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
                          offset: Offset(0, 10),
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
            ],
          );
        },
      ),
    );
  }
}

// === Features Section ===
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
