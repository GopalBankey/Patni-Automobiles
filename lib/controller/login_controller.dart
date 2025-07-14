import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:numberplatefinder/utils/snackbar_util.dart';
import 'package:numberplatefinder/views/home_screen.dart';

class LoginController extends GetxController {
  var isLoggedIn = false.obs;
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var isLoading = false.obs;

  @override
  void onInit() {
    isLoggedIn.value = GetStorage().read('isLoggedIn') ?? false;
    print('-------------${isLoggedIn.value}');
    super.onInit();
  }

  String mobile = '9824032105';
  String password = 'Patniauto@2025';
  Future<void> login() async {
    if (mobileController.text.trim() != mobile ||
        passwordController.text.trim() != password) {
      SnackbarUtil.showError( 'Error',
        'Invalid credentials',);
      return;
    }
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1));
    isLoading.value = false;
    mobileController.clear();
    passwordController.clear();
    GetStorage().write('isLoggedIn', true);
    Get.offAll(() => HomeScreen());
  }
}
