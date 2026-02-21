import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ocr_config.dart';

class OcrService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from [source] and run text recognition. Returns recognized text or null.
  static Future<String?> pickAndRecognizeText({ImageSource source = ImageSource.camera}) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 90);
    if (file == null) return null;
    final processed = await _preprocessImage(file.path);

    final inputImage = InputImage.fromFilePath(processed);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognised = await recognizer.processImage(inputImage);
      return recognised.text;
    } catch (e) {
      debugPrint('OCR error: $e');
      return null;
    } finally {
      recognizer.close();
    }
  }

  /// High-end pick & recognize: if `googleCloudVisionApiKey` is set, use Cloud
  /// Vision (DOCUMENT_TEXT_DETECTION), otherwise fallback to local ML Kit.
  static Future<String?> pickAndRecognizeHighEnd({ImageSource source = ImageSource.camera}) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 90);
    if (file == null) return null;

    final processed = await _preprocessImage(file.path);

    if (googleCloudVisionApiKey.isNotEmpty) {
      final cloud = await _recognizeWithCloudVision(processed, googleCloudVisionApiKey);
      if (cloud != null && cloud.isNotEmpty) return cloud;
      // fallthrough to mlkit if cloud returns nothing
    }

    return await pickAndRecognizeText(source: source);
  }

  static Future<String?> _recognizeWithCloudVision(String filePath, String apiKey) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final base64Img = base64Encode(bytes);
      final url = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');
      final body = jsonEncode({
        'requests': [
          {
            'image': {'content': base64Img},
            'features': [
              {'type': 'DOCUMENT_TEXT_DETECTION', 'maxResults': 1}
            ]
          }
        ]
      });

      final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) {
        debugPrint('Cloud Vision error ${resp.statusCode}: ${resp.body}');
        return null;
      }

      final j = jsonDecode(resp.body);
      final text = j['responses']?[0]?['fullTextAnnotation']?['text'] as String?;
      return text;
    } catch (e) {
      debugPrint('Cloud OCR error: $e');
      return null;
    }
  }

  /// Preprocess image: decode, resize if large, convert to grayscale and
  /// apply contrast stretching. Returns path to processed PNG file.
  static Future<String> _preprocessImage(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return filePath;

      // Resize to a reasonable max width for ML Kit (keep aspect)
      const maxDim = 1600;
      if (max(image.width, image.height) > maxDim) {
        image = img.copyResize(image, width: (image.width >= image.height) ? maxDim : null, height: (image.height > image.width) ? maxDim : null);
      }

      // Convert to grayscale to simplify recognition
      image = img.grayscale(image);

      // (Optional) Could perform contrast stretching or adaptive thresholding here.
      // Keep the grayscale + resize preprocessing for now to improve OCR robustness.

      // Encode to PNG and save next to original with _proc suffix
      final outBytes = img.encodePng(image);
      final outPath = '${filePath}_proc.png';
      await File(outPath).writeAsBytes(outBytes, flush: true);
      return outPath;
    } catch (e) {
      debugPrint('Preprocess error: $e');
      return filePath;
    }
  }

  /// Best-effort parse: find numeric values near keywords.
  /// `keys` is a map of target field -> list of keyword synonyms to search for.
  static Map<String, dynamic> parseFields(String text, Map<String, List<String>> keys) {
    final Map<String, dynamic> out = {};
    final lowered = text.toLowerCase();
    // split into lines for better context mapping
    final lines = lowered.split(RegExp(r'\r?\n'));

    // Build list of (lineIndex, number, startIndex, endIndex)
    final numRegex = RegExp(r'([0-9]+(?:\.[0-9]+)?)');
    final List<Map<String, dynamic>> numbers = [];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final m in numRegex.allMatches(line)) {
        numbers.add({'line': i, 'value': double.tryParse(m.group(1)!), 'start': m.start, 'end': m.end, 'text': line});
      }
    }

    for (final entry in keys.entries) {
      final field = entry.key;
      final synonyms = entry.value.map((s) => s.toLowerCase()).toList();

      // Attempt: find a number in a line that mentions a synonym
      double? best;
      for (final num in numbers) {
        final line = num['text'] as String;
        final foundSyn = synonyms.firstWhere((syn) => line.contains(syn), orElse: () => '');
        if (foundSyn.isNotEmpty) {
          best = num['value'] as double?;
          break;
        }
      }

      // If not found, try searching entire text for patterns like "keyword: 120" or "120 mg/dl"
      if (best == null) {
        for (final syn in synonyms) {
          final pattern = RegExp(r"""${RegExp.escape(syn)}[\s:\-]*([0-9]+(?:\.[0-9]+)?)""", caseSensitive: false);
          final m = pattern.firstMatch(lowered);
          if (m != null) {
            best = double.tryParse(m.group(1)!);
            break;
          }
        }
      }

      // If still not found, fallback: if there's any lone number with units matching common units near it
      if (best == null) {
        final unitHints = ['mg/dl', 'mmhg', 'bpm', 'g/dl', 'kg/m2', 'kg/m^2'];
        for (final num in numbers) {
          final line = num['text'] as String;
          if (unitHints.any((u) => line.contains(u))) {
            best = num['value'] as double?;
            break;
          }
        }
      }

      if (best != null) out[field] = best;
    }

    return out;
  }
}
