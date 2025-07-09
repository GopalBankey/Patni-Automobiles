import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:numberplatefinder/controller/connectivity_controller.dart';
import 'package:numberplatefinder/views/connectivity_banner.dart';
import 'package:numberplatefinder/views/splah_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ConnectivityController());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Patni Automobiles',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const Positioned(bottom: 0, child: BottomConnectivityBanner()),
          ],
        );
      },
    );
  }
}
