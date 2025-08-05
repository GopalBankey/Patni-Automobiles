import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:numberplatefinder/models/entries_model.dart';
import 'package:numberplatefinder/services.dart';
import 'package:numberplatefinder/utils/api_urls.dart';
import 'package:numberplatefinder/utils/snackbar_util.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as sync;

class NumberPlateController extends GetxController {
  FocusNode searchNode = FocusNode();
  var isLoading = false.obs;
  Rx<File>? imageFile = Rx<File>(File(''));
  List<String> numberPlates = [];
  var entries = <EntryData>[].obs;
  var searchEntriesList = <EntryData>[].obs;
  TextEditingController numberPlateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  var currentTime = DateTime.now().obs;

  List<String> items=['Yes','No'];

  var selectedValue= Rxn<String>();



  @override
  Future<void> onInit() async {
    await getEntries();
    Timer.periodic(Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
    // TODO: implement onInit
    super.onInit();
  }

  final List<RegExp> numberPlatePatterns = [
    // Support for newer 5-digit ending number plates
    RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,4}[0-9]{5}$'),

    // Standard (No spaces or special chars): GJ01AB1234
    RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,4}[0-9]{3,4}$'),

    // Standard (No spaces or special chars): GJ01AB1234
    RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,4}[0-9]{3,4}$'),

    // With spaces: GJ 01 AB 1234
    RegExp(r'^[A-Z]{2}\s?[0-9]{1,2}\s?[A-Z]{1,4}\s?[0-9]{3,4}$'),
    RegExp(r'^[A-Z]{2}?[0-9]{1,2}\s?[A-Z]{1,4}\s?[0-9]{3,4}$'),
    RegExp(r'^[A-Z]{2}\s?[0-9]{1,2}?[A-Z]{1,4}\s?[0-9]{3,4}$'),
    RegExp(r'^[A-Z]{2}\s?[0-9]{1,2}\s?[A-Z]{1,4}?[0-9]{3,4}$'),

    // With hyphens: GJ-01-AB-1234
    RegExp(r'^[A-Z]{2}-[0-9]{1,2}-[A-Z]{1,4}-[0-9]{3,4}$'),

    // Bike short format: GJ1AB1234 or GJ01AB123
    RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,4}[0-9]{2,4}$'),
    RegExp(r'^[A-Z]{2}?[0-9]{1,2}\s?[A-Z]{1,4}\s?[0-9]{2,4}$'),
    RegExp(r'^[A-Z]{2}\s?[0-9]{1,2}?[A-Z]{1,4}\s?[0-9]{2,4}$'),
    RegExp(r'^[A-Z]{2}\s?[0-9]{1,2}\s?[A-Z]{1,4}?[0-9]{2,4}$'),

    // Temporary plates: TEMP123456 or TR1234
    RegExp(r'^(TEMP|TR)[0-9]{3,6}$'),

    // Govt vehicles: GJ01G1234
    RegExp(r'^[A-Z]{2}[0-9]{1,2}G[0-9]{3,4}$'),

    // Diplomatic: 22CD1234
    RegExp(r'^22CD[0-9]{4}$'),

    // Diplomatic: 22BH1234A
    RegExp(r'^22[A-Z]{2}[0-9]{3,4}[A-Z]?$'),

    // Military: 123456A or 12345A
    RegExp(r'^[0-9]{5,6}[A-Z]$'),

    // Old-style two-wheeler: GJ01M1234 (single middle letter)
    RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1}[0-9]{3,4}$'),
  ];

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      imageFile?.value = File(picked.path);
      numberPlates.clear();
      update();
      await scanForNumberPlates(imageFile!.value);
    }
  }

  Future<void> scanForNumberPlates(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    List<String> allLines = [];
    String? firstValidPlate;

    // Step 1: Process individual lines
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        String rawText = line.text.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
        String cleaned = replaceZerosWithQ(rawText.replaceAll('IND', ''));

        allLines.add(cleaned);

        for (final pattern in numberPlatePatterns) {
          if (pattern.hasMatch(cleaned)) {
            firstValidPlate = cleaned;
            break;
          }
        }
        if (firstValidPlate != null) break;
      }
      if (firstValidPlate != null) break;
    }

    // Step 2: Combine lines only if no match found yet
    if (firstValidPlate == null && allLines.length > 1) {
      for (int i = 0; i < allLines.length - 1; i++) {
        String combined2 = replaceZerosWithQ(allLines[i] + allLines[i + 1]);
        print('2-----$combined2');
        for (final pattern in numberPlatePatterns) {
          if (pattern.hasMatch(combined2)) {
            firstValidPlate = combined2;
            break;
          }
        }
        if (firstValidPlate != null) break;

        if (i + 2 < allLines.length) {
          String combined3 = replaceZerosWithQ(
            allLines[i] + allLines[i + 1] + allLines[i + 2],
          );
          print('3-----$combined3');
          for (final pattern in numberPlatePatterns) {
            if (pattern.hasMatch(combined3)) {
              firstValidPlate = combined3;
              break;
            }
          }
          if (firstValidPlate != null) break;
        }
      }
    }

    // Step 3: Use the first valid detected plate
    if (firstValidPlate != null) {
      numberPlates = [firstValidPlate];
      numberPlateController.text = firstValidPlate;
    } else {
      SnackbarUtil.showError(
        'Error',
        'Unable to scan vehicle number please enter manually or try again',
        seconds: 4,
      );
    }

    update();
    await textRecognizer.close();
  }

  String replaceZerosWithQ(String input) {
    if (input.length != 10) return input;

    List<String> chars = input.split('');
    final indicesToCheck = [0, 1, 4, 5];
    final indicesToCheck1 = [2, 3, 6, 7, 8, 9];

    for (int i in indicesToCheck) {
      if (chars[i] == '0') {
        chars[i] = 'Q';
      } else if (chars[i] == '1') {
        chars[i] = 'I';
      } else if (chars[i] == '2') {
        chars[i] = 'Z';
      } else if (chars[i] == '8') {
        chars[i] = 'B';
      }
    }
    for (int i in indicesToCheck1) {
      if (chars[i] == 'Z') {
        chars[i] = '4';
      } else if (chars[i] == 'O') {
        chars[i] = '0';
      }
    }

    return chars.join('');
  }

  Future<void> outEntry(String numberPlate) async {
    try {
      isLoading.value = true;

      final getData = await ApiService.post(
        ApiUrls.outEntry + numberPlate.trim(),
        {},
      );

      if (getData != null) {
        SnackbarUtil.showSuccess('Success', 'Vehicle OUT Successfully');

        await getEntries();
      }else{
        await getEntries();

      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addEntry() async {
    try {
      isLoading.value = true;

      final getData = await ApiService.post(
        "${ApiUrls.inEntry}${numberPlateController.text.trim()}&location=${locationController.text}&key=${selectedValue.value?.toLowerCase() ?? ''}",{});

      if (getData != null) {
        numberPlateController.clear();
        locationController.clear();
        imageFile?.value = File('');
       selectedValue=Rxn<String>();

        SnackbarUtil.showSuccess('Success', 'Vehicle IN Successfully');
        Navigator.pop(Get.context!);
        await getEntries();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getEntries() async {
    try {
      isLoading(true);
      final getData = await ApiService.get(ApiUrls.entries);
      if (getData != null) {
        entries.value = EntriesModel.fromJson(getData).data ?? [];
        searchEntriesList.clear();
        searchEntriesList.addAll(entries);

      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
    } finally {
      isLoading(false);
    }
  }

  //local search
  Future<void> searchEntries(String numberPlate) async {
    try {
      searchEntriesList = <EntryData>[].obs;

      isLoading.value = true;
      if (numberPlate.isNotEmpty) {
        for (var element in entries) {
          if (element.vehicleNumber?.contains(numberPlate.toUpperCase()) ??
              false) {
            searchEntriesList.add(element);
          }
        }
      } else {
        searchEntriesList.clear();
        searchEntriesList.addAll(entries);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportEntriesToExcel() async {
    var storagePermission = await Permission.storage.request();
    var manageStoragePermission =
        await Permission.manageExternalStorage.request();

    if (storagePermission.isGranted || manageStoragePermission.isGranted) {
      final workbook = sync.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = 'Vehicle Entries';

      // Set column widths
      sheet.setColumnWidthInPixels(1, 50); // ID
      sheet.setColumnWidthInPixels(2, 100); // Vehicle Number
      sheet.setColumnWidthInPixels(3, 150); // In Time
      sheet.setColumnWidthInPixels(4, 150); // Out Time
      sheet.setColumnWidthInPixels(5, 150); // location
      sheet.setColumnWidthInPixels(6, 50); // location

      // Add headers
      // Get header cells
      final cellStyle = workbook.styles.add('headerStyle');
      cellStyle.bold = true;

      // Set header text with bold style
      sheet.getRangeByName('A1').cellStyle = cellStyle;
      sheet.getRangeByName('A1').setText('ID');

      sheet.getRangeByName('B1').cellStyle = cellStyle;
      sheet.getRangeByName('B1').setText('Vehicle Number');

      sheet.getRangeByName('C1').cellStyle = cellStyle;
      sheet.getRangeByName('C1').setText('In Time');

      sheet.getRangeByName('D1').cellStyle = cellStyle;
      sheet.getRangeByName('D1').setText('Out Time');

      sheet.getRangeByName('E1').cellStyle = cellStyle;
      sheet.getRangeByName('E1').setText('Location');
      sheet.getRangeByName('F1').cellStyle = cellStyle;
      sheet.getRangeByName('F1').setText('Key');

      // Add data rows
      int rowIndex = 2;
      for (var entry in entries) {
        sheet.getRangeByName('A$rowIndex').setText(entry.id?.toString() ?? '');
        sheet.getRangeByName('B$rowIndex').setText(entry.vehicleNumber ?? '');
        sheet.getRangeByName('C$rowIndex').setText(DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(entry.inTime  ?? '')));
        sheet.getRangeByName('D$rowIndex').setText(entry.outTime == null ?  '' :DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(entry.outTime  ?? '')));
        sheet.getRangeByName('E$rowIndex').setText((entry.location== '0' || entry.location == null)  ?  '' : entry.location  );
        sheet.getRangeByName('F$rowIndex').setText(entry.key ?? '');

        rowIndex++;
      }

      // Save file
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final fileName =
          'Vehicle_Entries_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final directory = Directory('/storage/emulated/0/Download');
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      print('Excel saved to: ${file.path}');
      SnackbarUtil.showInfo('Saved', "Excel saved to ${file.path}");

      OpenFile.open(file.path);
    } else {
      print('Storage permission not granted.');
      openAppSettings();
    }
  }

  // Future<void> exportEntriesToExcel() async {
  //   // Request both permissions for Android 11+
  //   var storagePermission = await Permission.storage.request();
  //   var manageStoragePermission = await Permission.manageExternalStorage.request();
  //
  //   if (storagePermission.isGranted || manageStoragePermission.isGranted) {
  //     var excel = Excel.createExcel();
  //     var sheet = excel['Vehicle Entries1'];
  //
  //     // Add header row
  //     sheet.appendRow([
  //       TextCellValue('ID',),
  //       TextCellValue('Vehicle Number                '),
  //       TextCellValue('In Time                       '),
  //       TextCellValue('Out Time                      '),
  //       // TextCellValue('Created At'),
  //       // TextCellValue('Updated At'),
  //     ]);
  //
  //     // Add data rows
  //     for (var entry in entries) {
  //       sheet.appendRow([
  //         TextCellValue(entry.id?.toString() ?? '',),
  //         TextCellValue(entry.vehicleNumber ?? ''),
  //         TextCellValue(entry.inTime ?? ''),
  //         TextCellValue(entry.outTime ?? ''),
  //         // TextCellValue(entry.createdAt ?? ''),
  //         // TextCellValue(entry.updatedAt ?? ''),
  //       ]);
  //     }
  //
  //     // File name
  //     String fileName = 'Vehicle_Entries_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
  //
  //     // Save to Downloads (user-visible)
  //     Directory directory = Directory('/storage/emulated/0/Download');
  //     final file = File('${directory.path}/$fileName')
  //       ..createSync(recursive: true)
  //       ..writeAsBytesSync(excel.encode()!);
  //
  //     print("Excel exported to: ${file.path}");
  //     SnackbarUtil.showInfo('Saved',"Excel saved to ${file.path}");
  //     OpenFile.open(file.path);
  //   } else {
  //     print("Storage permission not granted.");
  //     openAppSettings(); // optional: open settings page
  //   }
  // }
}
