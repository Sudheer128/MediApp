import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/url.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic>? students;
  bool isLoading = false;
  bool hasSearched = false;
  static const Color primaryBlue = Color(0xFF0A66C2); // LinkedIn blue
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
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final response = await http.get(Uri.parse('$baseurl/search?query=$query'));
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

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (query) => fetchStudents(query),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          hintText: 'Search by name, email, or phone',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey.shade600),
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
        style: TextStyle(fontSize: 16, color: Colors.black87),
        onChanged: (value) {
          setState(() {}); // update clear icon visibility
        },
      ),
    );
  }

  void navigateToAdminEdit(BuildContext context, String userId) {
    if (kIsWeb) {
      context.go('/doctor_profile/$userId');
    } else {
      context.push('/doctor_profile/$userId');
    }
  }

  Widget _buildProfileCard(dynamic student) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          navigateToAdminEdit(context, student['user_id'].toString());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipOval(
                  child:
                      student['profile_image'] != null &&
                              student['profile_image'].toString().isNotEmpty
                          ? Image.network(
                            student['profile_image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade600,
                              );
                            },
                          )
                          : Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                ),
              ),
              SizedBox(width: 16),
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    if (student['headline'] != null &&
                        student['headline'].toString().isNotEmpty)
                      Text(
                        student['headline'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (student['headline'] == null ||
                        student['headline'].toString().isEmpty)
                      Text(
                        'Medical Professional',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            student['location'] ?? 'Location not specified',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    if (student['email'] != null &&
                        student['email'].toString().isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              student['email'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (student['mutual_connections'] != null &&
                        student['mutual_connections'] > 0) ...[
                      SizedBox(height: 8),
                      Text(
                        '${student['mutual_connections']} mutual connections',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Connect Button
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Connect action
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBlue,
                      side: BorderSide(color: primaryBlue, width: 1.5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Connect',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
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
            Icon(icon, size: 80, color: color ?? Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: color ?? Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Shimmer
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(width: 16),
            // Profile Info Shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 13,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Container(
              height: 32,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Divider(height: 1, color: Colors.grey.shade300),
            if (isLoading)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildShimmerCard(),
                ),
              ),
            if (!isLoading &&
                hasSearched &&
                (students == null || students!.isEmpty))
              _buildEmptyState(
                Icons.search_off,
                'No results found\nTry searching with different keywords',
              ),
            if (!isLoading && !hasSearched)
              _buildEmptyState(
                Icons.search,
                'Search for medical professionals',
                color: Colors.grey.shade500,
              ),
            if (!isLoading && students != null && students!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: students!.length,
                  itemBuilder: (context, index) {
                    final student = students![index];
                    return _buildProfileCard(student);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
