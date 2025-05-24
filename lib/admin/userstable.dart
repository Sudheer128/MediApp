import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final int userId;
  final String name;
  final String email;
  String role;
  final String createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }
}

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<User>> futureUsers;
  final UserService userService = UserService(
    baseUrl: 'http://192.168.0.103:8080',
  );

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String _searchQuery = '';

  // Roles including known defaults
  final List<String> _knownRoles = [
    'admin',
    'college',
    'doctor',
    'not_assigned',
  ];

  late List<String> _roles;

  @override
  void initState() {
    super.initState();
    futureUsers = userService.fetchUsers();
    futureUsers.then((users) {
      setState(() {
        _allUsers = users;
        _filteredUsers = List.from(_allUsers);
        // Combine known roles + any new roles found dynamically
        final userRoles = users.map((u) => u.role).toSet();
        _roles = List<String>.from(_knownRoles);
        for (var r in userRoles) {
          if (!_roles.contains(r)) _roles.add(r);
        }
      });
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
                user.createdAt.toLowerCase().contains(query) ||
                user.userId.toString().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_filteredUsers.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PaginatedDataTable(
                header: Text('Users'),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: [5, 10, 20],
                onRowsPerPageChanged: (rows) {
                  setState(() {
                    if (rows != null) _rowsPerPage = rows;
                  });
                },
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                    label: Text('User ID'),
                    numeric: true,
                    onSort:
                        (columnIndex, ascending) => _sort<num>(
                          (user) => user.userId,
                          columnIndex,
                          ascending,
                        ),
                  ),
                  DataColumn(
                    label: Text('Name'),
                    onSort:
                        (columnIndex, ascending) => _sort<String>(
                          (user) => user.name,
                          columnIndex,
                          ascending,
                        ),
                  ),
                  DataColumn(
                    label: Text('Email'),
                    onSort:
                        (columnIndex, ascending) => _sort<String>(
                          (user) => user.email,
                          columnIndex,
                          ascending,
                        ),
                  ),
                  DataColumn(
                    label: Text('Role'),
                    onSort:
                        (columnIndex, ascending) => _sort<String>(
                          (user) => user.role,
                          columnIndex,
                          ascending,
                        ),
                  ),
                  DataColumn(
                    label: Text('Created At'),
                    onSort:
                        (columnIndex, ascending) => _sort<String>(
                          (user) => user.createdAt,
                          columnIndex,
                          ascending,
                        ),
                  ),
                  DataColumn(label: Text('Actions')),
                ],
                source: UserDataTableSource(
                  context: context,
                  users: _filteredUsers,
                  roles: _roles,
                  userService: userService,
                  onRoleUpdated: () {
                    setState(() {});
                  },
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () => _showAddUserDialog(context),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final _emailController = TextEditingController();
    final _nameController = TextEditingController();
    String _selectedRole = 'not_assigned';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<String>(
                value:
                    _roles.contains(_selectedRole)
                        ? _selectedRole
                        : 'not_assigned',
                items:
                    _roles
                        .map(
                          (role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) _selectedRole = val;
                },
                decoration: InputDecoration(labelText: 'Role'),
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
                    await userService.addUser(email, name, _selectedRole);
                    final users = await userService.fetchUsers();
                    setState(() {
                      _allUsers = users;
                      _filteredUsers = List.from(users);

                      // Update roles with any new roles added by backend
                      final userRoles = users.map((u) => u.role).toSet();
                      for (var r in userRoles) {
                        if (!_roles.contains(r)) _roles.add(r);
                      }
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add user')),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class UserDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<User> users;
  final List<String> roles;
  final UserService userService;
  final VoidCallback onRoleUpdated;

  UserDataTableSource({
    required this.context,
    required this.users,
    required this.roles,
    required this.userService,
    required this.onRoleUpdated,
  });

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) return null!;
    final user = users[index];

    // Safe dropdown value fallback
    final dropdownValue =
        roles.contains(user.role) ? user.role : 'not_assigned';

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(user.userId.toString())),
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(
          DropdownButton<String>(
            value: dropdownValue,
            items:
                roles
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      ),
                    )
                    .toList(),
            onChanged: (newRole) async {
              if (newRole != null && newRole != user.role) {
                try {
                  await userService.updateUserRole(user.userId, newRole);
                  user.role = newRole;
                  onRoleUpdated();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Role updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update role')),
                  );
                }
              }
            },
          ),
        ),
        DataCell(Text(user.createdAt)),
        DataCell(
          Row(
            children: [
              // Add buttons here if needed (e.g. edit/delete)
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['users'];
      return data.map((json) => User.fromJson(json)).toList();
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

  Future<void> addUser(String email, String name, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'name': name, 'role': role}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }
}
