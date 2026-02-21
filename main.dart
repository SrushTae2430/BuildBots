import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────
// MULTILINGUAL SUPPORT
// ─────────────────────────────────────────────

enum AppLanguage { english, hindi, tamil, telugu }

class AppLocalizations {
  final AppLanguage language;
  const AppLocalizations(this.language);

  String get appTitle => {
    AppLanguage.english: 'KIDNEY AI',
    AppLanguage.hindi:   'किडनी AI',
    AppLanguage.tamil:   'சிறுநீரக AI',
    AppLanguage.telugu:  'కిడ్నీ AI',
  }[language]!;

  String get scanReport => {
    AppLanguage.english: 'Clinical Report Scan',
    AppLanguage.hindi:   'नैदानिक रिपोर्ट स्कैन',
    AppLanguage.tamil:   'மருத்துவ அறிக்கை ஸ்கேன்',
    AppLanguage.telugu:  'క్లినికల్ రిపోర్ట్ స్కాన్',
  }[language]!;

  String get patientDetails => {
    AppLanguage.english: 'Patient Details',
    AppLanguage.hindi:   'रोगी विवरण',
    AppLanguage.tamil:   'நோயாளி விவரங்கள்',
    AppLanguage.telugu:  'రోగి వివరాలు',
  }[language]!;

  String get age => {
    AppLanguage.english: 'Age',
    AppLanguage.hindi:   'आयु',
    AppLanguage.tamil:   'வயது',
    AppLanguage.telugu:  'వయస్సు',
  }[language]!;

  String get diabetes => {
    AppLanguage.english: 'Diabetes History',
    AppLanguage.hindi:   'मधुमेह इतिहास',
    AppLanguage.tamil:   'நீரிழிவு வரலாறு',
    AppLanguage.telugu:  'మధుమేహ చరిత్ర',
  }[language]!;

  String get hypertension => {
    AppLanguage.english: 'Hypertension History',
    AppLanguage.hindi:   'उच्च रक्तचाप इतिहास',
    AppLanguage.tamil:   'உயர் இரத்த அழுத்த வரலாறு',
    AppLanguage.telugu:  'అధిక రక్తపోటు చరిత్ర',
  }[language]!;

  String get analyzeBtn => {
    AppLanguage.english: 'ANALYZE HEALTH DATA',
    AppLanguage.hindi:   'स्वास्थ्य डेटा विश्लेषण करें',
    AppLanguage.tamil:   'உடல்நலத் தரவை பகுப்பாய்வு',
    AppLanguage.telugu:  'ఆరోగ్య డేటా విశ్లేషించు',
  }[language]!;

  String get creatinineLabel => {
    AppLanguage.english: 'Serum Creatinine (mg/dL)',
    AppLanguage.hindi:   'सीरम क्रिएटिनिन (mg/dL)',
    AppLanguage.tamil:   'சீரம் கிரியேட்டினின் (mg/dL)',
    AppLanguage.telugu:  'సీరమ్ క్రియేటినిన్ (mg/dL)',
  }[language]!;

  String get ocrFailed => {
    AppLanguage.english: 'Could not find Creatinine value. Please enter manually.',
    AppLanguage.hindi:   'क्रिएटिनिन मूल्य नहीं मिला। कृपया मैन्युअल दर्ज करें।',
    AppLanguage.tamil:   'கிரியேட்டினின் மதிப்பு கிடைக்கவில்லை. கைமுறையாக உள்ளிடுக.',
    AppLanguage.telugu:  'క్రియేటినిన్ విలువ కనుగొనబడలేదు. దయచేసి మాన్యువల్‌గా నమోదు చేయండి.',
  }[language]!;

  String get aiRisk => {
    AppLanguage.english: 'AI PREDICTED RISK',
    AppLanguage.hindi:   'AI अनुमानित जोखिम',
    AppLanguage.tamil:   'AI கணிக்கப்பட்ட ஆபத்து',
    AppLanguage.telugu:  'AI అంచనా వేసిన ప్రమాదం',
  }[language]!;

