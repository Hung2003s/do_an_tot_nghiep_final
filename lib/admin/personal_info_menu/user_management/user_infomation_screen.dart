import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../model/user.dart';

// Import Bottom Navigation Bar components nếu cần
// import 'bottom_navigation_bar.dart';

class UserInfoScreen extends StatefulWidget {
  // Nhận đối tượng User để hiển thị thông tin (tùy chọn, nếu là màn hình chỉnh sửa)
  final User? user;

  const UserInfoScreen({Key? key, this.user}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  // Controllers cho Text Input Fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  // Biến trạng thái cho Giới tính
  Gender? _selectedGender; // Lưu giới tính được chọn

  // Biến trạng thái để theo dõi chế độ chỉnh sửa
  bool _isEditing = false; // Ban đầu là chế độ xem
  bool _isLoading = false;

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

  // Hàm xử lý khi nút Sửa/Lưu được bấm
  void _toggleEditSave() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thông tin cá nhân'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleEditSave,
            child: Text(_isEditing ? 'LƯU' : 'SỬA',
                style: TextStyle(
                    color: _isEditing ? Colors.green : Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: _avatarController.text.isNotEmpty
                  ? NetworkImage(_avatarController.text)
                  : null,
              child: _avatarController.text.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 30.0),
            _buildTextInputField(
              controller: _firstNameController,
              label: 'Họ',
              hintText: 'Lê',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _lastNameController,
              label: 'Tên',
              hintText: 'Minh',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _phoneNumberController,
              label: 'Số điện thoại',
              hintText: '0123 456 789',
              enabled: _isEditing,
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _emailController,
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
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Giới tính',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      const SizedBox(height: 8.0),
                      Container(
                        child: DropdownButtonFormField<Gender>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
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
                          onChanged: _isEditing
                              ? (Gender? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (_isEditing)
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'LƯU THAY ĐỔI',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  // Hàm trợ giúp để xây dựng các trường nhập text
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
                color: Colors.grey)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          enabled: enabled,
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

  // TODO: Implement hàm build Bottom Navigation Bar (tái sử dụng từ màn hình trước)
  // Widget _buildBottomNavigationBar() {
  //   return BottomAppBar(...);
  // }
}
