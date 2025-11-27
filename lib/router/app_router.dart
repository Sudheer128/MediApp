import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicalapp/admin/adminCollegedocList.dart';
import 'package:medicalapp/admin/adminintreststatus.dart';
import 'package:medicalapp/admin/adminloginlogs.dart';
import 'package:medicalapp/admin/collegeStudentsform.dart';
import 'package:medicalapp/admin/form_page.dart';
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/admin/search.dart';
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/admin/studentsList.dart';
import 'package:medicalapp/admin/userstable.dart';
import 'package:medicalapp/college/collegedashboard.dart';
<<<<<<< HEAD
import 'package:medicalapp/extranew/jobnotification.dart';
=======
import 'package:medicalapp/edit_formAfterSave.dart';
import 'package:medicalapp/extranew/jobdetails.dart';
>>>>>>> 52235f6ff29e365ab6026d3a8a3d0169df949368
import 'package:medicalapp/index.dart';
import 'package:medicalapp/myrankUser/homepage.dart';
import 'package:medicalapp/myrank_cm/home_page.dart';
import 'package:medicalapp/newUser.dart';
<<<<<<< HEAD
import 'package:medicalapp/pdf.dart';
import 'package:medicalapp/student/edit.dart';
import 'package:medicalapp/student/form_page.dart';
=======
import 'package:medicalapp/student/edit.dart';
>>>>>>> 52235f6ff29e365ab6026d3a8a3d0169df949368
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
    '/student-details',
    '/doctor',
    '/college',
    '/user',
    '/course-details', // <-- FIXED
    '/edit-application',
    '/create-student-form',
    '/search-doctors',
    '/doctor_profile',
    '/pdf-viewer',
    '/add_job',
    '/manage_users',
    '/college_interests',
    '/login-tracks',
  ],

  'college': ['/college', '/available-doctors', '/doctor'],

  'doctor': ['/doctor', '/edit-form', '/edit-application', '/job-details/'],

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
    GoRoute(
      path: '/edit-form/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id']!) ?? 0;
        return EditForm(applicationId: id);
      },
    ),
    GoRoute(
      path: '/edit-application',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return EditApplicationForm(existingData: data);
      },
    ),
    GoRoute(
      path: '/job-details/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id']!) ?? 0;
        return JobDetailsPage(jobId: id);
      },
    ),

    GoRoute(path: '/', builder: (_, __) => Index()),

    GoRoute(path: '/admin', builder: (_, __) => AdminDashboard()),
    GoRoute(path: '/college', builder: (_, __) => CollegeDashboard()),
    GoRoute(path: '/user', builder: (_, __) => UserHomePage()),
    GoRoute(path: '/cm', builder: (_, __) => MyRankCMHomePage()),
    GoRoute(path: '/doctor', builder: (_, __) => DoctorDashboardApp()),
    GoRoute(path: '/approval', builder: (_, __) => ApprovalScreen()),

    GoRoute(
      path: '/create-student-form',
      builder: (_, __) => ApplicationForm(),
    ),

    GoRoute(path: '/search-doctors', builder: (_, __) => SearchPage()),
    GoRoute(
      path: '/available-doctors',
      builder: (_, __) => AdminCollegeDegreesScreen(),
    ),
    GoRoute(path: '/add_job', builder: (_, __) => JobNotificationForm()),

    GoRoute(path: '/manage_users', builder: (_, __) => UserManagementPage()),

    GoRoute(path: '/college_interests', builder: (_, __) => InterestsPage()),

    GoRoute(path: '/login-tracks', builder: (_, __) => LoginLogsPage()),
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

    GoRoute(
      name: 'studentDetails',
      path: '/student-details/:applicationId/:studentName/:degree/:courseName',
      builder: (context, state) {
        return AdminStudentDetailScreen(
          applicationId:
              int.tryParse(state.pathParameters['applicationId']!) ?? 0,
          StudentName: Uri.decodeComponent(
            state.pathParameters['studentName']!,
          ),
          degree: Uri.decodeComponent(state.pathParameters['degree']!),
          courseName: Uri.decodeComponent(state.pathParameters['courseName']!),
        );
      },
    ),

    GoRoute(
      name: 'editApplication',
      path: '/edit-application',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;

        return EditApplicationForm(existingData: data);
      },
    ),

    GoRoute(
      name: 'adminEditForm',
      path: '/doctor_profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return AdminEditForm(userId: userId);
      },
    ),
    GoRoute(
      name: 'pdfViewer',
      path: '/pdf-viewer/:url',
      builder: (context, state) {
        final url = Uri.decodeComponent(state.pathParameters['url']!);
        final color = state.extra as Color? ?? Colors.blue;

        return PdfViewerPage(url: url, color: color);
      },
    ),
  ],
);
