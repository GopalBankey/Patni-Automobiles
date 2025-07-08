import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:numberplatefinder/customs/common_button.dart';
import 'package:numberplatefinder/customs/custom_app_bar.dart';
import 'package:numberplatefinder/utils/app_colors.dart';
import '../controller/number_plate_controller.dart';

class NumberPlateScanner extends StatelessWidget {
  NumberPlateScanner({super.key});
  final NumberPlateController controller = Get.find<NumberPlateController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          controller.numberPlateController.clear();
          controller.imageFile = Rx<File>(File(''));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: 'Add Vehicle Details'),
        body: GetBuilder<NumberPlateController>(
          builder: (_) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Scan & Save Vehicle',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final now = controller.currentTime.value;
                    return Text(
                      'Date: ${DateFormat('EEE, dd MMM yyyy hh:mm:ss a').format(now)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    );
                  }),

                  const SizedBox(height: 30),

                  /// Vehicle Number Input
                  TextFormField(
                    controller: controller.numberPlateController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Vehicle Number',
                      prefixIcon: Icon(Icons.pedal_bike_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Image Preview
                  Obx(() {
                    return controller.imageFile?.value.path != ''
                        ? Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                controller.imageFile!.value,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: -5,
                              top: -10,
                              child: GestureDetector(
                                onTap: () {
                                  controller.imageFile?.value = File('');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : GestureDetector(
                          onTap: () {
                            controller.pickImage();
                          },
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: Radius.circular(20),
                              dashPattern: [5],
                              color: Colors.black,
                            ),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(12),
                              //   border: Border.all(color: Colors.black,width: 1.5),
                              // ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 35,
                                    color: AppColors.primary,
                                  ),
                                  Text(
                                    'No Image Selected',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                  }),

                  //   onPressed: controller.pickImage,
                  //   icon: Icon(Icons.photo),
                  //   label: Text('Pick Image'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.cyan,
                  //     foregroundColor: Colors.white,
                  //     minimumSize: Size(double.infinity, 48),
                  //     shape: RoundedRectangleBorder(
                  //
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 30),

                  /// Submit Button
                  Obx(() {
                    return controller.isLoading.value
                        ? CircularProgressIndicator()
                        : CommonButton(
                          text: 'Submit Vehicle',
                          onTap: () async {
                            final plate =
                                controller.numberPlateController.text
                                    .trim()
                                    .toUpperCase();

                            // Check empty
                            if (plate.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please enter the vehicle number',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(12),
                              );
                              return;
                            }

                            // Check format
                            final isValid = controller.numberPlatePatterns.any(
                              (pattern) => pattern.hasMatch(plate),
                            );

                            if (!isValid) {
                              Get.snackbar(
                                'Error',
                                'Please enter a valid vehicle number',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(12),
                              );
                              return;
                            }

                            // Call API
                            await controller.addEntry();
                          },
                        );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
