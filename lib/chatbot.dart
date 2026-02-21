import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'ayu_theme.dart';

class ChatbotScreen extends StatefulWidget {
  final String initialTopic;
  const ChatbotScreen({super.key, this.initialTopic = "Skin Diseases"});

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
    bool isSkin = widget.initialTopic == "Skin Diseases";

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.initialTopic} Assistant"),
        backgroundColor: AyuTheme.primaryTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              Text(
                isSkin 
                  ? "Upload a clear image of the affected skin area for AI analysis."
                  : "Welcome to the ${widget.initialTopic} LLM Assistant. Describe your symptoms or query below.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AyuTheme.textGray),
              ),

              const SizedBox(height: 24),

              if (isSkin) ...[
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
              ] else ...[
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter details here...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Connecting to ${widget.initialTopic} LLM...")),
                    );
                  },
                  child: const Text("Run AI Assessment"),
                ),
              ],

              const SizedBox(height: 20),

              if (isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Analyzing...")
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
                        const Text("Diagnostic Insight:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(result!["disease"] ?? "Analysis complete"),

                        const SizedBox(height: 8),

                        const Text("Risk Level:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(result!["risk_level"] ?? "Low"),

                        const SizedBox(height: 12),

                        const Text("Advice:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(result!["advice"] ?? "Please consult a professional."),
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
