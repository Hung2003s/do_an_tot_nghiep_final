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
  final TextEditingController _middleLastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); // Cho Ngày sinh

  // Biến trạng thái cho Giới tính
  Gender? _selectedGender; // Lưu giới tính được chọn

  // Biến trạng thái để theo dõi chế độ chỉnh sửa
  bool _isEditing = false; // Ban đầu là chế độ xem

  @override
  void initState() {
    super.initState();
    // Điền dữ liệu từ user object nếu có (cho màn hình chỉnh sửa)
    if (widget.user != null) {
      _middleLastNameController.text = widget.user!.middleLastName ?? '';
      _firstNameController.text = widget.user!.firstName ?? '';
      _phoneController.text = widget.user!.phoneNumber ?? '';
      _emailController.text = widget.user!.email ?? '';
      if (widget.user!.dateOfBirth != null) {
        _dobController.text = DateFormat('dd/MM/yyyy').format(widget.user!.dateOfBirth!);
      }
      _selectedGender = widget.user!.gender;
    }
  }

  @override
  void dispose() {
    // Giải phóng controllers
    _middleLastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nút Sửa/Lưu được bấm
  void _toggleEditSave() {
    if (_isEditing) {
      // Đang ở chế độ chỉnh sửa, bấm nút Lưu
      _saveChanges(); // Gọi hàm lưu thay đổi
    } else {
      // Đang ở chế độ xem, bấm nút Sửa
      // Chuyển sang chế độ chỉnh sửa
      setState(() {
        _isEditing = true;
      });
    }
  }

  // Hàm lưu thay đổi
  void _saveChanges() {
    // TODO: Thu thập dữ liệu từ các trường input và trạng thái
    final middleLastName = _middleLastNameController.text;
    final firstName = _firstNameController.text;
    final phoneNumber = _phoneController.text;
    final email = _emailController.text;
    final dobString = _dobController.text;
    DateTime? dateOfBirth;
    try {
      dateOfBirth = DateFormat('dd/MM/yyyy').parse(dobString);
    } catch (e) {
      print("Error parsing date: $e");
      // Xử lý lỗi parse ngày (ví dụ: hiển thị thông báo lỗi cho người dùng)
    }
    final gender = _selectedGender;

    // In ra dữ liệu đã thu thập (Để kiểm tra)
    print('Họ và tên đệm: $middleLastName');
    print('Tên: $firstName');
    print('Số điện thoại: $phoneNumber');
    print('Email: $email');
    print('Ngày sinh: $dateOfBirth');
    print('Giới tính: $gender');

    // TODO: Gửi dữ liệu này lên API hoặc lưu vào cơ sở dữ liệu

    // Sau khi lưu xong, chuyển lại về chế độ xem
    setState(() {
      _isEditing = false;
    });
    // TODO: Hiển thị thông báo thành công hoặc lỗi
  }


  // Hàm hiển thị Date Picker và chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    // Chỉ cho phép chọn ngày khi ở chế độ chỉnh sửa
    if (!_isEditing) return;

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
        title: const Text('Quản lý người dùng'), // Hoặc "Thông tin người dùng"
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleEditSave, // Gọi hàm xử lý Sửa/Lưu
            child: Text(
              _isEditing ? 'LƯU' : 'SỬA', // Thay đổi text của nút
              style: TextStyle(color: _isEditing ? Colors.green : Colors.orange), // Thay đổi màu nút
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder Avatar tròn lớn
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              // TODO: Hiển thị ảnh avatar của user nếu có widget.user
            ),
            const SizedBox(height: 30.0),

            // --- Các trường nhập thông tin ---
            _buildTextInputField(
              controller: _middleLastNameController,
              label: 'Họ và tên đệm',
              hintText: 'Nguyễn Văn',
              readOnly: !_isEditing, // Chỉ đọc khi không ở chế độ chỉnh sửa
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _firstNameController,
              label: 'Tên',
              hintText: 'A',
              readOnly: !_isEditing, // Chỉ đọc khi không ở chế độ chỉnh sửa
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hintText: '0123 456 789',
              keyboardType: TextInputType.phone,
              readOnly: !_isEditing, // Chỉ đọc khi không ở chế độ chỉnh sửa
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _emailController,
              label: 'Email',
              hintText: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
              readOnly: !_isEditing, // Chỉ đọc khi không ở chế độ chỉnh sửa
            ),
            const SizedBox(height: 16.0),

            // --- Ngày tháng năm sinh và Giới tính ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ngày tháng năm sinh
                Expanded(
                  flex: 2,
                  child: _buildTextInputField(
                    controller: _dobController,
                    label: 'Ngày tháng năm sinh',
                    hintText: 'dd/mm/yyyy',
                    readOnly: true, // Luôn chỉ đọc, mở date picker bằng onTap
                    onTap: () {
                      // Chỉ cho phép mở date picker khi ở chế độ chỉnh sửa
                      if(_isEditing) _selectDate(context);
                    },
                  ),
                ),
                const SizedBox(width: 16.0),

                // Giới tính
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Giới tính', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
                      // Radio Buttons chỉ hoạt động khi ở chế độ chỉnh sửa
                      Row( // Radio Button Nam
                        children: [
                          Radio<Gender>(
                            value: Gender.male,
                            groupValue: _selectedGender,
                            onChanged: _isEditing ? (Gender? newValue) { // Chỉ cho phép thay đổi khi _isEditing là true
                              setState(() {
                                _selectedGender = newValue;
                              });
                            } : null, // Nếu không chỉnh sửa, onChanged là null (không tương tác được)
                            activeColor: Colors.orange,
                          ),
                          const Text('Nam'),
                        ],
                      ),
                      Row( // Radio Button Nữ
                        children: [
                          Radio<Gender>(
                            value: Gender.female,
                            groupValue: _selectedGender,
                            onChanged: _isEditing ? (Gender? newValue) { // Chỉ cho phép thay đổi khi _isEditing là true
                              setState(() {
                                _selectedGender = newValue;
                              });
                            } : null, // Nếu không chỉnh sửa, onChanged là null
                            activeColor: Colors.orange,
                          ),
                          const Text('Nữ'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            _isEditing ? Center( // Căn giữa nút
              child: ElevatedButton(
                onPressed: _saveChanges, // Gọi hàm lưu thay đổi
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Màu nền cam
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0), // Padding nút
                  shape: RoundedRectangleBorder( // Bo tròn góc
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(double.infinity, 50), // Chiếm hết chiều rộng và chiều cao tối thiểu
                ),
                child: const Text(
                  'LƯU THAY ĐỔI',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ) : Container(),
            const SizedBox(height: 16.0),
            // TODO: Thêm nút Save ở dưới cùng nếu bạn muốn có 2 nút Save (trên và dưới)

          ],
        ),
      ),
      // Bottom Navigation Bar (Tái sử dụng)
      // bottomNavigationBar: _buildBottomNavigationBar(), // Cần implement hàm này
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
    bool readOnly = false, // Default readOnly is false
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly, // Sử dụng giá trị readOnly được truyền vào
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: _isEditing ? Color(0xffd5d5d5) : Color(0xffb0f7ff),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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