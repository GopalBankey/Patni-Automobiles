import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberplatefinder/controller/login_controller.dart';
import 'package:numberplatefinder/customs/common_button.dart';
import 'package:numberplatefinder/customs/custom_textformfiled.dart';
import 'package:numberplatefinder/utils/app_colors.dart';
import 'package:numberplatefinder/utils/validators.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                child: Image.asset('assets/images/app_logo.png', scale: 2.5),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      width: screenWidth,
                      height: screenHeight * 0.7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.28),
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone,
                              maxLength: 10,
                              validator: (value) => Validators.phone(value),
                              label: 'Mobile',
                              hint: 'Mobile',
                              controller: loginController.mobileController,
                            ),
                            const SizedBox(height: 20),
                            CustomTextFormField(
                              prefixIcon: Icons.password,
                              isPassword: true,
                              validator: (value) => Validators.password(value),
                              label: 'Password',
                              hint: 'Password',
                              controller: loginController.passwordController,
                            ),
                            const SizedBox(height: 40),
                            Obx(() {
                              return loginController.isLoading.value
                                  ? const CircularProgressIndicator()
                                  : CommonButton(
                                text: 'Login',
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    loginController.login();
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -290,
                      left: -20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              AppColors.primary,
                              const Color(0xff367ead),
                            ],
                          ),
                        ),
                        width: screenHeight * 0.6,
                        height: screenHeight * 0.6,
                        child: Column(
                          children: [
                            const SizedBox(height: 300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/company_logo.png',
                                  color: Colors.white,
                                  scale: 3,
                                ),
                                SizedBox(width: screenWidth * 0.15),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
