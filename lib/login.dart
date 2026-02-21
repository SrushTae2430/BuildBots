import 'package:flutter/material.dart';
import 'home.dart';
import 'api_service.dart';
import 'ayu_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Fields State
  final _emailController = TextEditingController();
  final _ageController = TextEditingController(text: "35");
  String _selectedLanguage = "English";
  String _selectedGender = "Prefer not to say";
  
  // Section 2
  final _heightController = TextEditingController(text: "170");
  final _weightController = TextEditingController(text: "70");

  // Section 3
  String? _selectedLifestyle;
  String? _selectedSmoking;
  String? _selectedAlcohol;
  String? _selectedExercise;
  String? _selectedDiet;
  final _sleepController = TextEditingController();
  final _stressController = TextEditingController();

  // Section 4
  final _medicalConditionsController = TextEditingController();
  final Map<String, bool> _familyHistory = {
    "Diabetes": false,
    "Heart Disease": false,
    "Cancer": false,
    "Hypertension": false,
    "Stroke": false,
    "Asthma": false,
  };

  Widget _buildSectionHeader(String number, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      decoration: BoxDecoration(
        color: AyuTheme.sectionBarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.rectangle,
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final profileData = {
      "email": _emailController.text,
      "language": _selectedLanguage,
      "age": int.tryParse(_ageController.text) ?? 35,
      "gender": _selectedGender,
      "height": int.tryParse(_heightController.text),
      "weight": int.tryParse(_weightController.text),
      "lifestyle": _selectedLifestyle,
      "smoking": _selectedSmoking,
      "alcohol": _selectedAlcohol,
      "exercise": _selectedExercise,
      "diet": _selectedDiet,
      "sleep": _sleepController.text,
      "stress": _stressController.text,
      "medical_conditions": _medicalConditionsController.text,
      "family_history": _familyHistory.entries.where((e) => e.value).map((e) => e.key).toList(),
    };

    final success = await ApiService.login(profileData);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userProfile: profileData)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sync failed. Check connection.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
              decoration: BoxDecoration(gradient: AyuTheme.headerGradient),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AyuCare",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Early Detection • AI Insights • Privacy First",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Login to Continue",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Complete your health profile to get started",
                      style: TextStyle(color: AyuTheme.textGray),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Login helps personalize your health insights securely.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AyuTheme.textGray, fontSize: 13),
                    ),

                    // Section 1: Basic Info
                    _buildSectionHeader("1", "Basic Information"),
                    _buildDropdown("Preferred Language *", _selectedLanguage, 
                      ["English", "हिन्दी", "मराठी", "தமிழ்", "తెలుగు", "বাংলা"], 
                      (val) => setState(() => _selectedLanguage = val!)),
                    _buildInputField("Email *", _emailController, hint: "your.email@example.com"),
                    Row(
                      children: [
                        Expanded(child: _buildInputField("Age *", _ageController, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown("Gender (Optional)", _selectedGender, 
                          ["Male", "Female", "Prefer not to say"], 
                          (val) => setState(() => _selectedGender = val!))),
                      ],
                    ),

                    // Section 2: Physical Measurements
                    _buildSectionHeader("2", "Physical Measurements (Optional)"),
                    Row(
                      children: [
                        Expanded(child: _buildInputField("Height (cm)", _heightController, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInputField("Weight (kg)", _weightController, keyboardType: TextInputType.number)),
                      ],
                    ),

                    // Section 3: Lifestyle
                    _buildSectionHeader("3", "Lifestyle & Habits (Optional)"),
                    _buildDropdown("Lifestyle", _selectedLifestyle, 
                      ["Sedentary", "Mildly Active", "Moderately Active", "Very Active"], 
                      (val) => setState(() => _selectedLifestyle = val)),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown("Smoking Status", _selectedSmoking, ["Non-smoker", "Former smoker", "Current smoker"], (val) => setState(() => _selectedSmoking = val))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown("Alcohol Consumption", _selectedAlcohol, ["Never", "Socially", "Regularly"], (val) => setState(() => _selectedAlcohol = val))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown("Exercise Frequency", _selectedExercise, ["Daily", "Weekly", "Rarely", "Never"], (val) => setState(() => _selectedExercise = val))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown("Diet Type", _selectedDiet, ["Vegetarian", "Non-Vegetarian", "Vegan"], (val) => setState(() => _selectedDiet = val))),
                      ],
                    ),

                    // Section 4: Medical History
                    _buildSectionHeader("4", "Medical History (Optional)"),
                    _buildInputField("Known Medical Conditions", _medicalConditionsController, hint: "e.g., Hypertension, Asthma, Diabetes"),
                    const Text("Family History of Diseases", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: _familyHistory.keys.map((key) {
                        return SizedBox(
                          width: 150,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(key, style: const TextStyle(fontSize: 12)),
                            value: _familyHistory[key],
                            onChanged: (val) => setState(() => _familyHistory[key] = val!),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      }).toList(),
                    ),

                    // Privacy Notice
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: Colors.green[700], size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Your medical data is encrypted, private, and never shared.",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Buttons
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login & Continue to App"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        final demoProfile = {
                          "email": "demo@ayucare.ai",
                          "language": "English",
                          "age": 28,
                        };
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage(userProfile: demoProfile)),
                        );
                      },
                      child: const Text("Skip Sync (Demo Mode) →", style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AyuTheme.sectionBarColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "← Back to Home",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
