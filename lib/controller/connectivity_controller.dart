import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final isConnected = true.obs;
  final showOnlineBanner = false
      .obs; // This controls the temporary "You're back online" banner

  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _initializeConnection();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool previousStatus = isConnected.value;
    isConnected.value = result != ConnectivityResult.none;

    if (!isConnected.value && previousStatus) {
      // Stay offline
    } else if (isConnected.value && !previousStatus) {
      // Temporarily show "You're back online"
      showOnlineBanner.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        showOnlineBanner.value = false;
      });
    }
  }

  Future<void> _initializeConnection() async {
    final result = await _connectivity.checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;
  }
}

