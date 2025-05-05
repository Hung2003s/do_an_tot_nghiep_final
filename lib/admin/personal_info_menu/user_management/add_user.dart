import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart'; // Cần thêm dependency intl và import để định dạng ngày
import '../../model/user.dart';
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
  // Controllers cho Text Input Fields
  final TextEditingController _middleLastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); // Cho Ngày sinh

  // Biến trạng thái cho Giới tính
  Gender? _selectedGender; // Lưu giới tính được chọn

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
      body: SingleChildScrollView( // Cho phép cuộn form
        padding: const EdgeInsets.all(16.0), // Padding cho toàn bộ form
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang cho avatar
          children: [
            // Placeholder Avatar tròn lớn
            CircleAvatar(
              radius: 60, // Kích thước lớn
              backgroundColor: Colors.grey[300],
              // TODO: Thêm Image.network hoặc Image.asset cho ảnh thật
            ),
            const SizedBox(height: 30.0), // Khoảng cách

            // --- Các trường nhập thông tin ---
            _buildTextInputField(
              controller: _middleLastNameController,
              label: 'Họ và tên đệm',
              hintText: 'Nguyễn Văn',
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _firstNameController,
              label: 'Tên',
              hintText: 'A',
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hintText: '0123 456 789',
              keyboardType: TextInputType.phone, // Kiểu bàn phím điện thoại
            ),
            const SizedBox(height: 16.0),
            _buildTextInputField(
              controller: _emailController,
              label: 'Email',
              hintText: 'email@example.com',
              keyboardType: TextInputType.emailAddress, // Kiểu bàn phím email
            ),
            const SizedBox(height: 16.0),

            // --- Ngày tháng năm sinh và Giới tính ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh các mục con lên trên
              children: [
                // Ngày tháng năm sinh
                Expanded( // Chiếm hết không gian còn lại cho Ngày sinh
                  flex: 2, // Tỉ lệ chiếm không gian
                  child: _buildTextInputField(
                    controller: _dobController,
                    label: 'Ngày tháng năm sinh',
                    hintText: 'dd/mm/yyyy',
                    readOnly: true, // Không cho nhập trực tiếp
                    onTap: () {
                      _selectDate(context); // Mở Date Picker khi bấm vào
                    },
                  ),
                ),
                const SizedBox(width: 16.0), // Khoảng cách

                // Giới tính
                Expanded( // Chiếm một phần không gian cho Giới tính
                  flex: 1, // Tỉ lệ chiếm không gian
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Giới tính', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Row( // Radio Button Nam
                        children: [
                          Radio<Gender>(
                            value: Gender.male,
                            groupValue: _selectedGender, // Nhóm các radio button
                            onChanged: (Gender? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                            activeColor: Colors.orange, // Màu khi được chọn
                          ),
                          const Text('Nam'),
                        ],
                      ),
                      Row( // Radio Button Nữ
                        children: [
                          Radio<Gender>(
                            value: Gender.female,
                            groupValue: _selectedGender,
                            onChanged: (Gender? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                            activeColor: Colors.orange,
                          ),
                          const Text('Nữ'),
                        ],
                      ),
                      // Có thể thêm radio button Unknown nếu cần
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Center( // Căn giữa nút
              child: ElevatedButton(
                onPressed: () {}, // Gọi hàm lưu thay đổi
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
            ),
            const SizedBox(height: 16.0),


            // Khoảng cách cuối form

            // TODO: Thêm nút Save hoặc các nút khác nếu cần

          ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly, // Chỉ đọc nếu được set true
          onTap: onTap, // Hàm xử lý khi bấm vào (ví dụ: cho Date Picker)
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
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