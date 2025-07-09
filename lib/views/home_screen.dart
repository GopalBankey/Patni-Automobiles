import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:numberplatefinder/controller/number_plate_controller.dart';
import 'package:numberplatefinder/customs/common_button.dart';
import 'package:numberplatefinder/customs/custom_app_bar.dart';
import 'package:numberplatefinder/models/entries_model.dart' show EntryData;
import 'package:numberplatefinder/utils/app_colors.dart';
import 'package:numberplatefinder/views/login_screen.dart';
import 'package:numberplatefinder/views/number_plate_scanner.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final controller = Get.put(NumberPlateController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Vehicle Entries",
        showBackButton: false,
        actions: [
          IconButton(onPressed: () {

            controller. exportEntriesToExcel();

          }, icon: Icon(Icons.download)),

          IconButton(
            onPressed: () {
              Get.defaultDialog(
                titleStyle: TextStyle(fontWeight: FontWeight.w500),
                title: 'Logout',
                middleText: 'Are you sure you want to logout?',
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      SizedBox(width: 20),
                      CommonButton(
                        width: 70,
                        height: 40,
                        borderRadius: 20,
                        text: 'OK',
                        onTap: () async {
                          GetStorage().remove('isLoggedIn');
                          Get.offAll(LoginScreen());
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              );
            },
            icon: Icon(Icons.logout),
          ),
          

        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20,bottom: 6),
        child: CommonButton(
          // width: 200,
          text: 'IN +',
          onTap: () {
            controller.searchNode.unfocus();
            Get.to(() => NumberPlateScanner());
          },
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await controller.getEntries();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Search Bar
              TextField(
                focusNode: controller.searchNode,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Search by vehicle number...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) async {
                  await controller.searchEntries(value);
                },
              ),
              const SizedBox(height: 20),

              /// Car List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  } else if (controller.searchEntriesList.isEmpty) {
                    return Center(
                      child: Text(
                        'No vehicle entries yet.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.searchEntriesList.length,
                    padding: EdgeInsets.only(bottom: 60),
                    // separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final EntryData entryData =
                          controller.searchEntriesList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: AppColors.background,
                        elevation: 2,

                        child: ListTile(
                          leading: Text('🏍️', style: TextStyle(fontSize: 30)),
                          title: Text(
                            entryData.vehicleNumber ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'IN: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('EEE, dd MMM    hh:mm a').format(
                                      DateTime.parse(entryData.inTime ?? ''),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),

                              entryData.outTime == null
                                  ? SizedBox()
                                  : Row(
                                    children: [
                                      Text(
                                        'OUT: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'EEE, dd MMM    hh:mm a',
                                        ).format(
                                          DateTime.parse(
                                            entryData.outTime ?? '',
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                            ],
                          ),

                          trailing:
                              entryData.outTime == null
                                  ? GestureDetector(
                                    onTap: () {
                                      controller.searchNode.unfocus();

                                      Get.defaultDialog(
                                        contentPadding: EdgeInsets.zero,

                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,

                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    side: BorderSide(
                                                      color: AppColors.primary,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              CommonButton(
                                                width: 70,
                                                height: 40,
                                                borderRadius: 20,
                                                text: 'OK',
                                                onTap: () async {
                                                  Get.back();
                                                  await controller.outEntry(
                                                    entryData.vehicleNumber ??
                                                        '',
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                        ],

                                        title: 'Confirm',

                                        // middleText:
                                        //     'Are you sure you want to this out this vehicle (${entryData.vehicleNumber}) ?',
                                        titleStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                        content: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    'Are you sure you want to out this vehicle ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${entryData.vehicleNumber}',
                                                style: TextStyle(
                                                  color: Colors.black,

                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' ?',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        middleTextStyle: TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),

                                        // buttonColor: AppColors.primary
                                      );
                                    },
                                    child: Text(
                                      'OUT',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                  : SizedBox(),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
