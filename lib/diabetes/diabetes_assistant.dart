import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  bool _isLoading = false;
  double? _riskResult;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
                      decoration: const InputDecoration(labelText: "Glucose Level", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: _formData['glucose'].toString(),
                      onSaved: (val) => _formData['glucose'] = double.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Blood Pressure", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: _formData['blood_pressure'].toString(),
                      onSaved: (val) => _formData['blood_pressure'] = double.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "BMI", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: _formData['bmi'].toString(),
                      onSaved: (val) => _formData['bmi'] = double.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _formData['age'].toString(),
                      onSaved: (val) => _formData['age'] = int.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Pregnancies", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _formData['pregnancies'].toString(),
                      onSaved: (val) => _formData['pregnancies'] = int.parse(val!),
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
