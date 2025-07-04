import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberplatefinder/controller/login_controller.dart';
import 'package:numberplatefinder/views/home_screen.dart';
import 'package:numberplatefinder/views/login_screen.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      final authController = Get.put(LoginController());
      if (authController.isLoggedIn.value) {
        Get.offAll(()=>HomeScreen());
      } else {
        Get.offAll(()=>LoginScreen());
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/company_logo.png', scale: 3),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            // Text("Checking login...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
