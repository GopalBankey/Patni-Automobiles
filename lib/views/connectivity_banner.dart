import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberplatefinder/controller/connectivity_controller.dart';
class BottomConnectivityBanner extends StatelessWidget {
  const BottomConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectivityController c = Get.find();

    return Obx(() {
      if (!c.isConnected.value) {
        return _buildBanner("You are offline", Colors.red);
      } else if (c.showOnlineBanner.value) {
        return _buildBanner("You're back online", Colors.green);
      } else {
        return const SizedBox.shrink(); // No banner
      }
    });
  }

  Widget _buildBanner(String text, Color color) {
    return Material(

      child: Container(
        width: Get.width,
        // margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          // borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white,fontSize: 12),
          ),
        ),
      ),
    );
  }
}
