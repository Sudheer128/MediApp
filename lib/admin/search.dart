import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/admin/searchstudent.dart';
import 'package:medicalapp/url.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic>? students;
  bool isLoading = false;
  bool hasSearched = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Students'),
        backgroundColor: Colors.blue,
        elevation: 2.0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Colors.blue[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: () => fetchStudents(_searchController.text),
                  ),
                ),
                onSubmitted: (query) => fetchStudents(query),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blue))
                : hasSearched && (students == null || students!.isEmpty)
                ? Expanded(
                  child: Center(
                    child: Text(
                      'No Data Available',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                : students != null && students!.isNotEmpty
                ? Expanded(
                  child: ListView.builder(
                    itemCount: students!.length,
                    itemBuilder: (context, index) {
                      final student = students![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AdminEditForm(userId: student['user_id']),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: Colors.blue[50],
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(
                              student['name'],
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email: ${student['email']}',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                                Text(
                                  'Phone: ${student['phone']}',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
                : Expanded(
                  child: Center(
                    child: Text(
                      'Please search for students.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
