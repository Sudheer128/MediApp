import 'package:flutter/material.dart';
import 'package:medicalapp/college/homepage.dart';
import 'package:medicalapp/extranew/mainlayout.dart';
import 'collegeintrests.dart';
import 'studentList.dart';

class CollegeDashboard extends StatelessWidget {
  const CollegeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "College Dashboard",

      pages: [
        CollegeDegreesScreen(), // Page 1
        CollegeInterestsPage(), // Page 2
        // StudentListPage(),          // Page 3
        // CollegeProfilePage(),       // Page 4 (optional)
      ],
    );
  }
}