  String get aiTyping => {
    AppLanguage.english: 'AI Specialist is typing...',
    AppLanguage.hindi:   'AI विशेषज्ञ टाइप कर रहा है...',
    AppLanguage.tamil:   'AI நிபுணர் தட்டச்சு செய்கிறார்...',
    AppLanguage.telugu:  'AI నిపుణుడు టైప్ చేస్తున్నారు...',
  }[language]!;

  String get langName => {
    AppLanguage.english: 'English',
    AppLanguage.hindi:   'हिंदी',
    AppLanguage.tamil:   'தமிழ்',
    AppLanguage.telugu:  'తెలుగు',
  }[language]!;

  String get aiPromptLang => {
    AppLanguage.english: 'English',
    AppLanguage.hindi:   'Hindi',
    AppLanguage.tamil:   'Tamil',
    AppLanguage.telugu:  'Telugu',
  }[language]!;

  // ── Lifestyle section ──────────────────────────────────────────────────────
  String get lifestyleSection => {
    AppLanguage.english: 'Lifestyle Factors',
    AppLanguage.hindi:   'जीवनशैली कारक',
    AppLanguage.tamil:   'வாழ்க்கை முறை காரணிகள்',
    AppLanguage.telugu:  'జీవనశైలి కారకాలు',
  }[language]!;

  String get smoking => {
    AppLanguage.english: 'Do you smoke?',
    AppLanguage.hindi:   'क्या आप धूम्रपान करते हैं?',
    AppLanguage.tamil:   'நீங்கள் புகைபிடிக்கிறீர்களா?',
    AppLanguage.telugu:  'మీరు ధూమపానం చేస్తారా?',
  }[language]!;

  String get alcohol => {
    AppLanguage.english: 'Alcohol consumption?',
    AppLanguage.hindi:   'शराब का सेवन?',
    AppLanguage.tamil:   'மது அருந்துகிறீர்களா?',
    AppLanguage.telugu:  'మద్యపానం చేస్తారా?',
  }[language]!;

  String get waterIntake => {
    AppLanguage.english: 'Daily water intake',
    AppLanguage.hindi:   'दैनिक पानी का सेवन',
    AppLanguage.tamil:   'தினசரி நீர் உட்கொள்ளல்',
    AppLanguage.telugu:  'రోజువారీ నీటి తీసుకోవడం',
  }[language]!;

  String get exercise => {
    AppLanguage.english: 'Physical activity level',
    AppLanguage.hindi:   'शारीरिक गतिविधि स्तर',
    AppLanguage.tamil:   'உடல் செயல்பாட்டு நிலை',
    AppLanguage.telugu:  'శారీరక చర్య స్థాయి',
  }[language]!;

  String get diet => {
    AppLanguage.english: 'Diet type',
    AppLanguage.hindi:   'आहार प्रकार',
    AppLanguage.tamil:   'உணவு வகை',
    AppLanguage.telugu:  'ఆహార రకం',
  }[language]!;

  String get sleep => {
    AppLanguage.english: 'Sleep duration',
    AppLanguage.hindi:   'नींद की अवधि',
    AppLanguage.tamil:   'தூக்க காலம்',
    AppLanguage.telugu:  'నిద్ర వ్యవధి',
  }[language]!;

  String get painkillers => {
    AppLanguage.english: 'Frequent painkiller use?',
    AppLanguage.hindi:   'बार-बार दर्दनिवारक का उपयोग?',
    AppLanguage.tamil:   'அடிக்கடி வலி நிவாரணி பயன்படுத்துகிறீர்களா?',
    AppLanguage.telugu:  'తరచుగా నొప్పి నివారణ మందులు వాడతారా?',
  }[language]!;

  String get familyHistory => {
    AppLanguage.english: 'Family history of kidney disease?',
    AppLanguage.hindi:   'गुर्दे की बीमारी का पारिवारिक इतिहास?',
    AppLanguage.tamil:   'சிறுநீரக நோயின் குடும்ப வரலாறு?',
    AppLanguage.telugu:  'కిడ్నీ వ్యాధి కుటుంబ చరిత్ర ఉందా?',
  }[language]!;

