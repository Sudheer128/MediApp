import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicalapp/extranew/jobdetails.dart';
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  List jobs = [];
  bool loading = true;
  String searchQuery = '';
  String selectedFilter = 'All';
  Set<int> savedJobs = {};
  String Roleee = "";
  int userId = 0;

  // Track which view is active: 'all', 'applied', or 'saved'
  String activeView = 'all';
  List appliedJobs = [];
  List savedJobsList = [];
  bool loadingApplied = false;
  bool loadingSaved = false;

  @override
  void initState() {
    super.initState();
    loadRole();
    loadUserId();
    fetchJobs();
  }

  Future<void> loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? "";
    setState(() {
      Roleee = role;
    });
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userid') ?? 0;
    setState(() {
      userId = id;
    });
  }

  Future<void> fetchJobs() async {
    final response = await http.get(Uri.parse("$baseurl/get-all-jobs"));

    if (response.statusCode == 200) {
      setState(() {
        jobs = json.decode(response.body)['jobs'];
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> fetchAppliedJobs() async {
    if (userId == 0) return;

    setState(() {
      loadingApplied = true;
      activeView = 'applied';
    });

    try {
      final response = await http.get(
        Uri.parse("$baseurl/student/appliedJobs?user_id=$userId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          appliedJobs = data['jobs'] ?? [];
          loadingApplied = false;
        });
      } else {
        setState(() {
          appliedJobs = [];
          loadingApplied = false;
        });
      }
    } catch (e) {
      setState(() {
        appliedJobs = [];
        loadingApplied = false;
      });
    }
  }

  Future<void> fetchSavedJobs() async {
    if (userId == 0) return;

    setState(() {
      loadingSaved = true;
      activeView = 'saved';
    });

    try {
      final response = await http.get(
        Uri.parse("$baseurl/student/savedJobs?user_id=$userId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          savedJobsList = data['jobs'] ?? [];
          loadingSaved = false;
        });
      } else {
        setState(() {
          savedJobsList = [];
          loadingSaved = false;
        });
      }
    } catch (e) {
      setState(() {
        savedJobsList = [];
        loadingSaved = false;
      });
    }
  }

  List get filteredJobs {
    return jobs.where((job) {
      final matchesSearch =
          job['job_title'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          job['organization'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      final matchesFilter =
          selectedFilter == 'All' ||
          job['job_type'].toString() == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Color(0xFFF3F2EF),
      body:
          loading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
                ),
              )
              : isWeb
              ? _buildWebLayout()
              : _buildMobileLayout(),
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1128),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildFiltersSidebar()),
            SizedBox(width: 16),
            Expanded(flex: 7, child: _buildJobsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [_buildSearchAndFilters(), Expanded(child: _buildJobsList())],
    );
  }

  Widget _buildFiltersSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildFilterSection('Job Type', [
            'All',
            'Full Time',
            'Part Time',
            'Contract',
            'Internship',
          ]),
          SizedBox(height: 20),
          Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        ...options.map((option) => _buildFilterOption(option)).toList(),
      ],
    );
  }

  Widget _buildFilterOption(String option) {
    final isSelected = selectedFilter == option;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = option;
          activeView = 'all'; // Reset to all jobs when filter changes
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF0A66C2) : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              option,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Color(0xFFEEF3F8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search jobs',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 12),
          // Filter dropdown and action buttons
          Row(
            children: [
              // Filter dropdown (compact size)
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0A66C2)),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    items:
                        [
                          'All',
                          'Full Time',
                          'Part Time',
                          'Contract',
                          'Internship',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedFilter = newValue;
                          activeView = 'all';
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Conditionally show buttons for doctors
              if (Roleee == 'doctor') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: fetchAppliedJobs,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          activeView == 'applied'
                              ? Colors.white
                              : Color(0xFF0A66C2),
                      backgroundColor:
                          activeView == 'applied'
                              ? Color(0xFF0A66C2)
                              : Colors.white,
                      side: BorderSide(color: Color(0xFF0A66C2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Applied Jobs',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 8),
                // Expanded(
                //   child: OutlinedButton(
                //     onPressed: fetchSavedJobs,
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor:
                //           activeView == 'saved'
                //               ? Colors.white
                //               : Color(0xFF0A66C2),
                //       backgroundColor:
                //           activeView == 'saved'
                //               ? Color(0xFF0A66C2)
                //               : Colors.white,
                //       side: BorderSide(color: Color(0xFF0A66C2)),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(4),
                //       ),
                //       padding: EdgeInsets.symmetric(vertical: 12),
                //     ),
                //     child: Text(
                //       'Saved Jobs',
                //       style: TextStyle(
                //         fontSize: 13,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    // Determine which list to display
    List displayJobs;
    bool isLoading;

    if (activeView == 'applied') {
      displayJobs = appliedJobs;
      isLoading = loadingApplied;
    } else if (activeView == 'saved') {
      displayJobs = savedJobsList;
      isLoading = loadingSaved;
    } else {
      displayJobs = filteredJobs;
      isLoading = false;
    }

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (activeView == 'applied') {
          await fetchAppliedJobs();
        } else if (activeView == 'saved') {
          await fetchSavedJobs();
        } else {
          await fetchJobs();
        }
      },
      child:
          displayJobs.isEmpty
              ? ListView(
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.work_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          activeView == 'applied'
                              ? 'No applied jobs yet'
                              : activeView == 'saved'
                              ? 'No saved jobs yet'
                              : 'No jobs found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          activeView == 'all'
                              ? 'Try adjusting your search or filters'
                              : 'Start exploring jobs to build your list',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: displayJobs.length,
                itemBuilder: (context, index) {
                  final job = displayJobs[index];
                  return JobCard(
                    job: job,
                    isSaved: savedJobs.contains(job['id']),
                    isApplied: activeView == 'applied',
                    isSavedView: activeView == 'saved',
                    onSave: () {
                      setState(() {
                        if (savedJobs.contains(job['id'])) {
                          savedJobs.remove(job['id']);
                        } else {
                          savedJobs.add(job['id']);
                        }
                      });
                    },
                  );
                },
              ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Map job;
  final bool isSaved;
  final bool isApplied;
  final bool isSavedView;
  final VoidCallback onSave;

  const JobCard({
    required this.job,
    required this.isSaved,
    required this.onSave,
    this.isApplied = false,
    this.isSavedView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isApplied || isSavedView ? Color(0xFF0A66C2) : Color(0xFFE0E0E0),
          width: isApplied || isSavedView ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (kIsWeb) {
            context.go('/job-details/${job['id']}');
          } else {
            context.push('/job-details/${job['id']}');
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge for applied/saved
              if (isApplied || isSavedView)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFE7F3FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isApplied ? Icons.check_circle : Icons.bookmark,
                        size: 14,
                        color: Color(0xFF0A66C2),
                      ),
                      SizedBox(width: 4),
                      Text(
                        isApplied ? 'Applied' : 'Saved',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0A66C2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.business,
                      size: 24,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Job info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['job_title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          job['organization'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              job['location'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  if (!isApplied && !isSavedView)
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color:
                            isSaved ? Color(0xFF0A66C2) : Colors.grey.shade600,
                      ),
                      onPressed: onSave,
                    ),
                ],
              ),
              SizedBox(height: 12),
              // Job details
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoPill(Icons.work_outline, job['job_type']),
                  _buildInfoPill(
                    Icons.account_balance_wallet_outlined,
                    _getSalaryDisplay(job),
                  ),
                  _buildInfoPill(
                    Icons.category_outlined,
                    '${job['category']} • ${job['department']}',
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Application deadline
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: Color(0xFFE67700)),
                    SizedBox(width: 6),
                    Text(
                      'Apply before: ${job['application_deadline']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE67700),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade300),
              SizedBox(height: 12),
              // Footer with promoted info and apply button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted 2 days ago',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () {
                      if (kIsWeb) {
                        context.go('/job-details/${job['id']}');
                      } else {
                        context.push('/job-details/${job['id']}');
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF0A66C2),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'View details',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildInfoPill(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF3F2EF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  String _getSalaryDisplay(Map job) {
    final salaryMin = job['salary_min'];
    final salaryMax = job['salary_max'];

    final isMinEmpty =
        salaryMin == null ||
        salaryMin.toString().isEmpty ||
        salaryMin.toString() == '0';
    final isMaxEmpty =
        salaryMax == null ||
        salaryMax.toString().isEmpty ||
        salaryMax.toString() == '0';

    if (isMinEmpty && isMaxEmpty) {
      return 'Not Disclosed';
    }

    return '₹${salaryMin} - ₹${salaryMax}';
  }
}
