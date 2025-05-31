import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';

class LoginLog {
  final String userId;
  final String email;
  final String role;
  final String ipAddress;
  final String name;
  final String loginTime;

  LoginLog({
    required this.userId,
    required this.email,
    required this.role,
    required this.ipAddress,
    required this.name,
    required this.loginTime,
  });

  factory LoginLog.fromJson(Map<String, dynamic> json) {
    return LoginLog(
      userId: json['user_id'].toString(), // Convert to string if needed
      email: json['email'],
      role: json['role'],
      ipAddress: json['ip_address'],
      name: json['name'],
      loginTime: json['login_time'],
    );
  }
}

class LoginLogsPage extends StatefulWidget {
  const LoginLogsPage({Key? key}) : super(key: key);

  @override
  _LoginLogsPageState createState() => _LoginLogsPageState();
}

class _LoginLogsPageState extends State<LoginLogsPage> {
  List<LoginLog> _allLogs = [];
  List<LoginLog> _filteredLogs = [];

  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseurl/get-login-logs'));
      if (response.statusCode == 200) {
        // Direct array response, no need to access ['logs']
        final List<dynamic> logs = json.decode(response.body);
        setState(() {
          _allLogs = logs.map((e) => LoginLog.fromJson(e)).toList();
          _filteredLogs = List.from(_allLogs);
        });
      } else {
        throw Exception('Failed to load logs');
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

  void _filterLogs(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredLogs =
          _allLogs.where((log) {
            return log.userId.contains(query) ||
                log.email.toLowerCase().contains(query) ||
                log.role.toLowerCase().contains(query) ||
                log.ipAddress.contains(query) ||
                log.name.toLowerCase().contains(query) ||
                log.loginTime.toLowerCase().contains(query);
          }).toList();
      _currentPage = 0;
    });
  }

  void _sort<T>(
    Comparable<T> Function(LoginLog log) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filteredLogs.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  int get _totalPages => (_filteredLogs.length / _rowsPerPage).ceil();

  List<LoginLog> get _currentPageItems {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _filteredLogs.length);
    return _filteredLogs.sublist(start, end);
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Logs'),
        backgroundColor: Colors.blue,
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
                      onChanged: _filterLogs,
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAscending,
                            columns: [
                              DataColumn(
                                label: const Text('User ID'),
                                onSort:
                                    (i, asc) => _sort((d) => d.userId, i, asc),
                              ),
                              DataColumn(
                                label: const Text('Name'),
                                onSort:
                                    (i, asc) => _sort((d) => d.name, i, asc),
                              ),
                              DataColumn(
                                label: const Text('Email'),
                                onSort:
                                    (i, asc) => _sort((d) => d.email, i, asc),
                              ),
                              DataColumn(
                                label: const Text('Role'),
                                onSort:
                                    (i, asc) => _sort((d) => d.role, i, asc),
                              ),
                              DataColumn(
                                label: const Text('IP Address'),
                                onSort:
                                    (i, asc) =>
                                        _sort((d) => d.ipAddress, i, asc),
                              ),
                              DataColumn(
                                label: const Text('Login Time'),
                                onSort:
                                    (i, asc) =>
                                        _sort((d) => d.loginTime, i, asc),
                              ),
                            ],
                            rows:
                                _currentPageItems.map((log) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(log.userId)),
                                      DataCell(Text(log.name)),
                                      DataCell(Text(log.email)),
                                      DataCell(Text(log.role)),
                                      DataCell(Text(log.ipAddress)),
                                      DataCell(Text(log.loginTime)),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Text('<|'),
                        onPressed:
                            _currentPage == 0 ? null : () => _goToPage(0),
                      ),
                      IconButton(
                        icon: const Text('<'),
                        onPressed:
                            _currentPage == 0
                                ? null
                                : () => _goToPage(_currentPage - 1),
                      ),
                      Text('Page ${_currentPage + 1} of $_totalPages'),
                      IconButton(
                        icon: const Text('>'),
                        onPressed:
                            _currentPage >= _totalPages - 1
                                ? null
                                : () => _goToPage(_currentPage + 1),
                      ),
                      IconButton(
                        icon: const Text('>|'),
                        onPressed:
                            _currentPage >= _totalPages - 1
                                ? null
                                : () => _goToPage(_totalPages - 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
    );
  }
}
