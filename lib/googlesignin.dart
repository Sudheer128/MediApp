import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/college/homepage.dart';
import 'package:medicalapp/myrankUser/homepage.dart';
import 'package:medicalapp/newUser.dart';

import 'package:medicalapp/student/form_page.dart';
import 'package:medicalapp/student/home.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  void _handleSignIn() async {
    User? user = await signInWithGoogle();
    if (user != null) {
      final email = user.email ?? "";
      final name = user.displayName ?? "";

      final response = await http.post(
        Uri.parse('$baseurl/api/user/check-or-insert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save user_id to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userId = data['userid']; // Adjust key as per your API response
        final userName = data['name'];
        await prefs.setString('name', userName);
        print('Saved user_id: $userId');
        if (userId != null) {
          await prefs.setInt('userid', userId);
          print('Saved user_id: $userId');
        }

        final role = data['role'];

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
          case 'notassigned':
          default:
            destinationPage = ApprovalScreen();
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      } else {
        print("API failed: ${response.body}");
      }
    } else {
      print('Sign in failed or cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign-In')),
      body: Center(
        child: Column(
          children: [
            Text('Wellcome to MyRank Doctor Portal'),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    print(userCredential.user?.email);
    print(userCredential.user?.displayName);
    print(userCredential.user?.phoneNumber);
    return userCredential.user;
  } catch (e) {
    print('Error with Google sign-in: $e');
    return null;
  }
}

Future<void> signOutGoogle() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
  print('User signed out');
}
