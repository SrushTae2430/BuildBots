import 'package:flutter/material.dart';
import 'chatbot.dart';
import 'vitals.dart';
import 'emergency.dart';
import 'analysis.dart';
import 'ayu_theme.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  const HomePage({super.key, required this.userProfile});

  Widget diseaseCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Placeholder for LLM connection
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatbotScreen(initialTopic: title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: AyuTheme.textGray),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: color),
                ],
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
      appBar: AppBar(
        title: const Text("AyuCare Dashboard"),
        backgroundColor: AyuTheme.primaryTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile synchronized with website")),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AyuTheme.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${userProfile['email'].split('@')[0]}!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AyuTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Language: ${userProfile['language']} | Age: ${userProfile['age']}",
                  style: TextStyle(color: AyuTheme.darkBlue.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          const Text(
            "Health Assessments",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AyuTheme.textDark,
            ),
          ),
          const SizedBox(height: 15),

          diseaseCard(
            context,
            "Diabetes", 
            "Analyze blood sugar trends and risk factors using AI.", 
            Icons.bloodtype, 
            const Color(0xFFff6b6b)
          ),
          diseaseCard(
            context,
            "Skin Diseases", 
            "Upload images for instant AI skin lesion analysis.", 
            Icons.healing, 
            const Color(0xFF4facfe)
          ),
          diseaseCard(
            context,
            "Heart Health", 
            "Evaluate cardiovascular risks and vital patterns.", 
            Icons.favorite, 
            const Color(0xFFfa709a)
          ),
          diseaseCard(
            context,
            "Kidney Health", 
            "Assess renal function and health indicators.", 
            Icons.water_drop, 
            const Color(0xFF30cfd0)
          ),
          
          const SizedBox(height: 10),
          
          ElevatedButton.icon(
            icon: const Icon(Icons.analytics_outlined),
            label: const Text("View Health Analysis Trends"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6c5ce7),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AnalysisPage(userProfile: userProfile)),
              );
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Start AI Health Assistant"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.monitor_heart_outlined),
            label: const Text("Enter Daily Vitals"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AyuTheme.primaryTeal,
              side: const BorderSide(color: AyuTheme.primaryTeal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.emergency_outlined),
            label: const Text("Emergency Mode"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
