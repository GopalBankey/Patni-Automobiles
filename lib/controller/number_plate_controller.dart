import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberplatefinder/models/entries_model.dart';
import 'package:numberplatefinder/services.dart';
import 'package:numberplatefinder/utils/api_urls.dart';
import 'package:numberplatefinder/utils/snackbar_util.dart';

class NumberPlateController extends GetxController {
  FocusNode searchNode=FocusNode();
  var isLoading = false.obs;
  Rx<File>? imageFile = Rx<File>(File(''));
  List<String> numberPlates = [];
  var entries = <EntryData>[].obs;
  var searchEntriesList = <EntryData>[].obs;
  TextEditingController numberPlateController = TextEditingController();
  var currentTime = DateTime.now().obs;

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


  // Future<void> scanForNumberPlates(File imageFile) async {
  //   final inputImage = InputImage.fromFile(imageFile);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final recognizedText = await textRecognizer.processImage(inputImage);
  //
  //   List<String> allLines = [];
  //   Set<String> matchedPlates = {};
  //
  //   for (final block in recognizedText.blocks) {
  //     for (final line in block.lines) {
  //       String raw = line.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  //       String cleaned = raw
  //           .replaceAll('O', '0')
  //           .replaceAll('I', '1')
  //           .replaceAll('Z', '2')
  //           .replaceAll('B', '8')
  //           .replaceAll('D', '0'); // sometimes D is wrongly used for 0
  //
  //       allLines.add(cleaned);
  //
  //       for (final pattern in numberPlatePatterns) {
  //         if (pattern.hasMatch(cleaned)) {
  //           matchedPlates.add(cleaned);
  //         }
  //       }
  //     }
  //   }
  //
  //   // Combine 2 or 3 lines if needed
  //   for (int i = 0; i < allLines.length - 1; i++) {
  //     String combined2 = allLines[i] + allLines[i + 1];
  //     print('2-----$combined2');
  //
  //     for (final pattern in numberPlatePatterns) {
  //       if (pattern.hasMatch(combined2)) {
  //         matchedPlates.add(combined2);
  //         break;
  //       }
  //     }
  //
  //     if (i + 2 < allLines.length) {
  //       String combined3 = allLines[i] + allLines[i + 1] + allLines[i + 2];
  //       print('3-----$combined3');
  //
  //       for (final pattern in numberPlatePatterns) {
  //         if (pattern.hasMatch(combined3)) {
  //           matchedPlates.add(combined3);
  //           break;
  //         }
  //       }
  //     }
  //   }
  //
  //   // Prioritize 10-character results (like GJ03KQ6533)
  //   List<String> sortedPlates = matchedPlates.toList()
  //     ..sort((a, b) => (b.length == 10 ? 1 : 0) - (a.length == 10 ? 1 : 0));
  //
  //   numberPlates = sortedPlates;
  //
  //   if (numberPlates.isNotEmpty) {
  //     numberPlateController.text = numberPlates[0];
  //   } else {
  //     SnackbarUtil.showError(
  //       'Error',
  //       'Unable to scan vehicle number. Please try again or enter manually.',
  //       seconds: 4,
  //     );
  //   }
  //
  //   update();
  //   await textRecognizer.close();
  // }


  Future<void> scanForNumberPlates(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    List<String> detectedPlates = [];
    List<String> allLines = [];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        String rawText = line.text.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );

        // Correct common OCR errors
        String cleaned = rawText
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('Z', '2')
            .replaceAll('B', '8');

        allLines.add(cleaned);

        for (final pattern in numberPlatePatterns) {
          if (pattern.hasMatch(cleaned)) {
            detectedPlates.add(cleaned); // Display cleaned value
            break;
          }
        }
      }
    }

    // Try combining 2 and 3 lines
    if (detectedPlates.isEmpty && allLines.length > 1) {
      for (int i = 0; i < allLines.length - 1; i++) {
        String combined2 = allLines[i] + allLines[i + 1];
        print('2-----'+combined2);

        for (final pattern in numberPlatePatterns) {
          if (pattern.hasMatch(combined2)) {
            detectedPlates.add(combined2);
            break;
          }
        }

        if (i + 2 < allLines.length) {
          String combined3 = allLines[i] + allLines[i + 1] + allLines[i + 2];
          print('3-----'+combined3);
          for (final pattern in numberPlatePatterns) {
            if (pattern.hasMatch(combined3)) {
              detectedPlates.add(combined3);
              break;
            }
          }
        }
      }
    }

    numberPlates = detectedPlates;
    if (numberPlates.isNotEmpty){
      numberPlateController.text = numberPlates[0];
    }else{
      SnackbarUtil.showError('Error', 'Unable to scan vehicle number please enter manually or try again',seconds: 4);

    }

    update();
    await textRecognizer.close();
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
        ApiUrls.inEntry + numberPlateController.text.trim(),
        {},
      );

      if (getData != null) {
        numberPlateController.clear();
        imageFile?.value = File('');
        SnackbarUtil.showSuccess('Success', 'Vehicle IN Successfully');
        Navigator.pop(Get.context!);
      await  getEntries();
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
      if(numberPlate.isNotEmpty)
        {
          for (var element in entries) {
            if(element.vehicleNumber?.contains(numberPlate.toUpperCase()) ?? false)
            {
              searchEntriesList.add(element);
            }
          }
        }else{
        searchEntriesList.clear();
        searchEntriesList.addAll(entries);      }


    }catch(e)
    {
      if (kDebugMode) {
        print("Exception: $e");
      }
    }
    finally{
      isLoading.value = false;
    }

  }
}
