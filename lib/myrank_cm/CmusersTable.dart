import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/myrank_cm/studentdetails.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Models ---

class User {
  final int userId;
  final String name;
  final String email;
  String role;
  String cmName;
  final String createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.cmName,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      cmName: json['cm_name'] ?? '',
      createdAt: json['created_at'],
    );
  }
}

class UserResponse {
  final List<User> users;

  UserResponse({required this.users});
}

// --- Service ---

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<UserResponse> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('name') ?? 'Admin';
    final response = await http.get(
      Uri.parse('$baseUrl/myrank-cm/users?cm_name=$savedName'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final usersJson = data['users'];
      if (usersJson == null) {
        return UserResponse(users: []);
      }

      final users =
          (usersJson as List<dynamic>).map((j) => User.fromJson(j)).toList();

      return UserResponse(users: users);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> updateUserRole(int userId, String role) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'role': role}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update role');
    }
  }

  Future<void> updateUserCMName(int userId, String cmName) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/cm_name'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cm_name': cmName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update CM Name');
    }
  }

  Future<void> addUser(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('name') ?? 'Admin';
    final response = await http.post(
      Uri.parse('$baseUrl/myrank-cm/adduser'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'name': name, 'cmname': savedName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }
}

// --- UI ---

class CmManagementPage extends StatefulWidget {
  const CmManagementPage({super.key});

  @override
  State<CmManagementPage> createState() => _CmManagementPageState();
}

class _CmManagementPageState extends State<CmManagementPage> {
  late Future<UserResponse> futureUserData;
  final UserService userService = UserService(baseUrl: baseurl);

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  int _rowsPerPage = 10;
  int _currentPage = 0;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  String _searchQuery = '';

  late ScrollController _scrollController;

  static const Color primaryBlue = Color.fromARGB(255, 250, 110, 110);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    futureUserData = userService.fetchUsers();
    final resp = await futureUserData;
    setState(() {
      _allUsers = resp.users;
      _filteredUsers = List.from(_allUsers);
      _currentPage = 0;
    });
  }

  void _sort<T>(
    Comparable<T> Function(User user) getField,
    int columnIndex,
    bool ascending,
  ) {
    _filteredUsers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _currentPage = 0; // Reset page on sort
    });
  }

  void _filterUsers(String query) {
    query = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredUsers =
          _allUsers.where((user) {
            return user.name.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query) ||
                user.role.toLowerCase().contains(query) ||
                user.cmName.toLowerCase().contains(query) ||
                user.createdAt.toLowerCase().contains(query) ||
                user.userId.toString().contains(query);
          }).toList();
      _currentPage = 0; // Reset page on filter
    });
  }

  int get _totalPages => (_filteredUsers.length / _rowsPerPage).ceil();

  List<User> get _currentPageItems {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return _filteredUsers.sublist(
      start,
      end > _filteredUsers.length ? _filteredUsers.length : end,
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

  void _showAddUserDialog(BuildContext context) {
    final _emailController = TextEditingController();
    final _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                final name = _nameController.text.trim();
                if (email.isNotEmpty && name.isNotEmpty) {
                  try {
                    await userService.addUser(email, name);
                    await _loadUsers();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add user')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: FutureBuilder<UserResponse>(
        future: futureUserData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: _filterUsers,
                  ),
                  const SizedBox(height: 16),
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
                              label: const Text('User ID'),
                              numeric: true,
                              onSort:
                                  (i, asc) =>
                                      _sort<num>((u) => u.userId, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Name'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((u) => u.name, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Email'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((u) => u.email, i, asc),
                            ),
                            DataColumn(
                              label: const Text('Role'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((u) => u.role, i, asc),
                            ),
                            DataColumn(label: const Text('CM Name')),
                            DataColumn(
                              label: const Text('Created At'),
                              onSort:
                                  (i, asc) =>
                                      _sort<String>((u) => u.createdAt, i, asc),
                            ),
                          ],
                          rows:
                              _currentPageItems.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user.userId.toString())),
                                    DataCell(Text(user.name)),
                                    DataCell(Text(user.email)),
                                    DataCell(Text(user.role)),
                                    DataCell(
                                      Text(
                                        user.cmName.isNotEmpty
                                            ? user.cmName
                                            : '-',
                                      ),
                                    ),
                                    DataCell(Text(user.createdAt)),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 56, // default FAB width is 56
                      height: 56, // default FAB height is 56
                      child: FloatingActionButton(
                        onPressed: () => _showAddUserDialog(context),
                        child: const Icon(Icons.person_add),
                        backgroundColor: kPrimaryColor,
                        heroTag: 'addUserButton',
                        elevation: 4,
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
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
