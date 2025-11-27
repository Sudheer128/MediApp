import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:medicalapp/pdf.dart';
import 'package:medicalapp/student/edit.dart';
import 'package:medicalapp/url.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_picker_stub.dart' if (dart.library.html) 'image_picker_web.dart';

class EditForm extends StatefulWidget {
  final int applicationId;

  const EditForm({Key? key, required this.applicationId}) : super(key: key);

  @override
  State<EditForm> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<EditForm> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;
  final ImagePicker _picker = ImagePicker();
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  String? encodeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return Uri.encodeFull(url);
  }

  Future<void> fetchStudentData() async {
    print(widget.applicationId);
    try {
      final response = await http.get(
        Uri.parse(
          '$baseurl/studentscompletedetails?user_id=${widget.applicationId}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = 'You still have not created profile yet, Create a profile';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  // Future<XFile?> pickImageWeb() async {
  //   final completer = Completer<XFile?>();

  //   // Create a NEW input element each time
  //   final input = html.FileUploadInputElement()..accept = 'image/*';

  //   // Set up the listener BEFORE clicking
  //   input.onChange.listen((event) {
  //     print("📂 File input changed");

  //     if (input.files == null || input.files!.isEmpty) {
  //       print("❌ No files selected");
  //       completer.complete(null);
  //       return;
  //     }

  //     final file = input.files!.first;
  //     print("✅ File selected: ${file.name}, size: ${file.size} bytes");

  //     final reader = html.FileReader();
  //     reader.readAsArrayBuffer(file);

  //     reader.onLoadEnd.listen((event) {
  //       print("✅ File read complete");
  //       final data = reader.result as Uint8List;
  //       completer.complete(XFile.fromData(data, name: file.name));
  //     });

  //     reader.onError.listen((event) {
  //       print("❌ File read error");
  //       completer.complete(null);
  //     });
  //   });

  //   // Trigger the file picker
  //   print("🖱️ Triggering file picker...");
  //   input.click();

  //   return completer.future;
  // }

  Future<void> _showImageOptionsDialog(bool isProfileImage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isProfileImage ? 'Profile Photo' : 'Cover Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('View Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _viewImage(isProfileImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Change Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(isProfileImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewImage(bool isProfileImage) {
    final imageUrl =
        isProfileImage
            ? encodeUrl(data?['profile_url'])
            : encodeUrl(data?['cover_url']);

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(
                      isProfileImage ? 'Profile Photo' : 'Cover Photo',
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  Flexible(
                    child: InteractiveViewer(
                      child: Image.network(
                        imageUrl.toString(),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('Failed to load image'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No ${isProfileImage ? 'profile' : 'cover'} photo available',
          ),
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage(bool isProfileImage) async {
    try {
      XFile? pickedFile;

      if (kIsWeb) {
        pickedFile = await pickImageWeb();
      } else {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile == null) {
        print("❌ No image selected");
        return;
      }

      print("✅ Image picked: ${pickedFile.name}");

      // Show preview dialog before uploading
      if (mounted) {
        await _showPreviewDialog(pickedFile, isProfileImage);
      }
    } catch (e) {
      print("❌ Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
      }
    }
  }

  Future<void> _showPreviewDialog(XFile file, bool isProfileImage) async {
    try {
      print("📸 Loading preview for: ${file.name}");

      // Read bytes (works on web & mobile)
      final Uint8List bytes = await file.readAsBytes();

      print("✅ Image bytes loaded: ${bytes.length} bytes");

      if (!mounted) {
        print("❌ Widget not mounted, cannot show dialog");
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent accidental dismissal
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Preview Image"),
            content: SizedBox(
              width: 300,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print("❌ Image display error: $error");
                    return const Center(child: Text("Failed to display image"));
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print("❌ Upload cancelled");
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  print("✅ Upload confirmed");
                  Navigator.of(dialogContext).pop(); // close preview
                  await _uploadImage(
                    file,
                    isProfileImage,
                  ); // upload original file
                },
                child: const Text("Upload"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("❌ Failed to load image preview: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load image preview: $e")),
        );
      }
    }
  }

  Future<void> _uploadImage(XFile file, bool isProfileImage) async {
    setState(() {
      _uploadingImage = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseurl/upload/profile-or-cover'),
      );

      // Add user_id
      request.fields['user_id'] = widget.applicationId.toString();

      // Add the image file
      if (kIsWeb) {
        // Web version
        final bytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            isProfileImage ? "profile_url" : "cover_url",
            bytes,
            filename: file.name,
          ),
        );
      } else {
        // Mobile version
        request.files.add(
          await http.MultipartFile.fromPath(
            isProfileImage ? "profile_url" : "cover_url",
            file.path, // <==== FIX: Using XFile path (not cropped file)
          ),
        );
      }

      // SEND REQUEST
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);

        // Update image URL locally
        setState(() {
          if (isProfileImage) {
            data?['profile_url'] = jsonResponse['profile_url'];
          } else {
            data?['cover_url'] = jsonResponse['cover_url'];
          }
        });

        // REFRESH FULL DATA (so UI updates instantly)
        await fetchStudentData();

        setState(() {
          _uploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isProfileImage ? "Profile" : "Cover"} photo updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("Failed to upload image: $responseData");
      }
    } catch (e) {
      setState(() {
        _uploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // LinkedIn-style Profile Header with Cover and Profile Picture
  Widget buildProfileHeader(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    final email = data['email'] ?? '';
    final phone = data['phone']?.toString() ?? '';
    final address = data['address'] ?? '';
    final profileImageUrl = encodeUrl(data['profile_url']);
    final coverImageUrl = encodeUrl(data['cover_url']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  gradient:
                      coverImageUrl == null || coverImageUrl.toString().isEmpty
                          ? LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                ),
                child:
                    coverImageUrl != null && coverImageUrl.toString().isNotEmpty
                        ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            coverImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.blue.shade400,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : null,
              ),
              // Loading overlay
              if (_uploadingImage)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              // Edit Cover Button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    onPressed:
                        _uploadingImage
                            ? null
                            : () => _showImageOptionsDialog(false),
                    tooltip: 'Edit cover photo',
                  ),
                ),
              ),
              // Profile Picture
              Positioned(
                bottom: -50,
                left: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --------------------
                    // PROFILE IMAGE (clickable)
                    // --------------------
                    GestureDetector(
                      onTap: () => _showImageOptionsDialog(true),
                      child: Tooltip(
                        message: "View / Change Profile Photo",
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.grey.shade300,
                          ),
                          child: ClipOval(
                            child:
                                _uploadingImage
                                    ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue.shade700,
                                      ),
                                    )
                                    : (profileImageUrl != null &&
                                        profileImageUrl!.isNotEmpty)
                                    ? Image.network(
                                      profileImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                        ),
                      ),
                    ),

                    // --------------------
                    // CAMERA ICON BUTTON
                    // --------------------
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImageOptionsDialog(true),
                        child: Tooltip(
                          message: "Change Profile Photo",
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Profile Info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Medical Professional',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$email • $phone',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LinkedIn-style Section Card
  Widget buildLinkedInSection({
    required String title,
    required Widget content,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    color: Colors.grey.shade700,
                    tooltip: 'Edit $title',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // About Section
  Widget buildAboutSection() {
    return buildLinkedInSection(
      title: 'About',
      onEdit: _navigateToEdit,
      content: Text(
        'Experienced medical professional dedicated to providing quality healthcare and continuous professional development.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          height: 1.5,
        ),
      ),
    );
  }

  // Experience Item
  Widget buildExperienceItem(Map<String, dynamic> work, bool isLast) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.business, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work['role'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    work['name'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${work['from'] ?? ''} - ${work['to'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    work['place'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (work['description'] != null &&
                      work['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      work['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Work Experience Section
  Widget buildWorkExperienceSection(List<dynamic> workExperiences) {
    return buildLinkedInSection(
      title: 'Work Experience',
      onEdit: _navigateToEdit,
      content: Column(
        children:
            workExperiences.asMap().entries.map((entry) {
              return buildExperienceItem(
                entry.value,
                entry.key == workExperiences.length - 1,
              );
            }).toList(),
      ),
    );
  }

  // Fellowship Item
  Widget buildFellowshipItem(Map<String, dynamic> fellowship, bool isLast) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fellowship['courseName'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fellowship['collegeName'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fellowship['fromDate'] ?? ''} - ${fellowship['toDate'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Fellowship Section
  Widget buildFellowshipSection(List<dynamic> fellowships) {
    return buildLinkedInSection(
      title: 'Fellowships',
      onEdit: _navigateToEdit,
      content: Column(
        children:
            fellowships.asMap().entries.map((entry) {
              return buildFellowshipItem(
                entry.value,
                entry.key == fellowships.length - 1,
              );
            }).toList(),
      ),
    );
  }

  // Education Item
  Widget buildEducationItem(Map<String, dynamic> edu, bool isLast) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.school, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu['collegeName'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${edu['type'] ?? ''}, ${edu['courseName'] ?? ''}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${edu['fromDate'] ?? ''} - ${edu['toDate'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // Education Section
  Widget buildEducationSection(List<dynamic> education) {
    return buildLinkedInSection(
      title: 'Education',
      onEdit: _navigateToEdit,
      content: Column(
        children:
            education.asMap().entries.map((entry) {
              return buildEducationItem(
                entry.value,
                entry.key == education.length - 1,
              );
            }).toList(),
      ),
    );
  }

  // Licenses & Certifications
  Widget buildLicensesSection(dynamic certificate) {
    return buildLinkedInSection(
      title: 'Medical Counsel Certificate',
      onEdit: _navigateToEdit,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.verified, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate['courseName'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  certificate['counselName'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registration No: ${certificate['registrationNumber'] ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valid: ${certificate['validFrom'] ?? ''} - ${certificate['validTo'] ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Publications Section
  Widget buildPublicationsSection(List<dynamic> papers) {
    return buildLinkedInSection(
      title: 'Publications',
      onEdit: _navigateToEdit,
      content: Column(
        children:
            papers.asMap().entries.map((entry) {
              final paper = entry.value;
              final isLast = entry.key == papers.length - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paper['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Published: ${paper['submittedOn'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
      ),
    );
  }

  // Resume/Documents Section
  Future<void> _launchURL(BuildContext context, String url) async {
    if (kIsWeb) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PdfViewerPage(url: url, color: Colors.blue.shade700),
        ),
      );
    }
  }

  Widget buildResumeSection(List<dynamic> documents) {
    return buildLinkedInSection(
      title: 'Resume & Documents',
      onEdit: _navigateToEdit,
      content: Column(
        children:
            documents.asMap().entries.map((entry) {
              final doc = entry.value;
              final isLast = entry.key == documents.length - 1;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.description,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name'] ?? 'Unnamed Document',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc['type'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final url = doc['url'] ?? '';
                          if (url.isNotEmpty) {
                            _launchURL(context, url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No URL provided')),
                            );
                          }
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
      ),
    );
  }

  void _navigateToEdit() {
    print(data);
    if (data != null) {
      if (kIsWeb) {
        context.go('/edit-application', extra: data);
      } else {
        context.push('/edit-application', extra: data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: linkedInProfileShimmer(),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditApplicationForm(existingData: null),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildGeneralCertificatesSection(List<dynamic> certificates) {
      return buildLinkedInSection(
        title: 'Licenses & Certifications',
        onEdit: _navigateToEdit,
        content: Column(
          children:
              certificates.asMap().entries.map((entry) {
                final cert = entry.value;
                final isLast = entry.key == certificates.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.card_membership,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cert['certificateName'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cert['issuingAuthority'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Valid: ${cert['from'] ?? ''} - ${cert['to'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (cert['officialLink'] != null &&
                                  cert['officialLink']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final url = cert['officialLink'];
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not open link',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'View Certificate',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue.shade700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 20),
                    ],
                  ],
                );
              }).toList(),
        ),
      );
    }

    // Conferences Section
    Widget buildConferencesSection(List<dynamic> conferences) {
      return buildLinkedInSection(
        title: 'CONFERENCES AND CME',
        onEdit: _navigateToEdit,
        content: Column(
          children:
              conferences.asMap().entries.map((entry) {
                final conference = entry.value;
                final isLast = entry.key == conferences.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.event,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conference['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conference['activityType'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Organized by: ${conference['organizer'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${conference['date'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (conference['uploadLink'] != null &&
                                  conference['uploadLink']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final url = conference['uploadLink'];
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not open link',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue.shade700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 20),
                    ],
                  ],
                );
              }).toList(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Overall Edit Button
          TextButton.icon(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Edit Profile'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (data != null) buildProfileHeader(data!),
                    buildAboutSection(),
                    if (data?['workExperiences'] != null &&
                        (data!['workExperiences'] as List).isNotEmpty)
                      buildWorkExperienceSection(data!['workExperiences']),
                    if (data?['fellowships'] != null &&
                        (data!['fellowships'] as List).isNotEmpty)
                      buildFellowshipSection(data!['fellowships']),
                    if (data?['education'] != null)
                      buildEducationSection(data!['education']),
                    if (data?['certificate'] != null)
                      buildLicensesSection(data!['certificate']),
                    if (data?['certificates'] != null &&
                        (data!['certificates'] as List).isNotEmpty)
                      buildGeneralCertificatesSection(data!['certificates']),
                    if (data?['conferences'] != null &&
                        (data!['conferences'] as List).isNotEmpty)
                      buildConferencesSection(data!['conferences']),
                    if (data?['papers'] != null &&
                        (data!['papers'] as List).isNotEmpty)
                      buildPublicationsSection(data!['papers']),
                    if (data?['documents'] != null &&
                        (data!['documents'] as List).isNotEmpty)
                      buildResumeSection(data!['documents']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget shimmerBox({
  double height = 16,
  double width = double.infinity,
  double radius = 8,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

Widget linkedInProfileShimmer() {
  return SingleChildScrollView(
    child: Column(
      children: [
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER CARD
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Cover Image Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Profile Info
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmerBox(height: 25, width: 200),
                            const SizedBox(height: 12),
                            shimmerBox(height: 18, width: 150),
                            const SizedBox(height: 12),
                            shimmerBox(height: 14, width: 250),
                            const SizedBox(height: 8),
                            shimmerBox(height: 14, width: 180),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ABOUT SECTION
                shimmerSection(),
                // EXPERIENCE SECTION
                shimmerSection(),
                // EDUCATION SECTION
                shimmerSection(),
                //RESUME SECTION
                shimmerSection(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget shimmerSection() {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shimmerBox(height: 20, width: 160),
        const SizedBox(height: 20),
        shimmerBox(height: 14),
        const SizedBox(height: 12),
        shimmerBox(height: 14, width: 220),
        const SizedBox(height: 12),
        shimmerBox(height: 14),
      ],
    ),
  );
}
