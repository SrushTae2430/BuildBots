import 'package:flutter/material.dart';
import 'ayu_theme.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  String _selectedLanguage = "English";

  Widget _buildEmergencyNumber(String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
          ),
          Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstAidCard(String title, String subtitle, IconData icon, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AyuTheme.sectionBarColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text("Show $title First Aid"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, size: 16, color: AyuTheme.sectionBarColor),
                      const SizedBox(width: 8),
                      const Text("Select Language", style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        items: ["English", "हिन्दी"].map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) => setState(() => _selectedLanguage = val!),
                        underline: Container(height: 1, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Emergency First Aid",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Quick guidance until help arrives",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Emergency Numbers
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            const Text(
                              "India Emergency Numbers",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildEmergencyNumber("Ambulance", "102 / 108"),
                        _buildEmergencyNumber("Police", "100"),
                        _buildEmergencyNumber("Fire", "101"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // First Aid Cards
                  _buildFirstAidCard("Heart Attack", "Tap for first aid steps", Icons.favorite, Colors.red),
                  _buildFirstAidCard("Stroke (FAST Method)", "Tap for first aid steps", Icons.psychology, Colors.purple),
                  _buildFirstAidCard("Severe Breathing Difficulty", "Tap for first aid steps", Icons.air, Colors.blue),
                  _buildFirstAidCard("Diabetic Emergency (Low Sugar)", "Tap for first aid steps", Icons.medical_services, Colors.orange),

                  const SizedBox(height: 40),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AyuTheme.sectionBarColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: const Text("← Back to Home"),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