  List<String> get waterOptions => {
    AppLanguage.english: ['< 1 litre', '1–2 litres', '2–3 litres', '> 3 litres'],
    AppLanguage.hindi:   ['< 1 लीटर', '1–2 लीटर', '2–3 लीटर', '> 3 लीटर'],
    AppLanguage.tamil:   ['< 1 லிட்டர்', '1–2 லிட்டர்', '2–3 லிட்டர்', '> 3 லிட்டர்'],
    AppLanguage.telugu:  ['< 1 లీటర్', '1–2 లీటర్లు', '2–3 లీటర్లు', '> 3 లీటర్లు'],
  }[language]!;

  List<String> get exerciseOptions => {
    AppLanguage.english: ['Sedentary', 'Light', 'Moderate', 'Active'],
    AppLanguage.hindi:   ['निष्क्रिय', 'हल्का', 'मध्यम', 'सक्रिय'],
    AppLanguage.tamil:   ['செயலற்ற', 'இலகு', 'மிதமான', 'சுறுசுறுப்பான'],
    AppLanguage.telugu:  ['నిద్రాణం', 'తేలికపాటి', 'మధ్యస్థం', 'చురుకైన'],
  }[language]!;

  List<String> get dietOptions => {
    AppLanguage.english: ['Vegetarian', 'Non-Veg', 'Vegan', 'High-Salt'],
    AppLanguage.hindi:   ['शाकाहारी', 'मांसाहारी', 'वीगन', 'अधिक नमक'],
    AppLanguage.tamil:   ['சைவம்', 'அசைவம்', 'வீகன்', 'அதிக உப்பு'],
    AppLanguage.telugu:  ['శాకాహారి', 'మాంసాహారి', 'వీగన్', 'అధిక ఉప్పు'],
  }[language]!;

  List<String> get sleepOptions => {
    AppLanguage.english: ['< 5 hrs', '5–6 hrs', '7–8 hrs', '> 8 hrs'],
    AppLanguage.hindi:   ['< 5 घंटे', '5–6 घंटे', '7–8 घंटे', '> 8 घंटे'],
    AppLanguage.tamil:   ['< 5 மணி', '5–6 மணி', '7–8 மணி', '> 8 மணி'],
    AppLanguage.telugu:  ['< 5 గంటలు', '5–6 గంటలు', '7–8 గంటలు', '> 8 గంటలు'],
  }[language]!;
}

// ─────────────────────────────────────────────
// HIGH-END OCR UTILITIES
// ─────────────────────────────────────────────

class OCREnhancer {
  /// Pre-processes image for maximum OCR accuracy:
  /// 1. Upscales small images to minimum 1500px wide
  /// 2. Converts to greyscale
  /// 3. Applies contrast & brightness normalization
  /// 4. Sharpens edges with a convolution kernel
  static Future<String> enhancedImagePath(String originalPath) async {
    final raw = await File(originalPath).readAsBytes();
    img.Image? image = img.decodeImage(raw);
    if (image == null) return originalPath;

    // Step 1: Upscale if too small for reliable OCR
    if (image.width < 1500) {
      image = img.copyResize(image, width: 1500);
    }

    // Step 2: Greyscale
    image = img.grayscale(image);

    // Step 3: Auto-contrast normalization
    image = img.adjustColor(image, contrast: 1.4, brightness: 1.05);

    // Step 4: Sharpen for crisp text edges
    image = img.convolution(image, filter: [
      0, -1,  0,
     -1,  5, -1,
      0, -1,  0
    ], div: 1);

    final dir = await getTemporaryDirectory();
    final enhancedPath = '${dir.path}/enhanced_ocr.jpg';
    await File(enhancedPath).writeAsBytes(img.encodeJpg(image, quality: 95));
    return enhancedPath;
  }

