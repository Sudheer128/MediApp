import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';

class AuthState extends ChangeNotifier {
  String? role;
  bool initialized = false;

  AuthState() {
    refreshUser();
  }

  Future<void> refreshUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      role = null;
      initialized = true;
      notifyListeners();
      return;
    }

    final email = user.email;
    if (email == null) {
      role = null;
      initialized = true;
      notifyListeners();
      return;
    }

    final response = await http.post(
      Uri.parse('$baseurl/api/user/check-or-insert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      role = data['role'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role ?? '');
    }

    initialized = true;
    notifyListeners();
  }
}

final authState = AuthState();     // GLOBAL INSTANCE

