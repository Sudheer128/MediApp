import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicalapp/admin/adminCollegedocList.dart';
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/admin/studentsList.dart';
import 'package:medicalapp/college/collegedashboard.dart';
import 'package:medicalapp/index.dart';
import 'package:medicalapp/myrankUser/homepage.dart';
import 'package:medicalapp/myrank_cm/home_page.dart';
import 'package:medicalapp/newUser.dart';
import 'package:medicalapp/student/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _getRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

/// Role-based access definitions
final Map<String, List<String>> roleAccess = {
  'admin': [
    '/admin',
    '/available-doctors',
    '/doctor',
    '/college',
    '/user',
    '/course-details', // <-- FIXED
  ],

  'college': ['/college', '/available-doctors', '/doctor'],

  'doctor': ['/doctor'],

  'myrank_user': ['/user'],

  'myrank_cm': ['/cm', '/available-doctors'],

  'guest': ['/'],
};

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final role = await _getRole() ?? 'guest';
    final path = state.matchedLocation;

    // Not logged in
    if (user == null && path != '/') return '/';

    final allowedRoutes = roleAccess[role] ?? ['/'];

    // Allow dynamic course-details route
    if (path.startsWith('/course-details')) return null;

    // Allow navigation if already inside allowed area
    if (allowedRoutes.any((allowed) => path.startsWith(allowed))) {
      return null; // <-- DO NOT REDIRECT
    }

    // Only block when accessing forbidden route manually
    return allowedRoutes.first;
  },

  routes: [
    GoRoute(path: '/', builder: (_, __) => Index()),

    GoRoute(path: '/admin', builder: (_, __) => AdminDashboard()),
    GoRoute(path: '/college', builder: (_, __) => CollegeDashboard()),
    GoRoute(path: '/user', builder: (_, __) => UserHomePage()),
    GoRoute(path: '/cm', builder: (_, __) => MyRankCMHomePage()),
    GoRoute(path: '/doctor', builder: (_, __) => DoctorDashboardApp()),
    GoRoute(path: '/approval', builder: (_, __) => ApprovalScreen()),

    GoRoute(
      path: '/available-doctors',
      builder: (_, __) => AdminCollegeDegreesScreen(),
    ),

    GoRoute(
      path: '/course-details/:degree/:courseName/:status',
      builder: (context, state) {
        final degree = Uri.decodeComponent(state.pathParameters['degree']!);
        final courseName = Uri.decodeComponent(
          state.pathParameters['courseName']!,
        );
        final status = int.tryParse(state.pathParameters['status']!) ?? 0;

        return AdminCourseDetailsScreen(
          degree: degree,
          courseName: courseName,
          status: status,
        );
      },
    ),
  ],
);
