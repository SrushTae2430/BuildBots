import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';

class DiabetesAssistantScreen extends StatefulWidget {
  const DiabetesAssistantScreen({super.key});

  @override
  State<DiabetesAssistantScreen> createState() => _DiabetesAssistantScreenState();
}

class _DiabetesAssistantScreenState extends State<DiabetesAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'pregnancies': 0,
    'glucose': 100.0,
    'blood_pressure': 70.0,
    'skin_thickness': 20.0,
    'insulin': 79.0,
    'bmi': 25.0,
    'dpf': 0.5,
    'age': 30,
  };

  final Map<String, TextEditingController> _controllers = {};

  bool _isLoading = false;
  double? _riskResult;

  @override
  void initState() {
    super.initState();
    // initialize controllers with default values
    _controllers['glucose'] = TextEditingController(text: _formData['glucose'].toString());
    _controllers['blood_pressure'] = TextEditingController(text: _formData['blood_pressure'].toString());
    _controllers['bmi'] = TextEditingController(text: _formData['bmi'].toString());
    _controllers['age'] = TextEditingController(text: _formData['age'].toString());
    _controllers['pregnancies'] = TextEditingController(text: _formData['pregnancies'].toString());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() async {
    // sync controllers into _formData before submit
    _formData['glucose'] = double.tryParse(_controllers['glucose']?.text ?? '') ?? _formData['glucose'];
    _formData['blood_pressure'] = double.tryParse(_controllers['blood_pressure']?.text ?? '') ?? _formData['blood_pressure'];
    _formData['bmi'] = double.tryParse(_controllers['bmi']?.text ?? '') ?? _formData['bmi'];
    _formData['age'] = int.tryParse(_controllers['age']?.text ?? '') ?? _formData['age'];
    _formData['pregnancies'] = int.tryParse(_controllers['pregnancies']?.text ?? '') ?? _formData['pregnancies'];

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _riskResult = null;
      });

      try {
        final result = await ApiService.predictDiabetes(_formData);
        setState(() {
          _riskResult = result['diabetes_risk'] * 100;
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
      appBar: AppBar(title: const Text("Diabetes Risk AI Assistant")),
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
                              'glucose': ['glucose', 'glucose level', 'glc'],
                              'blood_pressure': ['blood pressure', 'bp'],
                              'bmi': ['bmi'],
                              'age': ['age'],
                              'pregnancies': ['pregnancy', 'pregnancies'],
                            });

                            setState(() {
                              parsed.forEach((k, v) {
                                if (_formData.containsKey(k)) {
                                  final isInt = _formData[k] is int;
                                  final newVal = isInt ? v.toInt() : v;
                                  _formData[k] = newVal;
                                  // update controller if present
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
                        color: _riskResult! > 50 ? Colors.orange[100] : Colors.green[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Calculated Diabetes Risk:",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${_riskResult!.toStringAsFixed(2)}%",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: _riskResult! > 50 ? Colors.orange[800] : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllers['glucose'],
                      decoration: const InputDecoration(labelText: "Glucose Level", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['blood_pressure'],
                      decoration: const InputDecoration(labelText: "Blood Pressure", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['bmi'],
                      decoration: const InputDecoration(labelText: "BMI", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['age'],
                      decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controllers['pregnancies'],
                      decoration: const InputDecoration(labelText: "Pregnancies", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submit,
                      child: const Text("Analyze Diabetes Risk"),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Note: This is an AI prediction. Please maintain regular health checkups.",
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
