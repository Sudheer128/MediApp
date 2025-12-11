import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobNotificationForm extends StatefulWidget {
  final int? jobId;
  const JobNotificationForm({super.key, this.jobId});

  @override
  State<JobNotificationForm> createState() => _JobNotificationFormState();
}

class _JobNotificationFormState extends State<JobNotificationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();
  final TextEditingController _vacanciesController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _applicationLinkController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();

  String? _selectedCategory;
  String? _selectedJobType;
  String? _selectedDepartment;
  DateTime? _applicationDeadline;
  DateTime? _joiningDate;
  bool _isSubmitting = false;
  // flatten course IDs + include MBBS string if selected
  final List<dynamic> allSelectedCourseIds = [];
  Map<String, dynamic> qualificationData = {};
  List<String> mainQualificationKeys = [];
  bool isEditMode = false;
  Map<String, dynamic>? loadedJob;

  /// Stores selected courses per qualification key
  Map<String, List<int>> selectedQualificationMapping = {};

  List<dynamic> activeCourses = [];
  @override
  void initState() {
    super.initState();
    fetchQualifications();
    if (widget.jobId != null) {
      isEditMode = true;
      fetchJobForEdit(widget.jobId!); // Load job details if editing
    }
  }

  void prefillQualifications(List courseIds) {
    selectedQualificationMapping.clear();

    qualificationData.forEach((key, courseList) {
      List<int> matching = [];

      for (var c in courseList) {
        if (courseIds.contains(c["course_id"])) {
          matching.add(c["course_id"]);
        }
      }

      if (matching.isNotEmpty) {
        selectedQualificationMapping[key] = matching;
      }
    });
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userid');
  }

  Future<void> fetchJobForEdit(int jobId) async {
    final userId = await getUserId();
    final response = await http.get(
      Uri.parse("$baseurl/getJobDetails?id=$jobId&user_id=$userId"),
    );

    if (response.statusCode != 200) return;

    final body = jsonDecode(response.body);
    final data = body["data"]; // <-- CORRECT

    setState(() {
      loadedJob = data; // <-- FIXED

      _organizationController.text = data["organization"] ?? "";
      _jobTitleController.text = data["job_title"] ?? "";
      _descriptionController.text = data["description"] ?? "";
      _locationController.text = data["location"] ?? "";
      _categoryController.text = data["category"] ?? "";
      _selectedDepartment = data["department"];
      _selectedJobType = data["job_type"];

      _vacanciesController.text = data["vacancies"].toString();
      _experienceController.text = data["experience_required"] ?? "";
      _salaryMinController.text = data["salary_min"].toString();
      _salaryMaxController.text = data["salary_max"].toString();

      _contactEmailController.text = data["contact_email"] ?? "";
      _contactPhoneController.text = data["contact_phone"] ?? "";
      _applicationLinkController.text = data["application_link"] ?? "";
      _requirementsController.text = data["requirements"] ?? "";

      // DATES
      if (data["application_deadline"] != null &&
          data["application_deadline"] != "") {
        _applicationDeadline = DateTime.parse(data["application_deadline"]);
      }

      if (data["joining_date"] != null && data["joining_date"] != "") {
        _joiningDate = DateTime.parse(data["joining_date"]);
      }

      // BENEFITS
      if (data["benefits"] != null && data["benefits"].toString().isNotEmpty) {
        _selectedBenefits.clear();
        _selectedBenefits.addAll(
          List<String>.from(jsonDecode(data["benefits"])),
        );
      }

      // QUALIFICATIONS → best source is course_ids
      if (body["course_ids"] != null) {
        List<String> ids = List<String>.from(body["course_ids"]);
        List<int> intIds = ids.map((e) => int.tryParse(e) ?? 0).toList();
        prefillQualifications(intIds);
      }
    });

    // course_labels mapping (degree + course_name)
    if (body["course_labels"] != null) {
      applyPreviousSelections(body);
    }
  }

  Future<void> fetchQualifications() async {
    final url = Uri.parse("$baseurl/courses/grouped");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        qualificationData = json['data'];
        mainQualificationKeys = [...qualificationData.keys.toList()];
      });

      // PERFECT SPOT — Both job data + qualification data are loaded ✔
      if (loadedJob != null) {
        applyPreviousSelections(loadedJob!);
      }
    }
  }

  final List<String> _jobTypes = [
    'Full Time',
    'Part Time',
    'Contract',
    'Temporary',
    'Internship',
    'Consultancy',
  ];
  final List<String> _departments = [
    'General Medicine',
    'Surgery',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Orthopedics',
    'Cardiology',
    'Neurology',
    'Pulmonology',
    'Radiology',
    'Anesthesiology',
    'Pathology',
    'Emergency Medicine',
    'Psychiatry',
    'Dermatology',
    'ENT',
    'Ophthalmology',
    'Physiology ',
    'Other',
  ];

  final List<String> _selectedQualifications = [];
  final List<String> _selectedBenefits = [];

  final List<String> _benefitsList = [
    'Health Insurance',
    'Accommodation',
    'Food Allowance',
    'Accommodation',
    'Professional Development',
    'CME Credits',
    'Conference Sponsorship',
    'Research Opportunities',
  ];
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final url =
        isEditMode
            ? Uri.parse("$baseurl/update-job-notification")
            : Uri.parse("$baseurl/add-job-notification");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userid") ?? 0;

    // Ensure qualifications list is clean
    final qualifications =
        selectedQualificationMapping.values
            .expand((e) => e)
            .map((id) => id.toString())
            .toSet()
            .toList();

    // Ensure benefits is List<String> ONLY
    final benefits = _selectedBenefits.map((e) => e.toString()).toList();

    final body = {
      if (isEditMode) "job_id": widget.jobId, // only when editing
      "userid": userId,
      "organization": _organizationController.text.trim(),
      "job_title": _jobTitleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "location": _locationController.text.trim(),
      "category": _categoryController.text.trim(),
      "department": _selectedDepartment ?? "",
      "job_type": _selectedJobType ?? "",
      "vacancies": int.tryParse(_vacanciesController.text) ?? 0,
      "experience": _experienceController.text.trim(),
      "salary_min": int.tryParse(_salaryMinController.text) ?? 0,
      "salary_max": int.tryParse(_salaryMaxController.text) ?? 0,
      "qualifications": qualifications, // VALID - only one field
      "benefits": benefits,
      "application_deadline": _applicationDeadline?.toIso8601String() ?? "",
      "joining_date": _joiningDate?.toIso8601String() ?? "",
      "contact_email": _contactEmailController.text.trim(),
      "contact_phone": _contactPhoneController.text.trim(),
      "application_link": _applicationLinkController.text.trim(),
      "requirements": _requirementsController.text.trim(),
    };

    print(jsonEncode(body));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200) {
      _showSubmissionDialog();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Color(0xFFF3F2EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Post a Job',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
      ),
    );
  }

  void applyPreviousSelections(Map job) {
    selectedQualificationMapping.clear();

    List<String> courseLabels = [];
    try {
      courseLabels = List<String>.from(job["course_labels"]);
    } catch (_) {}

    for (String label in courseLabels) {
      if (!label.contains("(") || !label.contains(")")) continue;

      final courseName = label.split("(")[0].trim();
      final degree = label.split("(")[1].replaceAll(")", "").trim();

      // Auto-select degree
      selectedQualificationMapping.putIfAbsent(degree, () => []);

      final courses = qualificationData[degree] ?? [];

      final match = courses.firstWhere(
        (c) => c["course_name"] == courseName,
        orElse: () => null,
      );

      if (match != null) {
        selectedQualificationMapping[degree]!.add(match["course_id"]);
      }
    }

    setState(() {});
  }

  Widget _buildWebLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 800),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildQualificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Required Qualifications",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),

        Wrap(
          spacing: 8,
          children:
              mainQualificationKeys.map((key) {
                bool isSelected = selectedQualificationMapping.containsKey(key);

                return FilterChip(
                  label: Text(key),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        // Add key (empty list for MBBS)
                        selectedQualificationMapping[key] = [];
                      } else {
                        // Remove key and its selections
                        selectedQualificationMapping.remove(key);
                      }
                    });
                  },
                );
              }).toList(),
        ),

        SizedBox(height: 20),

        /// Build dropdown selectors for each selected qualification with courses
        Column(
          children:
              selectedQualificationMapping.keys
                  .map((key) => _buildCourseSelector(key))
                  .toList(),
        ),
      ],
    );
  }

  // Replace the _openCourseSelectionDialog method with this enhanced version

  void _openCourseSelectionDialog(String key, List<dynamic> courses) {
    TextEditingController searchCtrl = TextEditingController();
    FocusNode searchFocusNode = FocusNode();

    List<dynamic> filtered = List.from(courses);

    void sortList() {
      filtered.sort((a, b) {
        bool aSel = selectedQualificationMapping[key]!.contains(a["course_id"]);
        bool bSel = selectedQualificationMapping[key]!.contains(b["course_id"]);
        if (aSel && !bSel) return -1;
        if (!aSel && bSel) return 1;
        return a["course_name"].compareTo(b["course_name"]);
      });
    }

    sortList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            /// Auto-focus works again
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!searchFocusNode.hasFocus) searchFocusNode.requestFocus();
            });

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select Course"),

                  /// 🔥 Always visible Select All button
                  TextButton(
                    onPressed: () {
                      setStateDialog(() {
                        for (var item in filtered) {
                          int id = item["course_id"];
                          if (!selectedQualificationMapping[key]!.contains(
                            id,
                          )) {
                            selectedQualificationMapping[key]!.add(id);
                          }
                        }
                        sortList();
                      });

                      setState(() {}); // update chips outside
                    },
                    child: Text(
                      "Select All",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),

                  /// Show Clear All only if something selected
                  if (selectedQualificationMapping[key]!.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setStateDialog(() {
                          selectedQualificationMapping[key]!.clear();
                          sortList();
                        });
                        setState(() {});
                      },
                      child: Text(
                        "Clear All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),

              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    /// Search box
                    TextField(
                      controller: searchCtrl,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search course...",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            searchCtrl.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setStateDialog(() {
                                      searchCtrl.clear();
                                      filtered = List.from(courses);
                                      sortList();
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          filtered =
                              value.isEmpty
                                  ? List.from(courses)
                                  : courses
                                      .where(
                                        (c) => c["course_name"]
                                            .toLowerCase()
                                            .contains(value.toLowerCase()),
                                      )
                                      .toList();
                          sortList();
                        });
                      },
                    ),

                    SizedBox(height: 12),

                    if (searchCtrl.text.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${filtered.length} result${filtered.length == 1 ? '' : 's'} found",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),

                    SizedBox(height: 6),

                    Expanded(
                      child:
                          filtered.isEmpty
                              ? Center(child: Text("No courses found"))
                              : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final int id = item["course_id"];
                                  final bool selected =
                                      selectedQualificationMapping[key]!
                                          .contains(id);

                                  return CheckboxListTile(
                                    value: selected,
                                    title: Text(item["course_name"]),
                                    onChanged: (checked) {
                                      setStateDialog(() {
                                        if (checked == true) {
                                          selectedQualificationMapping[key]!
                                              .add(id);
                                        } else {
                                          selectedQualificationMapping[key]!
                                              .remove(id);
                                        }
                                        sortList();
                                      });

                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => searchFocusNode.dispose());
  }

  Widget _buildCourseSelector(String key) {
    List<dynamic> courses = qualificationData[key] ?? [];
    bool isExpanded = false; // Local UI state toggle

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        List<int> selectedIds = selectedQualificationMapping[key] ?? [];
        List<int> visibleItems =
            isExpanded ? selectedIds : selectedIds.take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select courses for $key",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),

            /// Open search dialog button
            InkWell(
              onTap: () => _openCourseSelectionDialog(key, courses),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      "Search & Select Course",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            /// Selected items UI
            if (selectedIds.isNotEmpty)
              Wrap(
                spacing: 6,
                children: [
                  ...visibleItems.map((courseId) {
                    final course = courses.firstWhere(
                      (c) => c["course_id"] == courseId,
                    );

                    return Chip(
                      label: Text(
                        course["course_name"],
                        style: TextStyle(fontSize: 12),
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedQualificationMapping[key]!.remove(courseId);
                        });
                        setStateLocal(() {});
                      },
                    );
                  }),

                  /// If collapsed and more exist → show "+ More"
                  if (!isExpanded && selectedIds.length > 4)
                    InkWell(
                      onTap: () => setStateLocal(() => isExpanded = true),
                      child: Chip(
                        label: Text(
                          "+${selectedIds.length - 4} more ▼",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),

                  /// If expanded → show "Show less"
                  if (isExpanded && selectedIds.length > 4)
                    InkWell(
                      onTap: () => setStateLocal(() => isExpanded = false),
                      child: Chip(
                        label: Text(
                          "Show less ▲",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                ],
              ),

            SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return _buildFormContent();
  }

  Widget _buildFormContent() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          title: 'Organization Details',
          icon: Icons.business,
          children: [
            _buildTextField(
              controller: _organizationController,
              label: 'Hospital/Organization Name',
              hint: 'Enter organization name',
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'City, State',
              icon: Icons.location_on_outlined,
              required: true,
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildSectionCard(
          title: 'Job Details',
          icon: Icons.work_outline,
          children: [
            _buildTextField(
              controller: _jobTitleController,
              label: 'Job Title',
              hint: 'e.g., Junior Resident, Senior Resident',
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              hint: 'Enter category',
              required: true,
            ),

            SizedBox(height: 16),
            _buildDropdown(
              value: _selectedDepartment,
              label: 'Department/Specialization',
              items: _departments,
              onChanged: (value) => setState(() => _selectedDepartment = value),
              required: true,
            ),
            SizedBox(height: 16),
            _buildDropdown(
              value: _selectedJobType,
              label: 'Job Type',
              items: _jobTypes,
              onChanged: (value) => setState(() => _selectedJobType = value),
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _vacanciesController,
              label: 'Number of Vacancies',
              keyboardType: TextInputType.number,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Job Description',
              hint: 'Describe the role, responsibilities, and requirements',
              maxLines: 5,
              required: true,
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildSectionCard(
          title: 'Requirements',
          icon: Icons.checklist,
          children: [
            _buildTextField(
              controller: _requirementsController,
              label: 'Requirements',
              hint: 'Enter key job requirements or skills needed',
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _experienceController,
              label: 'Experience Required',
              hint: 'e.g., 0-2 years, Freshers Welcome',
            ),
            SizedBox(height: 16),

            SizedBox(height: 8),
            _buildQualificationsSection(),
          ],
        ),
        SizedBox(height: 16),
        _buildSectionCard(
          title: 'Compensation & Benefits',
          icon: Icons.account_balance_wallet_outlined,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _salaryMinController,
                    label: 'Min Salary',
                    hint: '₹/month',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _salaryMaxController,
                    label: 'Max Salary',
                    hint: '₹/month',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Additional Benefits',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            _buildChipSelection(_benefitsList, _selectedBenefits),
          ],
        ),
        SizedBox(height: 16),
        _buildSectionCard(
          title: 'Important Dates',
          icon: Icons.calendar_today,
          children: [
            _buildDateSelector(
              label: 'Application Deadline',
              date: _applicationDeadline,
              required: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _applicationDeadline = date);
                }
              },
            ),
            SizedBox(height: 12),
            _buildDateSelector(
              label: 'Expected Joining Date',
              date: _joiningDate,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(Duration(days: 60)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _joiningDate = date);
                }
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildSectionCard(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          children: [
            _buildTextField(
              controller: _contactEmailController,
              label: 'Contact Email',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _contactPhoneController,
              label: 'Contact Phone',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _applicationLinkController,
              label: 'Application Link',
              hint: 'https://...',
              keyboardType: TextInputType.url,
              icon: Icons.link,
            ),
          ],
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmits,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0A66C2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child:
                _isSubmitting
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(isEditMode ? "Update Job" : "Post Job"),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Icon(icon, color: Color(0xFF0A66C2), size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(0xFF0A66C2), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator:
          validator ??
          (value) {
            if (required && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(0xFF0A66C2), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 14)),
            );
          }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (required && value == null) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildChipSelection(List<String> items, List<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            final isSelected = selected.contains(item);
            return FilterChip(
              label: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Color(0xFF0A66C2) : Colors.grey.shade700,
                ),
              ),
              selected: isSelected,
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    selected.add(item);
                  } else {
                    selected.remove(item);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Color(0xFFE7F3FF),
              checkmarkColor: Color(0xFF0A66C2),
              side: BorderSide(
                color: isSelected ? Color(0xFF0A66C2) : Colors.grey.shade300,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF3F2EF),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey.shade600,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label + (required ? ' *' : ''),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    date == null
                        ? 'Select date'
                        : '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          date == null ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmits() async {
    await _handleSubmit();
  }

  void _showSubmissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'Success',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Text(
              'Your job has been posted successfully and will be visible to medical professionals.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF0A66C2),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _vacanciesController.dispose();
    _experienceController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _applicationLinkController.dispose();
    _requirementsController.dispose();

    super.dispose();
  }
}
