import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Guidance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "If breathing is severe:\n"
              "• Sit upright\n"
              "• Loosen tight clothing\n"
              "• Use inhaler if prescribed\n\n"
              "Call local emergency services immediately.\n"
              "This does not replace medical care.",
        ),
      ),
    );
  }
}
