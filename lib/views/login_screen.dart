import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberplatefinder/controller/login_controller.dart';
import 'package:numberplatefinder/customs/common_button.dart';
import 'package:numberplatefinder/customs/custom_textformfiled.dart';
import 'package:numberplatefinder/utils/app_colors.dart';
import 'package:numberplatefinder/utils/validators.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: loginController.fromKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .3,
                child: Image.asset('assets/images/app_logo.png', scale: 2.5),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height * .7,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * .28,
                            ),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 20),
                            CustomTextFormField(
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone,
                              maxLength: 10,

                              validator: (value) => Validators.phone(value),

                              label: 'Mobile',
                              hint: 'Mobile',
                              controller: loginController.mobileController,
                            ),
                            SizedBox(height: 20),
                            CustomTextFormField(
                              prefixIcon: Icons.password,
                              isPassword: true,

                              validator: (value) => Validators.password(value),
                              label: 'Password',
                              hint: 'Password',
                              controller: loginController.passwordController,
                            ),
                            SizedBox(height: 40),
                            Obx(() {
                              return loginController.isLoading.value
                                  ? CircularProgressIndicator()
                                  : CommonButton(
                                    text: 'Login',
                                    onTap: () {
                                      if (loginController.fromKey.currentState!
                                          .validate()) {
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
                          color: AppColors.primary,
                          shape: BoxShape.circle,

                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [AppColors.primary, Color(0xff367ead)],
                          ),
                        ),
                        width: MediaQuery.sizeOf(context).height * .6,
                        height: MediaQuery.sizeOf(context).height * .6,
                        child: Column(
                          children: [
                            SizedBox(height: 300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/company_logo.png',
                                  color: Colors.white,
                                  scale: 3,
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * .15,
                                ),
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
