import 'package:flutter/material.dart';

class HospitalProfilePage extends StatefulWidget {
  const HospitalProfilePage({Key? key}) : super(key: key);

  @override
  State<HospitalProfilePage> createState() => _HospitalProfilePageState();
}

class _HospitalProfilePageState extends State<HospitalProfilePage> {
  bool _isEditingAbout = false;

  final TextEditingController _orgNameController = TextEditingController(
    text: 'Apollo Hospitals',
  );
  final TextEditingController _establishedController = TextEditingController(
    text: '1983',
  );
  final TextEditingController _employeesController = TextEditingController(
    text: '50,000+',
  );
  final TextEditingController _locationController = TextEditingController(
    text: 'Hyderabad, Telangana, India',
  );
  final TextEditingController _overviewController = TextEditingController(
    text:
        'Apollo Hospitals is a leading healthcare provider in India, offering world-class medical services across multiple specialties. With state-of-the-art facilities and a team of highly qualified medical professionals, we are committed to providing exceptional patient care and advancing medical science through research and innovation.',
  );

  @override
  void dispose() {
    _orgNameController.dispose();
    _establishedController.dispose();
    _employeesController.dispose();
    _locationController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditingAbout = !_isEditingAbout;
    });
  }

  void _saveChanges() {
    // Save the changes here (e.g., API call)
    setState(() {
      _isEditingAbout = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Hospital Profile',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 8),
            _buildAboutSection(),
            const SizedBox(height: 8),
            _buildJobsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cover Photo
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Profile Picture
              Positioned(
                bottom: -40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        'https://via.placeholder.com/100',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_hospital,
                            size: 50,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          // Hospital Name and Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _orgNameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Healthcare • ${_employeesController.text} employees',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _locationController.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A66C2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Follow'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0A66C2),
                        side: const BorderSide(color: Color(0xFF0A66C2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 24,
                        ),
                      ),
                      child: const Text('Visit website'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (!_isEditingAbout)
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Color(0xFF0A66C2),
                  ),
                  onPressed: _toggleEdit,
                  tooltip: 'Edit',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditingAbout) ...[
            _buildEditableField(
              'Organization Name',
              _orgNameController,
              Icons.business,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              'Established Year',
              _establishedController,
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              'Total Employees',
              _employeesController,
              Icons.people,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              'Location',
              _locationController,
              Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              'Overview',
              _overviewController,
              Icons.description,
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: const BorderSide(color: Colors.black54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildInfoRow(
              Icons.business,
              'Organization Name',
              _orgNameController.text,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Established',
              _establishedController.text,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people,
              'Total Employees',
              _employeesController.text,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_city,
              'Location',
              _locationController.text,
            ),
            const SizedBox(height: 16),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _overviewController.text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not specified' : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildJobCard(
            title: 'Senior Cardiologist',
            location: 'Hyderabad, India',
            type: 'Full-time',
            postedTime: '2 days ago',
          ),
          const Divider(height: 32),
          _buildJobCard(
            title: 'Registered Nurse - ICU',
            location: 'Hyderabad, India',
            type: 'Full-time',
            postedTime: '3 days ago',
          ),
          const Divider(height: 32),
          _buildJobCard(
            title: 'Medical Laboratory Technician',
            location: 'Hyderabad, India',
            type: 'Full-time',
            postedTime: '5 days ago',
          ),
          const Divider(height: 32),
          _buildJobCard(
            title: 'Pediatric Surgeon',
            location: 'Hyderabad, India',
            type: 'Full-time',
            postedTime: '1 week ago',
          ),
          const Divider(height: 32),
          _buildJobCard(
            title: 'Hospital Administrator',
            location: 'Hyderabad, India',
            type: 'Full-time',
            postedTime: '1 week ago',
          ),
          const Divider(height: 32),
          _buildJobCard(
            title: 'Radiologist',
            location: 'Hyderabad, India',
            type: 'Full-time',
            postedTime: '2 weeks ago',
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Show all jobs',
                style: TextStyle(
                  color: Color(0xFF0A66C2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String location,
    required String type,
    required String postedTime,
  }) {
    return InkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _orgNameController.text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '$location • $type',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            postedTime,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