  /// Multi-strategy creatinine extraction:
  ///
  /// S1 – English label regex      ("Creatinine: 1.2", "S.Cr 0.9")
  /// S2 – Hindi label regex        ("क्रिएटिनिन 1.4")
  /// S3 – Tamil label regex        ("கிரியேட்டினின்: 0.9")
  /// S4 – Telugu label regex       ("క్రియేటినిన్ 1.1")
  /// S5 – Proximity search         (decimal nearest creatinine keyword)
  /// S6 – mg/dL heuristic          (decimal in physiological range on a mg/dL line)
  static String? extractCreatinine(String fullText) {
    final strategies = <RegExp>[
      RegExp(
        r'(?:serum\s+)?(?:creatinine|creat|cr|s\.cr|s\.creat)[:\s\t\.–\-]+(\d+\.?\d*)',
        caseSensitive: false,
      ),
      RegExp(r'(?:क्रिएटिनिन|सीरम\s+क्रेटिनिन)[:\s\t\.]+(\d+\.?\d*)'),
      RegExp(r'(?:கிரியேட்டினின்|சீரம்\s+கிரியேட்டினின்)[:\s\t\.]+(\d+\.?\d*)'),
      RegExp(r'(?:క్రియేటినిన్|సీరమ్\s+క్రియేటినిన్)[:\s\t\.]+(\d+\.?\d*)'),
    ];

    final lines = fullText.split('\n');

    // Strategies 1–4: exact label match
    for (final pattern in strategies) {
      for (final line in lines) {
        final m = pattern.firstMatch(line);
        if (m != null) {
          final val = double.tryParse(m.group(1)!);
          if (val != null && val >= 0.4 && val <= 15.0) return m.group(1);
        }
      }
    }

    final decimalRe = RegExp(r'(\d+\.\d+)');

    // Strategy 5: proximity — decimal near a creatinine keyword in same line
    final proximityRe = RegExp(
      r'(cr|creat|creatinine|क्रिएटिनिन|கிரியேட்டினின்|క్రియేటినిన్)',
      caseSensitive: false,
    );
    for (final line in lines) {
      if (proximityRe.hasMatch(line)) {
        for (final m in decimalRe.allMatches(line)) {
          final val = double.tryParse(m.group(1)!);
          if (val != null && val >= 0.4 && val <= 15.0) return m.group(1);
        }
      }
    }

    // Strategy 6: mg/dL heuristic
    final mgdlRe = RegExp(r'(mg|dl|mg/dl)', caseSensitive: false);
    for (final line in lines) {
      if (mgdlRe.hasMatch(line)) {
        for (final m in decimalRe.allMatches(line)) {
          final val = double.tryParse(m.group(1)!);
          if (val != null && val >= 0.4 && val <= 15.0) return m.group(1);
        }
      }
    }

    return null;
  }
}

// ─────────────────────────────────────────────
// APP ENTRY
// ─────────────────────────────────────────────

void main() => runApp(const KidneyHealthAI());

class KidneyHealthAI extends StatefulWidget {
  const KidneyHealthAI({super.key});

  @override
  State<KidneyHealthAI> createState() => _KidneyHealthAIState();
}

