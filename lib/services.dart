import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:numberplatefinder/utils/snackbar_util.dart';

class ApiService {
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    // Add 'Authorization': 'Bearer YOUR_TOKEN' if needed
  };

  // 🔹 GET Method
  static Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      // request.headers.addAll(headers ?? defaultHeaders);

      final response = await request.send();

      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        SnackbarUtil.showError('Error', 'Something went wrong');
        print("GET Error: ${response.statusCode} - ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("GET Exception: $e");
      return null;
    }
  }

  // 🔹 POST Method
  static Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('POST', uri);
      // request.headers.addAll(headers ?? defaultHeaders);
      request.body = jsonEncode(body);

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        final data = await response.stream.bytesToString();
        final jsonResponse = json.decode(data);

        if (kDebugMode) {
          print(data);
        }
        SnackbarUtil.showError('Error', jsonResponse['message']);

        if (kDebugMode) {
          print(
            "POST Error: ${response.statusCode} - ${response.reasonPhrase}",
          );
        }
        return null;
      }
    } catch (e) {
      print("POST Exception: $e");
      return null;
    }
  }

  // 🔹 PUT Method
  static Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('PUT', uri);
      // request.headers.addAll(headers ?? defaultHeaders);
      request.body = jsonEncode(body);

      final response = await request.send();

      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        print("PUT Error: ${response.statusCode} - ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("PUT Exception: $e");
      return null;
    }
  }

  // 🔹 DELETE Method
  static Future<dynamic> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('DELETE', uri);
      // request.headers.addAll(headers ?? defaultHeaders);

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        print(
          "DELETE Error: ${response.statusCode} - ${response.reasonPhrase}",
        );
        return null;
      }
    } catch (e) {
      print("DELETE Exception: $e");
      return null;
    }
  }
}
