// lib/main.dart
import 'package:flutter/material.dart';
import 'package:medicalapp/googlesignin.dart';

// === Colors ===
const medical = Color(0xFF007FFF);
const medicalLight = Color(0xFFE0F7FF);
const medicalDark = Color(0xFF005F9E);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedConnect',
      theme: ThemeData(
        primaryColor: medical,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MedConnect'), backgroundColor: medical),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            FeaturesSection(),
            ForDoctorsSection(),
            ForCollegesSection(),
            CTASection(),
          ],
        ),
      ),
    );
  }
}

// === Hero Section ===
class HeroSection extends StatelessWidget {
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
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              // Text Column
              Expanded(
                flex: isWide ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isWide ? 24 : 0,
                    bottom: isWide ? 0 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isWide
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Connecting Medical Talent With Opportunities',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          fontSize: isWide ? 48 : 36,
                          fontWeight: FontWeight.bold,
                          color: medicalDark,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'MedConnect helps medical professionals showcase their qualifications and connects hospitals and institutions with the talent they need.',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: medical,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(),
                                ),
                              );
                            },
                            child: Text('Get Started'),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: medical),
                              foregroundColor: medical,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                            onPressed: () {},
                            child: Text('Learn More'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Image
              Expanded(
                flex: isWide ? 1 : 0,
                child: Center(
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
    final cardWidth = isWide ? 260.0 : screenWidth - 32.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Platform Features',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: medicalDark,
            ),
          ),
          SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.spaceEvenly,
            children:
                features.map((f) {
                  return SizedBox(
                    width: cardWidth,
                    child: FeatureCard(
                      icon: f['icon'] as IconData,
                      title: f['title'] as String,
                      description: f['desc'] as String,
                    ),
                  );
                }).toList(),
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
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: medicalLight,
              child: Icon(icon, size: 28, color: medical),
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// === For Doctors Section ===
class ForDoctorsSection extends StatelessWidget {
  final bullets = const [
    'Create a comprehensive professional profile to highlight your qualifications',
    'Showcase your education, experience, and specialties',
    'Receive interest from leading medical institutions',
    'Manage all your professional documents in one secure place',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF7F7F7),
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isWide ? 24 : 0,
                    bottom: isWide ? 0 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isWide
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'For Medical Professionals',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: medicalDark,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...bullets.map(
                        (b) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check, color: medical, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: medical,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                        },

                        child: Text('Create Your Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&q=80&w=800',
                    fit: BoxFit.cover,
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

// === For Colleges Section ===
class ForCollegesSection extends StatelessWidget {
  final bullets = const [
    'Search for qualified medical professionals based on specific criteria',
    'Review detailed profiles with verified credentials',
    'Express interest directly to potential candidates',
    'Streamline your recruitment process for medical positions',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: LayoutBuilder(
        builder: (ctx, bc) {
          final isWide = bc.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              if (isWide)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1504439468489-c8920d796a29?auto=format&fit=crop&q=80&w=800',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isWide ? 24 : 0,
                    top: isWide ? 0 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isWide
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'For Institutions',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: medicalDark,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...bullets.map(
                        (b) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check, color: medical, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: medical,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                        },
                        child: Text('Find Candidates'),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isWide)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1504439468489-c8920d796a29?auto=format&fit=crop&q=80&w=800',
                      fit: BoxFit.cover,
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

// === CTA Section ===
class CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: medical,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Join our platform today and connect with the right opportunities or candidates in the medical field.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: medical,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              textStyle: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
            child: Text('Join Now'),
          ),
        ],
      ),
    );
  }
}