class _KidneyHealthAIState extends State<KidneyHealthAI> {
  AppLanguage _language = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: MainScreen(
        locale: AppLocalizations(_language),
        currentLanguage: _language,
        onLanguageChange: (lang) => setState(() => _language = lang),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  final AppLocalizations locale;
  final AppLanguage currentLanguage;
  final void Function(AppLanguage) onLanguageChange;

  const MainScreen({
    super.key,
    required this.locale,
    required this.currentLanguage,
    required this.onLanguageChange,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _ageController = TextEditingController();
  final _creatinineController = TextEditingController();
  String _hasDiabetes = 'no';
  String _hasHypertension = 'no';
  bool _isScanning = false;
  String? _ocrPreview;

  // ── Lifestyle state ────────────────────────────────────────────────────────
  String _smokes        = 'no';
  String _drinksAlcohol = 'no';
  String _waterIntake   = '1–2 litres';
  String _exercise      = 'Sedentary';
  String _diet          = 'Vegetarian';
  String _sleep         = '7–8 hrs';
  String _painkillers   = 'no';
  String _familyHistory = 'no';

  // ── HIGH-END OCR FLOW ──────────────────────────────────────────────────────
  Future<void> _scanReport() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return;

    setState(() => _isScanning = true);

    // Instantiate recognizers so they can be closed in finally
    final latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final devanagiriRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);

    try {
      // 1. Pre-process image for better OCR accuracy
      final enhancedPath = await OCREnhancer.enhancedImagePath(image.path);

      // 2. Run ML Kit in parallel with Latin + Devanagari scripts
      final inputImage = InputImage.fromFilePath(enhancedPath);
      final results = await Future.wait([
        latinRecognizer.processImage(inputImage),
        devanagiriRecognizer.processImage(inputImage),
      ]);

      // 3. Merge all recognised text from all passes
      final fullText = results.map((r) => r.text).join('\n');
      setState(() => _ocrPreview =
          fullText.length > 200 ? '${fullText.substring(0, 200)}…' : fullText);

      // 4. Multi-strategy extraction
      final value = OCREnhancer.extractCreatinine(fullText);
      if (value != null) {
        setState(() => _creatinineController.text = value);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.locale.ocrFailed)),
        );
      }
    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      // Always release ML Kit resources (from original code — prevents memory leaks)
      latinRecognizer.close();
      devanagiriRecognizer.close();
      setState(() => _isScanning = false);
    }
  }

  // ── LANGUAGE PICKER ────────────────────────────────────────────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final loc = AppLocalizations(lang);
            return ListTile(
              leading: const Icon(Icons.language),
              title: Text(loc.langName),
              trailing: lang == widget.currentLanguage
                  ? const Icon(Icons.check_circle, color: Colors.teal)
                  : null,
              onTap: () {
                widget.onLanguageChange(lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.locale;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(loc.appTitle,
            style: GoogleFonts.bebasNeue(letterSpacing: 2, fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.language),
              onPressed: _showLanguagePicker,
              tooltip: 'Change Language'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(loc.scanReport),
            _buildOCRCard(loc),
            if (_ocrPreview != null) _buildOCRPreviewCard(),
            const SizedBox(height: 25),
            _buildSectionHeader(loc.patientDetails),
            _buildModernField(loc.age, _ageController, Icons.calendar_today),
            _buildModernDropdown(loc.diabetes, _hasDiabetes,
                (v) => setState(() => _hasDiabetes = v!)),
            _buildModernDropdown(loc.hypertension, _hasHypertension,
                (v) => setState(() => _hasHypertension = v!)),
            const SizedBox(height: 25),
            _buildSectionHeader(loc.lifestyleSection),
            _buildModernDropdown(loc.smoking, _smokes,
                (v) => setState(() => _smokes = v!)),
            _buildModernDropdown(loc.alcohol, _drinksAlcohol,
                (v) => setState(() => _drinksAlcohol = v!)),
            _buildModernDropdown(loc.painkillers, _painkillers,
                (v) => setState(() => _painkillers = v!)),
            _buildModernDropdown(loc.familyHistory, _familyHistory,
                (v) => setState(() => _familyHistory = v!)),
            _buildMultiChoiceDropdown(
              loc.waterIntake,
              _waterIntake,
              loc.waterOptions,
              (v) => setState(() => _waterIntake = v!),
              Icons.water_drop_outlined,
            ),
            _buildMultiChoiceDropdown(
              loc.exercise,
              _exercise,
              loc.exerciseOptions,
              (v) => setState(() => _exercise = v!),
              Icons.directions_run,
            ),
            _buildMultiChoiceDropdown(
              loc.diet,
              _diet,
              loc.dietOptions,
              (v) => setState(() => _diet = v!),
              Icons.restaurant_menu,
            ),
            _buildMultiChoiceDropdown(
              loc.sleep,
              _sleep,
              loc.sleepOptions,
              (v) => setState(() => _sleep = v!),
              Icons.bedtime_outlined,
            ),
            const SizedBox(height: 40),
            _buildCalculateButton(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      );

  Widget _buildOCRCard(AppLocalizations loc) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.creatinineLabel,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  TextField(
                    controller: _creatinineController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: '0.0'),
                  ),
                ],
              ),
            ),
            _isScanning
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator())
                : Column(
                    children: [
                      IconButton.filled(
                        onPressed: _scanReport,
                        icon: const Icon(Icons.document_scanner_rounded),
                        style: IconButton.styleFrom(
                            minimumSize: const Size(60, 60)),
                      ),
                      const SizedBox(height: 4),
                      const Text('Smart Scan',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
          ],
        ),
      );

  Widget _buildOCRPreviewCard() => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'OCR read: $_ocrPreview',
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildModernField(
          String label, TextEditingController ctrl, IconData icon) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              icon: Icon(icon, size: 20),
              labelText: label,
              border: InputBorder.none),
        ),
      );

  Widget _buildModernDropdown(
          String label, String value, Function(String?) onChanged) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: DropdownButtonFormField<String>(
          value: value,
          items: ['yes', 'no']
              .map((s) =>
                  DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
              .toList(),
          onChanged: onChanged,
          decoration:
              InputDecoration(labelText: label, border: InputBorder.none),
        ),
      );

  Widget _buildMultiChoiceDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: DropdownButtonFormField<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          items: options
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
              icon: Icon(icon, size: 20, color: Colors.teal),
              labelText: label,
              border: InputBorder.none),
        ),
      );

  Widget _buildCalculateButton(AppLocalizations loc) => ElevatedButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ResultSheet(
            age: _ageController.text,
            sc: _creatinineController.text,
            dm: _hasDiabetes,
            htn: _hasHypertension,
            locale: loc,
            smokes: _smokes,
            alcohol: _drinksAlcohol,
            waterIntake: _waterIntake,
            exercise: _exercise,
            diet: _diet,
            sleep: _sleep,
            painkillers: _painkillers,
            familyHistory: _familyHistory,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 65),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: Colors.teal.withOpacity(0.4),
        ),
        child: Text(loc.analyzeBtn,
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      );
}

