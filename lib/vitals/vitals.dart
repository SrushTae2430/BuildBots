import 'package:flutter/material.dart';
import '../ayu_theme.dart';

class VitalsPage extends StatelessWidget {
  const VitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Health Vitals"),
        backgroundColor: AyuTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Track your health metrics daily for better insights.",
            style: TextStyle(color: AyuTheme.textGray),
          ),
          const SizedBox(height: 24),
          _buildVitalInput("Blood Sugar", Icons.bloodtype, "mg/dL"),
          _buildVitalInput("Blood Pressure", Icons.speed, "mmHg"),
          _buildVitalInput("Heart Rate", Icons.favorite, "bpm"),
          _buildVitalInput("SpO2", Icons.air, "%"),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Save Vitals"),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalInput(String label, IconData icon, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          prefixIcon: Icon(icon, color: AyuTheme.primaryTeal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
