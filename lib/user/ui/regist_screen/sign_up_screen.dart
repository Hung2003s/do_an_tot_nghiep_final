import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // GlobalKey để quản lý trạng thái của Form
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường nhập
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Giải phóng controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nút Đăng ký được bấm
  void _registerUser() {
    // Kiểm tra validation của form
    if (_formKey.currentState!.validate()) {
      // Nếu form hợp lệ, thực hiện logic đăng ký
      final email = _emailController.text;
      final password = _passwordController.text;

      // TODO: Implement logic đăng ký người dùng thực tế ở đây
      // Ví dụ: Sử dụng Firebase Authentication, gửi dữ liệu đến API backend, v.v.

      print('Email: $email');
      print('Password: $password');

      // Sau khi đăng ký thành công, bạn có thể điều hướng người dùng đến màn hình khác
      // Ví dụ: Navigator.pushReplacementNamed(context, '/home');
      // Hoặc hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công! (Logic demo)')),
      );

    } else {
      // Nếu form không hợp lệ, hiển thị thông báo lỗi (TextFormField sẽ tự hiển thị)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin nhập')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
        padding: const EdgeInsets.all(24.0), // Padding cho toàn bộ form
        child: Form( // Widget Form để quản lý các TextFormField và validation
          key: _formKey, // Gán GlobalKey cho Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Các mục con chiếm hết chiều rộng
            children: [
              // --- Trường Email ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Bàn phím tối ưu cho email
                decoration: _buildInputDecoration(labelText: 'Email', hintText: 'Nhập email của bạn'),
                validator: (value) { // Hàm validation
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Email';
                  }
                  // Thêm validation định dạng email nếu cần
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Định dạng Email không hợp lệ';
                  }
                  return null; // Trả về null nếu hợp lệ
                },
              ),
              const SizedBox(height: 16.0), // Khoảng cách

              // --- Trường Mật khẩu ---
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Ẩn ký tự mật khẩu
                decoration: _buildInputDecoration(labelText: 'Mật khẩu', hintText: 'Nhập mật khẩu'),
                validator: (value) { // Hàm validation
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Mật khẩu';
                  }
                  if (value.length < 6) { // Ví dụ: yêu cầu ít nhất 6 ký tự
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0), // Khoảng cách

              // --- Trường Xác nhận mật khẩu ---
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true, // Ẩn ký tự
                decoration: _buildInputDecoration(labelText: 'Xác nhận mật khẩu', hintText: 'Nhập lại mật khẩu'),
                validator: (value) { // Hàm validation
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận Mật khẩu';
                  }
                  if (value != _passwordController.text) { // Kiểm tra khớp với mật khẩu đã nhập
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0), // Khoảng cách

              // --- Nút Đăng ký ---
              ElevatedButton(
                onPressed: _registerUser, // Gán hàm xử lý khi bấm nút
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Màu nền cam
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding dọc
                  shape: RoundedRectangleBorder( // Bo tròn góc
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Đăng ký',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),

              // TODO: Thêm các widget khác nếu cần (ví dụ: nút "Đã có tài khoản? Đăng nhập")
            ],
          ),
        ),
      ),
    );
  }

  // Hàm trợ giúp để xây dựng Input Decoration với styling nhất quán
  InputDecoration _buildInputDecoration({required String labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder( // Viền bo tròn
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // Bỏ viền mặc định
      ),
      filled: true, // Nền màu
      fillColor: Colors.grey[200], // Màu nền xám nhạt
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    );
  }
}