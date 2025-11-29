import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';

class JobApply {
  final int jobId;
  final String appliedOn;
  final String jobTitle;
  final String organization;
  final String studentName;
  final String studentEmail;
  final int userId; // Added

  JobApply({
    required this.jobId,
    required this.appliedOn,
    required this.jobTitle,
    required this.organization,
    required this.studentName,
    required this.studentEmail,
    required this.userId,
  });

  factory JobApply.fromJson(Map<String, dynamic> json) {
    return JobApply(
      jobId: json['job_id'],
      appliedOn: json['applied_on'],
      jobTitle: json['job_title'],
      organization: json['organization'],
      studentName: json['student_name'],
      studentEmail: json['student_email'],
      userId: json['user_id'] ?? 0, // Mapping
    );
  }
}

class JobApplies extends StatefulWidget {
  @override
  _JobAppliesState createState() => _JobAppliesState();
}

class _JobAppliesState extends State<JobApplies> {
  List<JobApply> jobApplies = [];
  List<JobApply> filteredList = [];
  bool isLoading = true;
  int _sortColumnIndex = 0;
  bool _ascending = true;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse("$baseurl/jobs/applied"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<JobApply> loadedData =
          (data['data'] as List).map((e) => JobApply.fromJson(e)).toList();

      setState(() {
        jobApplies = loadedData;
        filteredList = loadedData;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void sortData(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _ascending = ascending;

      filteredList.sort((a, b) {
        switch (columnIndex) {
          case 0:
            return ascending
                ? a.jobId.compareTo(b.jobId)
                : b.jobId.compareTo(a.jobId);
          case 1:
            return ascending
                ? a.appliedOn.compareTo(b.appliedOn)
                : b.appliedOn.compareTo(a.appliedOn);
          case 2:
            return ascending
                ? a.jobTitle.compareTo(b.jobTitle)
                : b.jobTitle.compareTo(a.jobTitle);
        }
        return 0;
      });
    });
  }

  void search(String query) {
    setState(() {
      filteredList =
          jobApplies.where((item) {
            return item.jobTitle.toLowerCase().contains(query.toLowerCase()) ||
                item.studentName.toLowerCase().contains(query.toLowerCase()) ||
                item.organization.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Applications")),

      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      onChanged: search,
                      decoration: InputDecoration(
                        labelText: "Search...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _ascending,
                        columns: [
                          DataColumn(
                            label: Text("Job ID"),
                            onSort: (i, asc) => sortData(i, asc),
                          ),
                          DataColumn(
                            label: Text("Applied On"),
                            onSort: (i, asc) => sortData(i, asc),
                          ),
                          DataColumn(
                            label: Text("Job Title"),
                            onSort: (i, asc) => sortData(i, asc),
                          ),
                          DataColumn(label: Text("Organization")),
                          DataColumn(label: Text("Student Name")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Job")),
                          DataColumn(label: Text("Profile")), // NEW COLUMN
                        ],
                        rows:
                            filteredList.map((job) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(job.jobId.toString())),
                                  DataCell(Text(job.appliedOn)),
                                  DataCell(Text(job.jobTitle)),
                                  DataCell(Text(job.organization)),
                                  DataCell(Text(job.studentName)),
                                  DataCell(Text(job.studentEmail)),

                                  /// VIEW JOB BUTTON
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        if (kIsWeb) {
                                          context.go(
                                            '/job-details/${job.jobId}',
                                          );
                                        } else {
                                          context.push(
                                            '/job-details/${job.jobId}',
                                          );
                                        }
                                      },
                                      child: Text("View Job"),
                                    ),
                                  ),

                                  /// VIEW PROFILE BUTTON
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        if (kIsWeb) {
                                          context.go(
                                            '/doctor_profile/${job.userId}',
                                          );
                                        } else {
                                          context.push(
                                            '/doctor_profile/${job.userId}',
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(),
                                      child: Text("View Profile"),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
