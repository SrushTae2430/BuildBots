import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
                      decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _formData['age'].toString(),
                      onSaved: (val) => _formData['age'] = int.parse(val!),
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
                      decoration: const InputDecoration(labelText: "Resting Blood Pressure (trestbps)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _formData['trestbps'].toString(),
                      onSaved: (val) => _formData['trestbps'] = int.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Cholesterol (chol)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _formData['chol'].toString(),
                      onSaved: (val) => _formData['chol'] = int.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Max Heart Rate (thalach)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _formData['thalach'].toString(),
                      onSaved: (val) => _formData['thalach'] = int.parse(val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "ST Depression (oldpeak)", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: _formData['oldpeak'].toString(),
                      onSaved: (val) => _formData['oldpeak'] = double.parse(val!),
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
