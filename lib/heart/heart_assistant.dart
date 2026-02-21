import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';

class HeartAssistantScreen extends StatefulWidget {
  const HeartAssistantScreen({super.key});

  @override
  State<HeartAssistantScreen> createState() => _HeartAssistantScreenState();
}

class _HeartAssistantScreenState extends State<HeartAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'age': 50,
    'sex': 1,
    'cp': 0,
    'trestbps': 120,
    'chol': 200,
    'fbs': 0,
    'restecg': 0,
    'thalach': 150,
    'exang': 0,
    'oldpeak': 0.0,
    'slope': 1,
    'ca': 0,
    'thal': 2,
  };

  final Map<String, TextEditingController> _controllers = {};

  bool _isLoading = false;
  double? _riskResult;

  @override
  void initState() {
    super.initState();
    _controllers['age'] = TextEditingController(text: _formData['age'].toString());
    _controllers['trestbps'] = TextEditingController(text: _formData['trestbps'].toString());
    _controllers['chol'] = TextEditingController(text: _formData['chol'].toString());
    _controllers['thalach'] = TextEditingController(text: _formData['thalach'].toString());
    _controllers['oldpeak'] = TextEditingController(text: _formData['oldpeak'].toString());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _submit() async {
    // sync controllers
    _formData['age'] = int.tryParse(_controllers['age']?.text ?? '') ?? _formData['age'];
    _formData['trestbps'] = int.tryParse(_controllers['trestbps']?.text ?? '') ?? _formData['trestbps'];
    _formData['chol'] = int.tryParse(_controllers['chol']?.text ?? '') ?? _formData['chol'];
    _formData['thalach'] = int.tryParse(_controllers['thalach']?.text ?? '') ?? _formData['thalach'];
    _formData['oldpeak'] = double.tryParse(_controllers['oldpeak']?.text ?? '') ?? _formData['oldpeak'];

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _riskResult = null;
      });

      try {
        final result = await ApiService.predictHeart(_formData);
        setState(() {
          _riskResult = result['heart_risk'] * 100;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Heart Risk AI Assistant")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scan Report'),
                          onPressed: () async {
                            final source = await showDialog<ImageSource>(
                              context: context,
                              builder: (ctx) => SimpleDialog(
                                title: const Text('Choose Image Source'),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(ctx, ImageSource.camera),
                                    child: const Text('Camera'),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
                                    child: const Text('Gallery'),
                                  ),
                                ],
                              ),
                            );

                            if (source == null) return;

                            final text = await OcrService.pickAndRecognizeText(source: source);
                            if (text == null || text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No text detected')));
                              return;
                            }

                            final parsed = OcrService.parseFields(text, {
                              'age': ['age'],
                              'trestbps': ['blood pressure', 'trestbps', 'bp'],
                              'chol': ['cholesterol', 'chol'],
                              'thalach': ['thalach', 'max heart rate', 'heart rate'],
                              'oldpeak': ['oldpeak', 'st depression', 'st-depression'],
                            });

                            setState(() {
                              parsed.forEach((k, v) {
                                if (_formData.containsKey(k)) {
                                  final isInt = _formData[k] is int;
                                  final newVal = isInt ? v.toInt() : v;
                                  _formData[k] = newVal;
                                  if (_controllers.containsKey(k)) _controllers[k]!.text = newVal.toString();
                                }
                              });
                            });

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fields populated from report')));
                          },
                        ),
                      ],
                    ),
                    if (_riskResult != null)
                      Card(
                        color: _riskResult! > 50 ? Colors.red[100] : Colors.green[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Calculated Heart Disease Risk:",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${_riskResult!.toStringAsFixed(2)}%",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: _riskResult! > 50 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllers['age'],
                      decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "Sex", border: OutlineInputBorder()),
                      value: _formData['sex'],
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Male")),
                        DropdownMenuItem(value: 0, child: Text("Female")),
                      ],
                      onChanged: (val) => setState(() => _formData['sex'] = val),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['trestbps'],
                      decoration: const InputDecoration(labelText: "Resting Blood Pressure (trestbps)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['chol'],
                      decoration: const InputDecoration(labelText: "Cholesterol (chol)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['thalach'],
                      decoration: const InputDecoration(labelText: "Max Heart Rate (thalach)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['oldpeak'],
                      decoration: const InputDecoration(labelText: "ST Depression (oldpeak)", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submit,
                      child: const Text("Analyze Heart Risk"),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Note: This is an AI prediction based on provided data. Always consult a doctor for clinical diagnosis.",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
