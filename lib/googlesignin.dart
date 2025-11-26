import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/mainscreen.dart';
import 'package:medicalapp/auth.dart';
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
  Future<void> _handleSignIn() async {
    bool _isLoading = false;
    setState(() => _isLoading = true);

    User? user = await signInWithGoogle();
    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final email = user.email ?? "";
    final name = user.displayName ?? "";
    final photourl = user.photoURL ?? "";
    await prefs.setString('photourl', photourl);

    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/user/check-or-insert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await authState.refreshUser(); // refresh role → triggers redirect
        if (context.mounted) context.go('/');

        final userId = data['userid'];
        final userName = data['name'];
        final role = data['role'];

        await prefs.setString('name', userName);
        await prefs.setString('role', role);
        if (userId != null) await prefs.setInt('userid', userId);

        setState(() => _isLoading = false);

        // Use GoRouter navigation
        switch (role) {
          case 'admin':
            context.go('/admin');
            break;
          case 'college':
            context.go('/college');
            break;
          case 'doctor':
            context.go('/doctor');
            break;
          case 'myrank_user':
            context.go('/user');
            break;
          case 'myrank_cm':
            context.go('/myrank_cm');
            break;
          default:
            context.go('/approval');
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('API failed')));
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
