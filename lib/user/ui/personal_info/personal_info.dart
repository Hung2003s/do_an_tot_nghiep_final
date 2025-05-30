import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PersonalInfoScreen1 extends StatefulWidget {
  const PersonalInfoScreen1({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen1> createState() => _PersonalInfoScreen1State();
}

class _PersonalInfoScreen1State extends State<PersonalInfoScreen1> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _parentNumberController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  String? _gender;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _parentNumberController.dispose();
    _parentEmailController.dispose();
    _dobController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveInfo() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Lấy tất cả documents và tìm document phù hợp
    final allUsers = await FirebaseFirestore.instance.collection('user').get();
    final matchingDocs = allUsers.docs
        .where((doc) =>
            doc.data()['Email']?.toString().toLowerCase() ==
            user.email?.toLowerCase())
        .toList();

    if (matchingDocs.isNotEmpty) {
      final matchingDoc = matchingDocs.first;
      // Parse date string to DateTime
      DateTime? dob;
      try {
        dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      } catch (e) {
        print('Error parsing date: $e');
      }

      await FirebaseFirestore.instance
          .collection('user')
          .doc(matchingDoc.id)
          .update({
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Phone_number': _parentNumberController.text,
        'Email': _parentEmailController.text,
        'Gender': _gender,
        'DateOfBirth': dob != null ? Timestamp.fromDate(dob) : null,
      });
    }
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isLoading = true;
        });

        // Upload image to Firebase Storage
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(
                  '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          await storageRef.putFile(_imageFile!);
          final downloadUrl = await storageRef.getDownloadURL();

          // Update avatar URL in Firestore
          final allUsers =
              await FirebaseFirestore.instance.collection('user').get();
          final matchingDocs = allUsers.docs
              .where((doc) =>
                  doc.data()['Email']?.toString().toLowerCase() ==
                  user.email?.toLowerCase())
              .toList();

          if (matchingDocs.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('user')
                .doc(matchingDocs.first.id)
                .update({'avatar': downloadUrl});

            setState(() {
              _avatarController.text = downloadUrl;
            });
          }
        }
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ảnh lên: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Chỉnh sửa',
                  style: TextStyle(color: Colors.orange)),
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: const Text('Hủy', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveInfo,
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Lưu', style: TextStyle(color: Colors.green)),
            ),
          ]
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/17545.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black12,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: user == null
              ? const Center(
                  child: Text('Vui lòng đăng nhập để xem thông tin'),
                )
              : FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance.collection('user').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    Map<String, dynamic>? userData;
                    if (snapshot.hasData && snapshot.data != null) {
                      final matchingDocs = snapshot.data!.docs
                          .where((doc) =>
                              doc.data()['Email']?.toString().toLowerCase() ==
                              user?.email?.toLowerCase())
                          .toList();

                      if (matchingDocs.isNotEmpty) {
                        userData = matchingDocs.first.data();
                        _firstNameController.text = userData['FirstName'] ?? '';
                        _lastNameController.text = userData['LastName'] ?? '';
                        _parentNumberController.text =
                            userData['Phone_number'] ?? '';
                        _parentEmailController.text = userData['Email'] ?? '';
                        var dobRaw = userData['DateOfBirth'];
                        if (dobRaw != null) {
                          DateTime dob;
                          if (dobRaw is Timestamp) {
                            dob = dobRaw.toDate();
                          } else if (dobRaw is DateTime) {
                            dob = dobRaw;
                          } else {
                            dob = DateTime.tryParse(dobRaw.toString()) ??
                                DateTime.now();
                          }
                          _dobController.text =
                              DateFormat('dd/MM/yyyy').format(dob);
                        } else {
                          _dobController.text = '';
                        }
                        _avatarController.text = userData['avatar'] ?? '';
                        _gender = userData['Gender'] ?? '';
                      }
                    }
                    final avatarUrl = _avatarController.text;
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (avatarUrl.isNotEmpty
                                          ? NetworkImage(avatarUrl)
                                              as ImageProvider
                                          : null),
                                  child:
                                      (_imageFile == null && avatarUrl.isEmpty)
                                          ? const Icon(Icons.person, size: 50)
                                          : null,
                                ),
                                if (_isEditing)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.camera_alt,
                                            color: Colors.white),
                                        onPressed:
                                            _isLoading ? null : _pickImage,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (_isLoading)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: CircularProgressIndicator(),
                              ),
                            const SizedBox(height: 30.0),
                            _buildTextInputField(
                              controller: _firstNameController,
                              label: 'Tên',
                              hintText: 'hùng',
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16.0),
                            _buildTextInputField(
                              controller: _lastNameController,
                              label: 'Họ và tên đệm',
                              hintText: 'Lê Minh',
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16.0),
                            _buildTextInputField(
                              controller: _parentNumberController,
                              label: 'Số điện thoại',
                              hintText: '0123 456 789',
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16.0),
                            _buildTextInputField(
                              controller: _parentEmailController,
                              label: 'Email',
                              hintText: 'email@example.com',
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextInputField(
                                    controller: _dobController,
                                    label: 'Ngày sinh',
                                    hintText: 'dd/mm/yyyy',
                                    readOnly: true,
                                    enabled: _isEditing,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Giới tính',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      const SizedBox(height: 8.0),
                                      AbsorbPointer(
                                        absorbing: !_isEditing,
                                        child: DropdownButtonFormField<String>(
                                          value: _gender,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                          ),
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'Nam',
                                              child: Text('Nam'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Nữ',
                                              child: Text('Nữ'),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (_isEditing)
                                              setState(() {
                                                _gender = val;
                                              });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Thêm logic nâng cấp tài khoản
                              },
                              icon: Icon(Icons.upgrade),
                              label: Text('Nâng cấp tài khoản',
                                  style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: Color(0xff0e0e0e)),
              filled: true,
              fillColor: Color.fromARGB(255, 207, 241, 255),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
