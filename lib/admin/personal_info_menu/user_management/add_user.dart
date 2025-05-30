import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart'; // Cần thêm dependency intl và import để định dạng ngày
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

  // Controllers cho Text Input Fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

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
      _avatarController.text = widget.user!.avatarUrl;
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
    _avatarController.dispose();
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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
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
        'avatar': _avatarController.text,
      };
      await _userService.addUser(userData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Thêm người dùng thành công'),
            backgroundColor: Colors.green));
        Navigator.pop(context);
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
        // actions: [ // Có thể thêm nút Save ở đây nếu cần
        //   TextButton(onPressed: () { /* TODO: Lưu thông tin */ }, child: Text('Lưu')),
        // ],
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
              // Placeholder Avatar tròn lớn
              CircleAvatar(
                radius: 60, // Kích thước lớn
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 50),
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
                  final phoneReg = RegExp(r'^[0-9]{9,11}\$');
                  if (!phoneReg.hasMatch(value.replaceAll(' ', ''))) {
                    return 'Số điện thoại chỉ gồm 9-11 chữ số';
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
                  final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
                  if (!emailReg.hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextInputField(
                controller: _avatarController,
                label: 'Link ảnh đại diện',
                hintText: 'https://...',
                keyboardType: TextInputType.url,
                validator: (value) {
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
                        ? const CircularProgressIndicator(color: Colors.white)
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
