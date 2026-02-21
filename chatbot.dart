import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  File? selectedImage;
  Map<String, dynamic>? result;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        result = null;
      });

      analyzeImage();
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage == null) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.analyzeImage(selectedImage!);

      setState(() {
        result = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server connection failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skin Health Assistant"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Upload a clear image of the affected skin area.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Select Skin Image"),
              ),

              const SizedBox(height: 20),

              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(selectedImage!, height: 200),
                ),

              const SizedBox(height: 20),

              if (isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Analyzing image...")
                  ],
                ),

              if (result != null && !isLoading)
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Possible Condition:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(result!["disease"] ?? "Unknown"),

                        const SizedBox(height: 8),

                        const Text("Risk Level:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(result!["risk_level"] ?? "-"),

                        const SizedBox(height: 8),

                        const Text("Confidence:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "${((result!["confidence"] ?? 0) * 100).toStringAsFixed(1)}%",
                        ),

                        const SizedBox(height: 12),

                        const Text("Advice:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(result!["advice"] ?? "-"),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
