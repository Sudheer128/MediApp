import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicalapp/extranew/jobdetails.dart';
import 'package:medicalapp/extranew/jobnotification.dart';
import 'package:medicalapp/url.dart';

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

  @override
  void initState() {
    super.initState();
    fetchJobs();
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
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   title: Text(
      //     'Jobs',
      //     style: TextStyle(
      //       color: Colors.black87,
      //       fontSize: 20,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   iconTheme: IconThemeData(color: Colors.black87),
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(1),
      //     child: Container(color: Colors.grey[300], height: 1),
      //   ),
      // ),
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
            // Left sidebar - Filters
            Expanded(flex: 3, child: _buildFiltersSidebar()),
            SizedBox(width: 16),
            // Main content - Job listings
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
          // SizedBox(height: 20),
          // Text(
          //   'Saved Jobs',
          //   style: TextStyle(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //     color: Colors.black87,
          //   ),
          // ),
          // SizedBox(height: 8),
          // Text(
          //   '${savedJobs.length} jobs saved',
          //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),

          // ),
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
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Full-time'),
                _buildFilterChip('Part-time'),
                _buildFilterChip('Contract'),
                _buildFilterChip('Internship'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Color(0xFFE7F3FF),
        labelStyle: TextStyle(
          color: isSelected ? Color(0xFF0A66C2) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? Color(0xFF0A66C2) : Colors.grey.shade300,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildJobsList() {
    final displayJobs = filteredJobs;

    if (displayJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: displayJobs.length,
      itemBuilder: (context, index) {
        final job = displayJobs[index];
        return JobCard(
          job: job,
          isSaved: savedJobs.contains(job['id']),
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
    );
  }
}

class JobCard extends StatelessWidget {
  final Map job;
  final bool isSaved;
  final VoidCallback onSave;

  const JobCard({
    required this.job,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsPage(jobId: job['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Color(0xFF0A66C2) : Colors.grey.shade600,
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
                    '₹${job['salary_min']} - ₹${job['salary_max']}',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => JobDetailsPage(jobId: job['id']),
                        ),
                      );
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
}
