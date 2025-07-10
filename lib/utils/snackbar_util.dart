import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtil {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.greenAccent,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      dismissDirection: DismissDirection.horizontal, //

      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds:4 ),
    );
  }

  static void showError(String title, String message, {int seconds = 4}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      dismissDirection: DismissDirection.horizontal, //
      margin: const EdgeInsets.all(15),
      duration: Duration(seconds: seconds),

    );
  }


  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blueGrey,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      dismissDirection:DismissDirection.horizontal ,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 4),
    );
  }
}
