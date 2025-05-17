import 'package:animal_2/user/splash/splash_animal.dart';
import 'package:animal_2/user/ui/regist_screen/sign_up_screen.dart';
import 'package:animal_2/user/ui/ui_home_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../admin/home_dashboard/dashboard_homepage.dart';
import '../../const/ar_image.dart';
import '../ui_home_tabs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  // Controllers để lấy giá trị từ các trường nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Biến để lưu trữ thông báo lỗi (nếu có)
  String? _errorMessage;

  // Biến để theo dõi trạng thái loading khi đang xử lý đăng nhập
  bool _isLoading = false;

  Future<void> _login() async {
    // Reset lỗi và bắt đầu trạng thái loading
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Gọi phương thức signInWithEmailAndPassword của Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            // Lấy email và loại bỏ khoảng trắng thừa
            password: _passwordController.text, // Lấy mật khẩu
          );

      // Nếu đăng nhập thành công, userCredential.user sẽ chứa thông tin người dùng
      print('Đăng nhập thành công: ${userCredential.user!.uid}');

      // TODO: Điều hướng đến trang chính của ứng dụng sau khi đăng nhập thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()), // Thay HomePage bằng trang chính của bạn
      );

      //TODO (Tùy chọn): Lấy dữ liệu người dùng từ Firestore sau khi đăng nhập
      // String uid = userCredential.user!.uid;
      // DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      // if (userData.exists) {
      //   Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
      //   print('Dữ liệu người dùng từ Firestore: $data');
      //   // Sử dụng dữ liệu này để cập nhật UI hoặc truyền sang trang khác
      // } else {
      //   print('Không tìm thấy dữ liệu người dùng trong Firestore.');
      //   // Có thể tạo dữ liệu người dùng ban đầu nếu cần
      // }


      // TODO (Tùy chọn): Lấy dữ liệu người dùng từ Firestore sau khi đăng nhập
      String uid = userCredential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        print('Dữ liệu người dùng từ Firestore: $data');
        // Sử dụng dữ liệu này để cập nhật UI hoặc truyền sang trang khác
      } else {
        print('Không tìm thấy dữ liệu người dùng trong Firestore.');
        // Có thể tạo dữ liệu người dùng ban đầu nếu cần
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể từ Firebase Authentication
      String message = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng với Email này.';
      } else if (e.code == 'wrong-password') {
        message = 'Sai mật khẩu. Vui lòng thử lại.';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng Email không hợp lệ.';
      }
      // Thêm các trường hợp lỗi khác nếu cần (ví dụ: too-many-requests)

      print(
        'Lỗi Firebase Auth: ${e.code} - ${e.message}',
      ); // In lỗi chi tiết ra console

      // Cập nhật thông báo lỗi trên UI
      if (!mounted) return;
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      // Xử lý các lỗi khác không liên quan đến Firebase Auth
      print('Lỗi chung: $e');
      // Kiểm tra mounted trước khi gọi setState
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi không mong muốn: $e';
      });
    } finally {
      // Dù thành công hay thất bại, kết thúc trạng thái loading
      // Kiểm tra mounted trước khi gọi setState
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Giải phóng controllers khi widget không còn được sử dụng
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(OneImages.ar_background),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                //logo
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                    child: Image.asset(OneImages.ar_logo),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Email'),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff4e4e4e).withValues(alpha: 0.6),
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Nhập Email của bạn',
                          hintStyle: TextStyle(
                            color: Color(0xff000000).withValues(alpha: 0.3),
                          ),
                          prefixIcon: Icon(Icons.email_outlined),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập Email';
                          }
                          // Có thể thêm regex để kiểm tra định dạng email
                          // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          //   return 'Định dạng Email không hợp lệ';
                          // }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Mật khẩu'),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff4e4e4e).withValues(alpha: 0.6),
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        textAlignVertical: TextAlignVertical.center,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          hintStyle: TextStyle(
                            color: Color(0xff000000).withValues(alpha: 0.3),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          isCollapsed: false,
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          // Có thể thêm kiểm tra độ dài mật khẩu
                          // if (value.length < 6) {
                          //   return 'Mật khẩu phải có ít nhất 6 ký tự';
                          // }
                          return null; // Trả về null nếu hợp lệ
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _errorMessage!, // Hiển thị nội dung lỗi
                      style: TextStyle(color: Colors.red, fontSize: 14), // Màu đỏ cho lỗi
                      textAlign: TextAlign.center, // Căn giữa thông báo lỗi
                    ),
                  ),
                SizedBox(height: 60),

                //login button
                _isLoading
                ? Center(child: CircularProgressIndicator(),)
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login(); // Gọi hàm xử lý đăng nhập
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff601b7c),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Padding cho nút
                      // Kích thước chữ
                      shape: RoundedRectangleBorder( // Bo tròn góc nút
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Đăng Nhập', style: TextStyle(
                        fontSize: 18, color: Color(0xffffffff)
                    ))),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AdminDashboard()),
                        );
                        // Get
                      },
                      child: Text('Quên mật khẩu', style: TextStyle()),
                    ),
                    Container(
                      width: 1,
                      height: 10,
                      decoration: BoxDecoration(color: Color(0xff000000)),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => RegistrationScreen());
                      },
                      child: Text('Đăng ký', style: TextStyle()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
