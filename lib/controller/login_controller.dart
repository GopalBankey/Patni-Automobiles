import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  Future<void> login() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2));
    isLoading.value = false;
    GetStorage().write('isLoggedIn', true);
    Get.offAll(() =>  HomeScreen());
  }
}
