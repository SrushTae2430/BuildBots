import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const KidneyHealthAI());
}

class KidneyHealthAI extends StatelessWidget {
  const KidneyHealthAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, primary: Colors.teal),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _ageController = TextEditingController();
  final _creatinineController = TextEditingController();
  String _hasDiabetes = "no";
  String _hasHypertension = "no";
  bool _isScanning = false;

  // --- SMART OCR LOGIC ---
  Future<void> _scanReport() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() => _isScanning = true);
    final textRecognizer = TextRecognizer();
    
    try {
      final recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(image.path));
      
      // Regex: Looks for variations of "Creatinine" followed by a number
      // Captures values like "S.Creatinine: 1.2" or "Creatinine....0.9"
      RegExp regExp = RegExp(r'(creatinine|cr|s\.cr)[:\s\t\.]+(\d+\.?\d*)', caseSensitive: false);
      
      bool found = false;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final match = regExp.firstMatch(line.text.toLowerCase());
          if (match != null) {
            setState(() => _creatinineController.text = match.group(2)!);
            found = true;
            break;
          }
        }
        if (found) break;
      }
      
      if (!found) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not find Creatinine value. Please enter manually."))
        );
      }
    } finally {
      setState(() => _isScanning = false);
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text("KIDNEY AI", style: GoogleFonts.bebasNeue(letterSpacing: 2, fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Clinical Report Scan"),
            _buildOCRCard(),
            const SizedBox(height: 25),
            _buildSectionHeader("Patient Details"),
            _buildModernField("Age", _ageController, Icons.calendar_today),
            _buildModernDropdown("Diabetes History", _hasDiabetes, (v) => setState(() => _hasDiabetes = v!)),
            _buildModernDropdown("Hypertension History", _hasHypertension, (v) => setState(() => _hasHypertension = v!)),
            const SizedBox(height: 40),
            _buildCalculateButton(),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildOCRCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Serum Creatinine (mg/dL)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                TextField(
                  controller: _creatinineController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "0.0"),
                ),
              ],
            ),
          ),
          _isScanning 
            ? const CircularProgressIndicator()
            : IconButton.filled(
                onPressed: _scanReport, 
                icon: const Icon(Icons.document_scanner_rounded),
                style: IconButton.styleFrom(minimumSize: const Size(60, 60)),
              ),
        ],
      ),
    );
  }

  Widget _buildModernField(String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(icon: Icon(icon, size: 20), labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _buildModernDropdown(String label, String value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonFormField<String>(
        value: value,
        items: ["yes", "no"].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ResultSheet(
            age: _ageController.text,
            sc: _creatinineController.text,
            dm: _hasDiabetes,
            htn: _hasHypertension,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8, shadowColor: Colors.teal.withOpacity(0.4),
      ),
      child: const Text("ANALYZE HEALTH DATA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}

class ResultSheet extends StatelessWidget {
  final String age, sc, dm, htn;
  const ResultSheet({super.key, required this.age, required this.sc, required this.dm, required this.htn});

  Future<double> _getRiskScore() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.29.140:8080/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": double.tryParse(age) ?? 40.0,
          "sc": double.tryParse(sc) ?? 1.0,
          "htn": htn == "yes" ? 1 : 0,
          "dm": dm == "yes" ? 1 : 0
        }),
      ).timeout(const Duration(seconds: 8));
      return (jsonDecode(response.body)['risk_score']).toDouble();
    } catch (e) { return 0.0; }
  }

  Future<String> _getAIAdvice(double score) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.29.140:11434/api/generate"),
        body: jsonEncode({
          "model": "tinyllama",
          "prompt": "Kidney Risk is $score%. Age $age. Give 2 short health tips. Be professional.",
          "stream": false,
        }),
      ).timeout(const Duration(seconds: 25));
      return jsonDecode(response.body)['response'].toString().trim();
    } catch (e) {
      return score > 50 ? "⚠️ High risk detected. Consult a doctor." : "✅ Risk is low. Stay hydrated.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      padding: const EdgeInsets.all(32),
      height: MediaQuery.of(context).size.height * 0.75,
      child: FutureBuilder<double>(
        future: _getRiskScore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final score = snapshot.data ?? 0.0;
          return Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 30),
              Text("${score.toStringAsFixed(1)}%", 
                style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: score > 50 ? Colors.redAccent : Colors.teal)),
              const Text("AI PREDICTED RISK", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
              const Divider(height: 60),
              Expanded(
                child: FutureBuilder<String>(
                  future: _getAIAdvice(score),
                  builder: (context, aiSnap) {
                    if (aiSnap.connectionState == ConnectionState.waiting) return const Center(child: Text("AI Specialist is typing..."));
                    return SingleChildScrollView(
                      child: Text(aiSnap.data ?? "", 
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, height: 1.6, fontWeight: FontWeight.w500)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}