import 'package:animal_2/user/splash/splash_animal.dart';
import 'package:animal_2/user/ui/login_screen/login_screen.dart';
import 'package:animal_2/user/ui/ui_home_nature.dart';
import 'package:animal_2/user/ui/ui_home_tabs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animal App',
      home: SplashScreen(),
    );
  }
}
