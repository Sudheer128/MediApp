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

class CmInterestsPage extends StatefulWidget {
  const CmInterestsPage({Key? key}) : super(key: key);

  @override
  _CmInterestsPageState createState() => _CmInterestsPageState();
}

class _CmInterestsPageState extends State<CmInterestsPage> {
  List<Interest> _allInterests = [];
  List<Interest> _filteredInterests = [];

  static const Color primaryBlue = Color.fromARGB(255, 250, 110, 110);

  bool _isLoading = false;
  String? _error;

  int _rowsPerPage = 10;
  int _currentPage = 0;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  String _searchQuery = '';

  late ScrollController _scrollController;

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
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('name') ?? 'Admin';

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse("$baseurl/interests/cm?cm_name=$savedName"),
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
      _currentPage = 0; // reset page on sort
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
      _currentPage = 0; // reset page on filter
    });
  }

  int get _totalPages => (_filteredInterests.length / _rowsPerPage).ceil();

  List<Interest> get _currentPageItems {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return _filteredInterests.sublist(
      start,
      end > _filteredInterests.length ? _filteredInterests.length : end,
    );
  }

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
        title: const Text('College Interests'),
        backgroundColor: primaryBlue,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
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
                        child: DataTable(
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          columns: [
                            DataColumn(
                              label: const Text('ID'),
                              numeric: true,
                              onSort:
                                  (i, asc) => _sort<num>((d) => d.id, i, asc),
                            ),
                            DataColumn(
                              label: const Text('College ID'),
                              numeric: true,
                              onSort:
                                  (i, asc) =>
                                      _sort<num>((d) => d.collegeId, i, asc),
                            ),
                            DataColumn(
                              label: const Text('College Name'),
                              onSort:
                                  (i, asc) => _sort<String>(
                                    (d) => d.collegeName,
                                    i,
                                    asc,
                                  ),
                            ),
                            DataColumn(
                              label: const Text('Student ID'),
                              numeric: true,
                              onSort:
                                  (i, asc) =>
                                      _sort<num>((d) => d.studentId, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Student Name'),
                              onSort:
                                  (i, asc) => _sort<String>(
                                    (d) => d.studentName,
                                    i,
                                    asc,
                                  ),
                            ),
                            DataColumn(
                              label: const Text('Course Name'),
                              onSort:
                                  (i, asc) => _sort<String>(
                                    (d) => d.courseName,
                                    i,
                                    asc,
                                  ),
                            ),
                            DataColumn(
                              label: const Text('Degree'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((d) => d.degree, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Message'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((d) => d.message, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Status'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((d) => d.status, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Created At'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((d) => d.createdAt, i, asc),
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Text('<|', style: TextStyle(fontSize: 18)),
                        onPressed: _currentPage == 0 ? null : _goToFirstPage,
                      ),
                      IconButton(
                        icon: const Text('<', style: TextStyle(fontSize: 18)),
                        onPressed: _currentPage == 0 ? null : _goToPreviousPage,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Page ${_currentPage + 1} of $_totalPages'),
                      ),
                      IconButton(
                        icon: const Text('>', style: TextStyle(fontSize: 18)),
                        onPressed:
                            _currentPage >= _totalPages - 1
                                ? null
                                : _goToNextPage,
                      ),
                      IconButton(
                        icon: const Text('>|', style: TextStyle(fontSize: 18)),
                        onPressed:
                            _currentPage >= _totalPages - 1
                                ? null
                                : _goToLastPage,
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<int>(
                        value: _rowsPerPage,
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 rows')),
                          DropdownMenuItem(value: 10, child: Text('10 rows')),
                          DropdownMenuItem(value: 20, child: Text('20 rows')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _rowsPerPage = value;
                              _currentPage =
                                  0; // reset page when rows per page changes
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
    );
  }
}
