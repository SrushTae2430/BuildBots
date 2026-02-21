import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost/127.0.0.1 for Windows
  static const String baseUrl = "http://10.0.2.2:8000";

  // --- NEW: Profile & History ---
  static Future<Map<String, dynamic>> getProfile({String? email}) async {
    try {
      final url = email != null ? "$baseUrl/profile?email=$email" : "$baseUrl/profile";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  static Future<List<dynamic>> getHistory(String email) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/history?email=$email"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addVitals(String email, double risk, String stability) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add-vitals?email=$email&risk=$risk&stability=$stability"),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> login(Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- EXISTING: AI Assistants ---
  static Future<Map<String, dynamic>> predictHeart(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict/heart"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Heart prediction failed: ${response.body}");
  }

  static Future<Map<String, dynamic>> predictDiabetes(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict/diabetes"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Diabetes prediction failed: ${response.body}");
  }

  static Future<Map<String, dynamic>> predictKidney(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict/kidney"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Kidney prediction failed: ${response.body}");
  }

  static Future<Map<String, dynamic>> analyzeImage(File image) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/analyze-skin"));
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) return jsonDecode(responseData);
    throw Exception("Image upload failed");
  }
}