// ─────────────────────────────────────────────
// RESULT SHEET
// ─────────────────────────────────────────────

class ResultSheet extends StatelessWidget {
  final String age, sc, dm, htn;
  final String smokes, alcohol, waterIntake, exercise, diet, sleep, painkillers, familyHistory;
  final AppLocalizations locale;

  const ResultSheet({
    super.key,
    required this.age,
    required this.sc,
    required this.dm,
    required this.htn,
    required this.locale,
    required this.smokes,
    required this.alcohol,
    required this.waterIntake,
    required this.exercise,
    required this.diet,
    required this.sleep,
    required this.painkillers,
    required this.familyHistory,
  });

  Future<double> _getRiskScore() async {
    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.29.140:8080/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'age': double.tryParse(age) ?? 40.0,
              'sc': double.tryParse(sc) ?? 1.0,
              'htn': htn == 'yes' ? 1 : 0,
              'dm': dm == 'yes' ? 1 : 0,
            }),
          )
          .timeout(const Duration(seconds: 8));
      return (jsonDecode(response.body)['risk_score']).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  Future<String> _getAIAdvice(double score) async {
    final lang = locale.aiPromptLang;
    final prompt = '''
Kidney Disease Risk Score: ${score.toStringAsFixed(1)}%.
Patient profile:
- Age: $age
- Diabetes: $dm | Hypertension: $htn
- Smoking: $smokes | Alcohol: $alcohol
- Daily water intake: $waterIntake
- Physical activity: $exercise
- Diet: $diet
- Sleep: $sleep per night
- Frequent painkiller use: $painkillers
- Family history of kidney disease: $familyHistory

Respond ONLY in $lang.
Give exactly 3 concise, personalised, professional health tips based on this full lifestyle profile.
Address specific risk factors mentioned above.''';
    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.29.140:11434/api/generate'),
            body: jsonEncode(
                {'model': 'tinyllama', 'prompt': prompt, 'stream': false}),
          )
          .timeout(const Duration(seconds: 30));
      return jsonDecode(response.body)['response'].toString().trim();
    } catch (_) {
      return score > 50
          ? '⚠️ High risk detected. Consult a nephrologist.'
          : '✅ Risk is low. Stay hydrated and eat healthy.';
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
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 30),
              Text('${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w900,
                      color:
                          score > 50 ? Colors.redAccent : Colors.teal)),
              Text(locale.aiRisk,
                  style:
                      const TextStyle(letterSpacing: 2, color: Colors.grey)),
              const Divider(height: 60),
              Expanded(
                child: FutureBuilder<String>(
                  future: _getAIAdvice(score),
                  builder: (context, aiSnap) {
                    if (aiSnap.connectionState == ConnectionState.waiting) {
                      return Center(child: Text(locale.aiTyping));
                    }
                    return SingleChildScrollView(
                      child: Text(aiSnap.data ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              height: 1.6,
                              fontWeight: FontWeight.w500)),
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
