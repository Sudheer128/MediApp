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

  String? _selectedCategory;
  String? _selectedJobType;
  String? _selectedDepartment;
  DateTime? _applicationDeadline;
  DateTime? _joiningDate;

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
    final url = Uri.parse("$baseurl/add-job-notification");
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid') ?? 0;

    final body = {
      "userid": userId,
      "organization": _organizationController.text,
      "job_title": _jobTitleController.text,
      "description": _descriptionController.text,
      "location": _locationController.text,
      "category": _selectedCategory,
      "department": _selectedDepartment,
      "job_type": _selectedJobType,
      "vacancies": int.parse(_vacanciesController.text),
      "experience": _experienceController.text,
      "salary_min": int.tryParse(_salaryMinController.text) ?? 0,
      "salary_max": int.tryParse(_salaryMaxController.text) ?? 0,
      "qualifications": _selectedQualifications,
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

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job Posted Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Job Notification'), elevation: 2),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organization Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizationController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital/Organization Name *',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter organization name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'City, State',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Job Details Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jobTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Job Title *',
                        prefixIcon: Icon(Icons.work),
                        hintText: 'e.g., Junior Resident, Senior Resident',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter job title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department/Specialization *',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items:
                          _departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      decoration: const InputDecoration(
                        labelText: 'Job Type *',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      items:
                          _jobTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select job type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vacanciesController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Vacancies *',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of vacancies';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Job Description *',
                        prefixIcon: Icon(Icons.description),
                        hintText:
                            'Describe the role, responsibilities, and requirements',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter job description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Qualifications Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Experience Required',
                        prefixIcon: Icon(Icons.timeline),
                        hintText: 'e.g., 0-2 years, Freshers Welcome',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Required Qualifications:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _categories.map((qual) {
                            final isSelected = _selectedQualifications.contains(
                              qual,
                            );
                            return FilterChip(
                              label: Text(qual),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedQualifications.add(qual);
                                  } else {
                                    _selectedQualifications.remove(qual);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Compensation Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compensation & Benefits',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMinController,
                            decoration: const InputDecoration(
                              labelText: 'Min Salary (₹/month)',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMaxController,
                            decoration: const InputDecoration(
                              labelText: 'Max Salary (₹/month)',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Additional Benefits:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _benefitsList.map((benefit) {
                            final isSelected = _selectedBenefits.contains(
                              benefit,
                            );
                            return FilterChip(
                              label: Text(benefit),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedBenefits.add(benefit);
                                  } else {
                                    _selectedBenefits.remove(benefit);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Important Dates Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Dates',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Application Deadline *'),
                      subtitle: Text(
                        _applicationDeadline == null
                            ? 'Select deadline'
                            : '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _applicationDeadline = date;
                          });
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: const Text('Expected Joining Date'),
                      subtitle: Text(
                        _joiningDate == null
                            ? 'Select joining date'
                            : '${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 60),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _joiningDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Information Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email *',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _applicationLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Application Link (Optional)',
                        prefixIcon: Icon(Icons.link),
                        hintText: 'https://...',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_applicationDeadline == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select application deadline'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await submitJobNotification();

                  // Here you would typically send the data to your backend
                  _showSubmissionDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'POST JOB NOTIFICATION',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSubmissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text(
              'Your job notification has been posted successfully and will be visible to medical students.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // // Reset form
                  // _formKey.currentState!.reset();
                  // setState(() {
                  //   _selectedCategory = null;
                  //   _selectedJobType = null;
                  //   _selectedDepartment = null;
                  //   _applicationDeadline = null;
                  //   _joiningDate = null;
                  //   _selectedQualifications.clear();
                  //   _selectedBenefits.clear();
                  // });
                },
                child: const Text('OK'),
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
