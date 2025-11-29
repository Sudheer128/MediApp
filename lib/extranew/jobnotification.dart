import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicalapp/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobNotificationForm extends StatefulWidget {
  const JobNotificationForm({Key? key}) : super(key: key);

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

  /// Stores selected courses per qualification key
  Map<String, List<int>> selectedQualificationMapping = {};

  List<dynamic> activeCourses = [];
  @override
  void initState() {
    super.initState();
    fetchQualifications();
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
    }
  }

  final List<String> _categories = [
    'MBBS',
    'MD/MS',
    'DM/MCh',
    'DNB',
    'Diploma',
    'Super Speciality',
  ];
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
    'Radiology',
    'Anesthesiology',
    'Pathology',
    'Emergency Medicine',
    'Psychiatry',
    'Dermatology',
    'ENT',
    'Ophthalmology',
    'Other',
  ];

  final List<String> _selectedQualifications = [];
  final List<String> _selectedBenefits = [];

  final List<String> _benefitsList = [
    'Health Insurance',
    'Accommodation',
    'Food Allowance',
    'Transportation',
    'Professional Development',
    'CME Credits',
    'Conference Sponsorship',
    'Research Opportunities',
  ];

  Future<void> submitJobNotification() async {
    setState(() => _isSubmitting = true);

    final url = Uri.parse("$baseurl/add-job-notification");
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    // Add all other selected numeric course ids
    allSelectedCourseIds.addAll(
      selectedQualificationMapping.entries.expand((entry) => entry.value),
    );
    // remove duplicates
    final courseIds =
        allSelectedCourseIds
            .map((e) => e.toString()) // convert everything to string
            .toSet()
            .toList(); // remove duplicates

    final body = {
      "userid": userId,
      "organization": _organizationController.text,
      "job_title": _jobTitleController.text,
      "description": _descriptionController.text,
      "location": _locationController.text,
      "category": _categoryController.text,
      "department": _selectedDepartment,
      "job_type": _selectedJobType,
      "vacancies": int.parse(_vacanciesController.text),
      "experience": _experienceController.text,
      "salary_min": int.tryParse(_salaryMinController.text) ?? 0,
      "salary_max": int.tryParse(_salaryMaxController.text) ?? 0,
      "qualifications": courseIds,
      "benefits": _selectedBenefits,
      "application_deadline":
          "${_applicationDeadline!.year}-${_applicationDeadline!.month}-${_applicationDeadline!.day}",
      "joining_date":
          _joiningDate == null
              ? null
              : "${_joiningDate!.year}-${_joiningDate!.month}-${_joiningDate!.day}",
      "contact_email": _contactEmailController.text,
      "contact_phone": _contactPhoneController.text,
      "application_link": _applicationLinkController.text,
    };
    print(body);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        _showSubmissionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
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

  Widget _buildCourseSelector(String key) {
    List<dynamic> courses = qualificationData[key] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select courses for $key",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),

        DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              courses.map((course) {
                return DropdownMenuItem(
                  value: course["course_id"],
                  child: Text(course["course_name"]),
                );
              }).toList(),
          onChanged: (value) {
            final int courseId = value as int;

            if (!selectedQualificationMapping[key]!.contains(courseId)) {
              setState(() {
                selectedQualificationMapping[key]!.add(courseId);
              });
            }
          },
        ),

        Wrap(
          spacing: 6,
          children:
              selectedQualificationMapping[key]!.map((courseId) {
                final name =
                    courses.firstWhere(
                      (c) => c["course_id"] == courseId,
                    )["course_name"] ??
                    "Course";
                return Chip(
                  label: Text(name, style: TextStyle(fontSize: 12)),
                  onDeleted: () {
                    setState(() {
                      selectedQualificationMapping[key]!.remove(courseId);
                    });
                  },
                );
              }).toList(),
        ),

        SizedBox(height: 20),
      ],
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
            onPressed: _isSubmitting ? null : _handleSubmit,
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
                    : Text(
                      'Post Job',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_applicationDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select application deadline'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await submitJobNotification();
    }
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
    super.dispose();
  }
}
