import 'package:animal_2/const/ar_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../const/ar_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    child: Text('Tên đăng nhập'),
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
                              offset: Offset(0, 4)
                          )
                        ]
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tên đăng nhập',
                        hintStyle: TextStyle(
                          color: Color(0xff000000).withValues(alpha: 0.3),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: InputBorder.none,
                      ),
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
                              offset: Offset(0, 4)
                          )
                        ]
                    ),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        hintStyle: TextStyle(
                          color: Color(0xff000000).withValues(alpha: 0.3),
                        ),
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xffCCCCFF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff4e4e4e).withValues(alpha: 0.6),
                      spreadRadius: 0,
                      blurRadius: 1,
                      offset: Offset(0, 4)
                    )
                  ]
                ),
                child: Text('Đăng Nhập', style: TextStyle(

                ),),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('Quên mật khẩu', style: TextStyle(

                    )),
                  ),
                  Container(
                    width: 1,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xff000000)
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Đăng ký', style: TextStyle(
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
