import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';

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
  final List<String> cmNames;

  UserResponse({required this.users, required this.cmNames});
}

// --- Service ---

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<UserResponse> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // top-level list of all CM names for dropdown
      final cmNames = List<String>.from(
        data['myrank_cm_names'] as List<dynamic>,
      );
      // list of users
      final usersJson = data['users'] as List<dynamic>;
      final users =
          usersJson
              .map((j) => User.fromJson(j as Map<String, dynamic>))
              .toList();
      return UserResponse(users: users, cmNames: cmNames);
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

  Future<void> addUser(String email, String name, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/adduser'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'name': name, 'role': role}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }
}

// --- UI ---

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<UserResponse> futureUserData;
  final UserService userService = UserService(baseUrl: baseurl);

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<String> _roles = [];
  List<String> _cmNames = [];

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String _searchQuery = '';

  late UserDataTableSource _dataSource;

  @override
  void initState() {
    super.initState();
    futureUserData = userService.fetchUsers();
    futureUserData.then((resp) {
      setState(() {
        _allUsers = resp.users;
        _filteredUsers = List.from(_allUsers);
        _cmNames = resp.cmNames;

        // build roles list (known + any extra)
        const knownRoles = [
          'admin',
          'college',
          'doctor',
          'not_assigned',
          'myrank_user',
          'myrank_cm',
        ];
        _roles = List<String>.from(knownRoles);
        final extraRoles = _allUsers.map((u) => u.role).toSet();
        for (var r in extraRoles) {
          if (!_roles.contains(r)) _roles.add(r);
        }

        _dataSource = UserDataTableSource(
          context: context,
          users: _filteredUsers,
          roles: _roles,
          cmNames: _cmNames,
          userService: userService,
          onRoleUpdated: () => setState(() {}),
          onCMNameUpdated: () => setState(() {}),
        );
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
      _dataSource = UserDataTableSource(
        context: context,
        users: _filteredUsers,
        roles: _roles,
        cmNames: _cmNames,
        userService: userService,
        onRoleUpdated: () => setState(() {}),
        onCMNameUpdated: () => setState(() {}),
      );
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

      _dataSource = UserDataTableSource(
        context: context,
        users: _filteredUsers,
        roles: _roles,
        cmNames: _cmNames,
        userService: userService,
        onRoleUpdated: () => setState(() {}),
        onCMNameUpdated: () => setState(() {}),
      );
    });
  }

  void _showAddUserDialog(BuildContext context) {
    final _emailController = TextEditingController();
    final _nameController = TextEditingController();
    String _selectedRole = 'not_assigned';

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
              DropdownButtonFormField<String>(
                value:
                    _roles.contains(_selectedRole)
                        ? _selectedRole
                        : 'not_assigned',
                items:
                    _roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) _selectedRole = val;
                },
                decoration: const InputDecoration(labelText: 'Role'),
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
                    final resp = await userService.fetchUsers();
                    setState(() {
                      _allUsers = resp.users;
                      _filteredUsers = List.from(resp.users);
                      _cmNames = resp.cmNames;

                      final extraRoles = resp.users.map((u) => u.role).toSet();
                      for (var r in extraRoles) {
                        if (!_roles.contains(r)) _roles.add(r);
                      }

                      _dataSource = UserDataTableSource(
                        context: context,
                        users: _filteredUsers,
                        roles: _roles,
                        cmNames: _cmNames,
                        userService: userService,
                        onRoleUpdated: () => setState(() {}),
                        onCMNameUpdated: () => setState(() {}),
                      );
                    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.blue,
      ),
      body:
          _allUsers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
              ? const Center(child: Text('No users found'))
              : Padding(
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
                      child: PaginatedDataTable(
                        header: const Text('Users'),
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10, 20],
                        onRowsPerPageChanged: (rows) {
                          setState(() {
                            if (rows != null) _rowsPerPage = rows;
                          });
                        },
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: [
                          DataColumn(
                            label: const Text('User ID'),
                            numeric: true,
                            onSort:
                                (i, asc) => _sort<num>((u) => u.userId, i, asc),
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
                          DataColumn(
                            label: const Text('CM Name'),
                            // no sort on this one
                          ),
                          DataColumn(
                            label: const Text('Created At'),
                            onSort:
                                (i, asc) =>
                                    _sort<String>((u) => u.createdAt, i, asc),
                          ),
                        ],
                        source: _dataSource,
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class UserDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<User> users;
  final List<String> roles;
  final List<String> cmNames;
  final UserService userService;
  final VoidCallback onRoleUpdated;
  final VoidCallback onCMNameUpdated;

  UserDataTableSource({
    required this.context,
    required this.users,
    required this.roles,
    required this.cmNames,
    required this.userService,
    required this.onRoleUpdated,
    required this.onCMNameUpdated,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    final roleDropdownValue =
        roles.contains(user.role) ? user.role : 'not_assigned';
    final cmDropdownValue = cmNames.contains(user.cmName) ? user.cmName : null;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(user.userId.toString())),
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(
          DropdownButton<String>(
            value: roleDropdownValue,
            items:
                roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
            onChanged: (newRole) async {
              if (newRole != null && newRole != user.role) {
                try {
                  await userService.updateUserRole(user.userId, newRole);
                  user.role = newRole;
                  onRoleUpdated();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update role')),
                  );
                }
              }
            },
          ),
        ),
        DataCell(
          DropdownButton<String>(
            hint: const Text('Select CM'),
            value: cmDropdownValue,
            items:
                cmNames
                    .map((cm) => DropdownMenuItem(value: cm, child: Text(cm)))
                    .toList(),
            onChanged: (newCm) async {
              if (newCm != null && newCm != user.cmName) {
                try {
                  await userService.updateUserCMName(user.userId, newCm);
                  user.cmName = newCm;
                  onCMNameUpdated();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CM Name updated successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update CM Name')),
                  );
                }
              }
            },
          ),
        ),
        DataCell(Text(user.createdAt)),
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
