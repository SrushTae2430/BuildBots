import 'package:flutter/material.dart';

class VitalsPage extends StatelessWidget {
  const VitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Vitals")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(labelText: "Blood Sugar")),
          TextField(decoration: InputDecoration(labelText: "Blood Pressure")),
          TextField(decoration: InputDecoration(labelText: "Heart Rate")),
          TextField(decoration: InputDecoration(labelText: "SpO₂")),
        ],
      ),
    );
  }
}
