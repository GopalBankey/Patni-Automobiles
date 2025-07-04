import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:numberplatefinder/views/splah_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Number Plate Scanner',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}




// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await Firebase.initializeApp(
//   //   options: DefaultFirebaseOptions.currentPlatform,
//   // );
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Chat App',
//       debugShowCheckedModeBanner: false,
//       // theme: AppThemes.lightTheme,
//       // darkTheme: AppThemes.darkTheme,
//       // themeMode: Get.isDarkMode? ThemeMode.light:ThemeMode.dark,
//       home: NumberPlateScanner(),
//     );
//   }
// }
//
// // OCR SCREEN
//
// class NumberPlateScanner extends StatefulWidget {
//   const NumberPlateScanner({super.key});
//
//   @override
//   _NumberPlateScannerState createState() => _NumberPlateScannerState();
// }
//
// class _NumberPlateScannerState extends State<NumberPlateScanner> {
//   File? _imageFile;
//   List<String> _numberPlates = [];
//
//   // final RegExp numberPlateRegex = RegExp(
//   //   r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{3,4}$',
//   //   caseSensitive: false,
//   // );
//
//   // final RegExp numberPlateRegex = RegExp(
//   //   r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$',
//   //   caseSensitive: false,
//   // );
//
//   final List<RegExp> numberPlatePatterns = [
//     // Standard private/commercial: MH12AB1234
//     RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{3,4}$'),
//
//     // With spaces: MH 12 AB 1234
//     RegExp(r'^[A-Z]{2}\s?[0-9]{1,2}\s?[A-Z]{1,2}\s?[0-9]{3,4}$'),
//
//     // Old format: WB-04-A-1234
//     RegExp(r'^[A-Z]{2}-[0-9]{1,2}-[A-Z]{1,2}-[0-9]{3,4}$'),
//
//     // Temporary: TEMP1234, TR123456
//     RegExp(r'^(TEMP|TR)[0-9]{3,6}$'),
//
//     // Government: DL1G1234
//     RegExp(r'^[A-Z]{2}[0-9]{1,2}G[0-9]{3,4}$'),
//
//     // Diplomatic: 22CD1234
//     RegExp(r'^22CD[0-9]{4}$'),
//
//     // Military: 123456B
//     RegExp(r'^[0-9]{5,6}[A-Z]$'),
//   ];
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera);
//
//     if (picked != null) {
//       final image = File(picked.path);
//       setState(
//         () {
//           _imageFile = image;
//           _numberPlates.clear();
//         },
//       );
//
//       await _scanForNumberPlates(image);
//     }
//   }
//
//   Future<void> _scanForNumberPlates(File imageFile) async {
//     final inputImage = InputImage.fromFile(imageFile);
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     final RecognizedText recognizedText =
//         await textRecognizer.processImage(inputImage);
//
//     List<String> detectedPlates = [];
//
//     // for (TextBlock block in recognizedText.blocks) {
//     //   for (TextLine line in block.lines) {
//     //     // Remove non-alphanumeric and spaces
//     //     String cleanedLine =
//     //         line.text.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
//     //     if (numberPlateRegex.hasMatch(cleanedLine)) {
//     //       detectedPlates.add(cleanedLine);
//     //     }
//     //   }
//     // }
//
//     for (TextBlock block in recognizedText.blocks) {
//       for (TextLine line in block.lines) {
//         String raw = line.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
//
//         for (RegExp pattern in numberPlatePatterns) {
//           if (pattern.hasMatch(raw)) {
//             detectedPlates.add(line.text); // Add original for display
//             break; // stop checking once one pattern matches
//           }
//         }
//       }
//     }
//
//     setState(() {
//       _numberPlates = detectedPlates;
//     });
//
//     await textRecognizer.close();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlueAccent,
//       appBar: AppBar(
//         title: Text('Number Plate Scanner'),
//         backgroundColor: Colors.blueGrey,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//
//               ElevatedButton(
//
//                 onPressed: _pickImage,
//                 child: Text('Pick Image'),
//               ),
//               SizedBox(height: 20,width: MediaQuery.sizeOf(context).width,),
//               // _imageFile != null ? Image.file(_imageFile!) : Container(),
//               SizedBox(height: 20),
//               Text("Detected Number Plates:",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               ..._numberPlates.isNotEmpty
//                   ? _numberPlates.map((plate) => Text(plate,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold))).toList()
//                   : [
//                       Text("No valid number plate found",style: TextStyle(fontSize: 20),),
//                     ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }