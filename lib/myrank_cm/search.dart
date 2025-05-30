import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/myrankUser/userSearchStudent.dart';
import 'package:medicalapp/myrank_cm/cmsearchStudent.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CmSearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<CmSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic>? students;
  bool isLoading = false;
  bool hasSearched = false;
  static const Color primaryBlue = Color.fromARGB(255, 250, 110, 110);

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchStudents(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('name') ?? 'Admin';
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final response = await http.get(
      Uri.parse('$baseurl/cmsearch?query=$query&cmname=$savedName'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        students = jsonResponse['students'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        students = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}')));
    }
  }

  Widget _buildSearchBarWithButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 4,
              shadowColor: primaryBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (query) => fetchStudents(query),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: primaryBlue),
                  hintText: 'Search students by name, email...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: primaryBlue),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                students = null;
                                hasSearched = false;
                              });
                            },
                          )
                          : null,
                ),
                cursorColor: primaryBlue,
                style: TextStyle(fontSize: 16),
                onChanged: (value) {
                  setState(() {}); // update clear icon visibility
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => fetchStudents(_searchController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: primaryBlue.withOpacity(0.4),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: primaryBlue.withOpacity(0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryBlue.withOpacity(0.2),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CmEditForm(userId: student['user_id']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Email: ${student['email']}',
                      style: TextStyle(color: primaryBlue, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Phone: ${student['phone']}',
                      style: TextStyle(color: primaryBlue, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: primaryBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message, {Color? color}) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: color ?? primaryBlue.withOpacity(0.3)),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: color ?? primaryBlue.withOpacity(0.7),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Search Students',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 5,
        centerTitle: true,
        shadowColor: primaryBlue.withOpacity(0.4),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBarWithButton(),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(
                  color: primaryBlue,
                  strokeWidth: 4,
                ),
              ),
            if (!isLoading &&
                hasSearched &&
                (students == null || students!.isEmpty))
              _buildEmptyState(Icons.search_off, 'No students found..'),
            if (!isLoading && !hasSearched)
              _buildEmptyState(
                Icons.search,
                'Search for students to get started.',
                color: Colors.grey,
              ),
            if (!isLoading && students != null && students!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 16),
                  itemCount: students!.length,
                  itemBuilder: (context, index) {
                    final student = students![index];
                    return _buildStudentCard(student);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
