import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Interest {
  final int id;
  final int collegeId;
  final String collegeName;
  final int studentId;
  final String studentName;
  final String courseName;
  final String degree;
  final String message;
  final String status;
  final String createdAt;

  Interest({
    required this.id,
    required this.collegeId,
    required this.collegeName,
    required this.studentId,
    required this.studentName,
    required this.courseName,
    required this.degree,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      collegeId: json['college_id'],
      collegeName: json['college_name'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      courseName: json['course_name'],
      degree: json['degree'],
      message: json['message'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}

class CollegeInterestsPage extends StatefulWidget {
  const CollegeInterestsPage({Key? key}) : super(key: key);

  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<CollegeInterestsPage> {
  List<Interest> _allInterests = [];
  List<Interest> _filteredInterests = [];

  bool _isLoading = false;
  String? _error;

  int _rowsPerPage = 10; // Number of rows per page
  int _currentPage = 0;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  String _searchQuery = '';

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchInterests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInterests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    try {
      final response = await http.get(
        Uri.parse("$baseurl/get-college-interests?college_user_id=$userId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> interestList = data['interests'];

        setState(() {
          _allInterests =
              interestList.map((e) => Interest.fromJson(e)).toList();
          _filteredInterests = List.from(_allInterests);
          _currentPage = 0;
        });
      } else {
        throw Exception('Failed to load data: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sort<T>(
    Comparable<T> Function(Interest interest) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filteredInterests.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _currentPage = 0; // Reset to first page on sort
    });
  }

  void _filterInterests(String query) {
    query = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredInterests =
          _allInterests.where((interest) {
            return interest.collegeName.toLowerCase().contains(query) ||
                interest.studentName.toLowerCase().contains(query) ||
                interest.courseName.toLowerCase().contains(query) ||
                interest.degree.toLowerCase().contains(query) ||
                interest.message.toLowerCase().contains(query) ||
                interest.status.toLowerCase().contains(query) ||
                interest.createdAt.toLowerCase().contains(query) ||
                interest.id.toString().contains(query) ||
                interest.collegeId.toString().contains(query) ||
                interest.studentId.toString().contains(query);
          }).toList();
      _currentPage = 0; // Reset page on filter
    });
  }

  // Get current page items
  List<Interest> get _currentPageItems {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return _filteredInterests.sublist(
      startIndex,
      endIndex > _filteredInterests.length
          ? _filteredInterests.length
          : endIndex,
    );
  }

  // Calculate total pages
  int get _totalPages => (_filteredInterests.length / _rowsPerPage).ceil();

  void _goToFirstPage() {
    if (_currentPage != 0) {
      setState(() {
        _currentPage = 0;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToLastPage() {
    if (_currentPage != _totalPages - 1) {
      setState(() {
        _currentPage = _totalPages - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('College Interests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _filterInterests,
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            DataTable(
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              columns: [
                                DataColumn(
                                  label: Text('ID'),
                                  numeric: true,
                                  onSort:
                                      (i, asc) =>
                                          _sort<num>((d) => d.id, i, asc),
                                ),
                                DataColumn(
                                  label: Text('College ID'),
                                  numeric: true,
                                  onSort:
                                      (i, asc) => _sort<num>(
                                        (d) => d.collegeId,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('College Name'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.collegeName,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Student ID'),
                                  numeric: true,
                                  onSort:
                                      (i, asc) => _sort<num>(
                                        (d) => d.studentId,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Student Name'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.studentName,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Course Name'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.courseName,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Degree'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.degree,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Message'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.message,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Status'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.status,
                                        i,
                                        asc,
                                      ),
                                ),
                                DataColumn(
                                  label: Text('Created At'),
                                  onSort:
                                      (i, asc) => _sort<String>(
                                        (d) => d.createdAt,
                                        i,
                                        asc,
                                      ),
                                ),
                              ],
                              rows:
                                  _currentPageItems.map((interest) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(interest.id.toString())),
                                        DataCell(
                                          Text(interest.collegeId.toString()),
                                        ),
                                        DataCell(Text(interest.collegeName)),
                                        DataCell(
                                          Text(interest.studentId.toString()),
                                        ),
                                        DataCell(Text(interest.studentName)),
                                        DataCell(Text(interest.courseName)),
                                        DataCell(Text(interest.degree)),
                                        DataCell(Text(interest.message)),
                                        DataCell(Text(interest.status)),
                                        DataCell(Text(interest.createdAt)),
                                      ],
                                    );
                                  }).toList(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Text(
                                      '<|',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed:
                                        _currentPage == 0
                                            ? null
                                            : _goToFirstPage,
                                    tooltip: 'First Page',
                                  ),
                                  IconButton(
                                    icon: Text(
                                      '<',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed:
                                        _currentPage == 0
                                            ? null
                                            : _goToPreviousPage,
                                    tooltip: 'Previous Page',
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Text(
                                      'Page ${_currentPage + 1} of $_totalPages',
                                    ),
                                  ),
                                  IconButton(
                                    icon: Text(
                                      '>',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed:
                                        _currentPage >= _totalPages - 1
                                            ? null
                                            : _goToNextPage,
                                    tooltip: 'Next Page',
                                  ),
                                  IconButton(
                                    icon: Text(
                                      '>|',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed:
                                        _currentPage >= _totalPages - 1
                                            ? null
                                            : _goToLastPage,
                                    tooltip: 'Last Page',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
