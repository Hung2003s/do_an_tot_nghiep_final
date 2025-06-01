import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart'; // Cần thêm dependency intl và import để định dạng ngày
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../model/user.dart';
import '../../services/user_service.dart';
// Import model User (đã cập nhật)

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class AddUserScreen extends StatefulWidget {
  // Nhận đối tượng User để hiển thị thông tin (tùy chọn, nếu là màn hình chỉnh sửa)
  final User? user;

  const AddUserScreen({Key? key, this.user}) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = false;
  bool _isPickingImage = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Controllers cho Text Input Fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Biến trạng thái cho Giới tính
  Gender? _selectedGender; // Lưu giới tính được chọn

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _phoneNumberController.text = widget.user!.phoneNumber;
      _emailController.text = widget.user!.email;
      if (widget.user!.dateOfBirth != null) {
        _dobController.text =
            DateFormat('dd/MM/yyyy').format(widget.user!.dateOfBirth!);
      }
      _selectedGender = widget.user!.gender == 'Nam'
          ? Gender.male
          : widget.user!.gender == 'Nữ'
              ? Gender.female
              : Gender.unknown;
    }
  }

  @override
  void dispose() {
    // Giải phóng controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Hàm hiển thị Date Picker và chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Ngày bắt đầu mặc định
      firstDate: DateTime(1900), // Ngày sớm nhất có thể chọn
      lastDate: DateTime.now(), // Ngày muộn nhất có thể chọn (ví dụ: hôm nay)
    );
    if (picked != null) {
      setState(() {
        // Cập nhật text trong input field
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      String? imageUrl;

      // Upload image if selected
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': 'admin',
            'uploadTime': DateTime.now().toIso8601String(),
          },
        );

        final uploadTask = await storageRef.putFile(_imageFile!, metadata);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Tạo tài khoản Firebase Auth
      final userCredential =
          await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: 'user01', // Mật khẩu mặc định
      );

      final userData = {
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Phone_number': _phoneNumberController.text,
        'Email': _emailController.text,
        'DateOfBirth': _dobController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(_dobController.text)
            : null,
        'Gender': _selectedGender == Gender.male
            ? 'Nam'
            : _selectedGender == Gender.female
                ? 'Nữ'
                : '',
        'avatar': imageUrl ?? '',
        'role_id': 2,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userCredential.user?.uid,
      };

      // Log để kiểm tra dữ liệu trước khi lưu
      print('User data before saving: $userData');

      await _userService.addUser(userData);

      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Thêm người dùng thành công'),
            backgroundColor: Colors.green));

        // Hiển thị dialog thông tin tài khoản
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thông tin tài khoản'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tài khoản đã được tạo thành công với thông tin:'),
                  const SizedBox(height: 16),
                  Text('Email: ${_emailController.text}'),
                  const SizedBox(height: 8),
                  const Text('Mật khẩu mặc định: user01'),
                  const SizedBox(height: 16),
                  const Text(
                    'Lưu ý: Người dùng nên đổi mật khẩu sau khi đăng nhập lần đầu.',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog
                    Navigator.pop(context); // Quay lại màn hình trước
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } on auth.FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email không hợp lệ';
      } else {
        errorMessage = 'Lỗi khi tạo tài khoản: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Lỗi khi thêm người dùng: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: const Text('Thêm người dùng'), // Hoặc "Thông tin người dùng"
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveUser,
              child: const Text('LƯU', style: TextStyle(color: Colors.green)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        // Cho phép cuộn form
        padding: const EdgeInsets.all(16.0), // Padding cho toàn bộ form
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .center, // Căn giữa theo chiều ngang cho avatar
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60, // Kích thước lớn
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _isPickingImage ? null : _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isPickingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 30.0), // Khoảng cách

              // --- Các trường nhập thông tin ---
              _buildTextInputField(
                controller: _firstNameController,
                label: 'Họ',
                hintText: 'Lê',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextInputField(
                controller: _lastNameController,
                label: 'Tên',
                hintText: 'Minh',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextInputField(
                controller: _phoneNumberController,
                label: 'Số điện thoại',
                hintText: '0123 456 789',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  final phoneReg = RegExp(r'^[0-9]{10}$');
                  if (!phoneReg.hasMatch(value.replaceAll(' ', ''))) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextInputField(
                controller: _emailController,
                label: 'Email',
                hintText: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  final emailReg = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailReg.hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // --- Ngày tháng năm sinh và Giới tính ---
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Căn chỉnh các mục con lên trên
                children: [
                  // Ngày tháng năm sinh
                  Expanded(
                    // Chiếm hết không gian còn lại cho Ngày sinh
                    flex: 2, // Tỉ lệ chiếm không gian
                    child: _buildTextInputField(
                      controller: _dobController,
                      label: 'Ngày tháng năm sinh',
                      hintText: 'dd/mm/yyyy',
                      readOnly: true, // Không cho nhập trực tiếp
                      onTap: () {
                        _selectDate(context); // Mở Date Picker khi bấm vào
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn ngày sinh';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0), // Khoảng cách

                  // Giới tính
                  Expanded(
                    // Chiếm một phần không gian cho Giới tính
                    flex: 1, // Tỉ lệ chiếm không gian
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giới tính',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 8.0),
                        _buildGenderDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Center(
                // Căn giữa nút
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Màu nền cam
                      foregroundColor: Colors.white, // Màu chữ trắng
                      shape: RoundedRectangleBorder(
                        // Bo tròn góc
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'THÊM NGƯỜI DÙNG',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Khoảng cách cuối form

              // TODO: Thêm nút Save hoặc các nút khác nếu cần
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(...), // Cần implement nút này
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Cần implement vị trí này
    );
  }

  // Hàm trợ giúp để xây dựng các trường nhập text
  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly, // Chỉ đọc nếu được set true
          onTap: onTap, // Hàm xử lý khi bấm vào (ví dụ: cho Date Picker)
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(
          value: Gender.male,
          child: Text('Nam'),
        ),
        DropdownMenuItem(
          value: Gender.female,
          child: Text('Nữ'),
        ),
      ],
      onChanged: (Gender? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn giới tính';
        }
        return null;
      },
    );
  }

// TODO: Implement hàm build Bottom Navigation Bar (tái sử dụng từ màn hình trước)
// Widget _buildBottomNavigationBar() {
//   return BottomAppBar(...);
// }
}
