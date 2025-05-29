import 'package:animal_2/user/splash/splash_animal.dart';
import 'package:animal_2/user/ui/regist_screen/sign_up_screen.dart';
import 'package:animal_2/user/ui/ui_home_main.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // TODO: Implement your own authentication logic here
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi không mong muốn: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                    child: Image.asset(
                      OneImages.ar_logo,
                    ),
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
                            color: Color(0xff4e4e4e).withOpacity(0.6),
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
                            color: Color(0xff000000).withOpacity(0.3),
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
                            color: Color(0xff4e4e4e).withOpacity(0.6),
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
                            color: Color(0xff000000).withOpacity(0.3),
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
                          return null;
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
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 60),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff601b7c),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Đăng Nhập',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xffffffff)))),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrationScreen()),
                        );
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
