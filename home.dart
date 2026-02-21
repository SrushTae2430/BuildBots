import 'package:flutter/material.dart';
import '../chatbot/chatbot.dart';
import '../vitals/vitals.dart';
import '../emergency/emergency.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget diseaseCard(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        subtitle: const Text("Tap to learn symptoms & check risk"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          diseaseCard("Diabetes", Icons.bloodtype),
          diseaseCard("Skin Diseases", Icons.healing),
          diseaseCard("Respiratory Issues", Icons.air),
          diseaseCard("Heart Risk", Icons.favorite),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text("Start AI Health Assistant"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
          ),
          ElevatedButton(
            child: const Text("Enter Vitals"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsPage()),
              );
            },
          ),
          ElevatedButton(
            child: const Text("Emergency Guidance"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
