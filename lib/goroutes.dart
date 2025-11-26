import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/auth.dart';
import 'package:medicalapp/myrank_cm/home_page.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicalapp/index.dart';
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/college/homepage.dart';
import 'package:medicalapp/student/home.dart';
import 'package:medicalapp/myrankUser/homepage.dart';
import 'package:medicalapp/newUser.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    refreshListenable: authState, // if using authState
    initialLocation: '/',
    redirect: _redirectLogic,
    routes: _routes,
  );

  // Redirect logic
  static String? _redirectLogic(BuildContext context, GoRouterState state) {
    if (!authState.initialized) return null;

    final role = authState.role;
    final loggedIn = role != null;

    if (!loggedIn) return '/';

    switch (role) {
      case 'admin':
        return '/admin';
      case 'college':
        return '/college';
      case 'doctor':
        return '/doctor';
      case 'myrank_user':
        return '/user';
      case 'myrank_cm':
        return '/myrank_cm';
      default:
        return '/approval';
    }
  }

  // Route list
  static final List<GoRoute> _routes = [
    GoRoute(path: '/', builder: (_, __) => const Index()),
    GoRoute(path: '/admin', builder: (_, __) => AdminDashboard()),
    GoRoute(path: '/college', builder: (_, __) => CollegeDashboard()),
    GoRoute(path: '/doctor', builder: (_, __) => DoctorDashboardApp()),
    GoRoute(path: '/user', builder: (_, __) => UserHomePage()),
    GoRoute(path: '/myrank_cm', builder: (_, __) => MyRankCMHomePage()),
    GoRoute(path: '/approval', builder: (_, __) => ApprovalScreen()),
  ];
}
