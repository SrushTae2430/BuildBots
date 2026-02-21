import 'package:flutter/material.dart';
import 'ayu_theme.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  String _selectedLanguage = "English";

  final Map<String, Map<String, List<String>>> _firstAidData = {
    "English": {
      "Heart Attack": [
        "Call 102/108 immediately",
        "Help person sit down and rest",
        "Loosen tight clothing",
        "Give aspirin if available (chew, don't swallow)",
        "Stay calm and monitor breathing",
        "Be ready to perform CPR if needed"
      ],
      "Stroke (FAST Method)": [
        "F: Face - Ask to smile, check if one side droops",
        "A: Arms - Raise both arms, check if one drifts down",
        "S: Speech - Ask to repeat a phrase, check if slurred",
        "T: Time - Call 102/108 immediately if any signs",
        "Note: Keep person lying down with head slightly elevated."
      ],
      "Severe Breathing Difficulty": [
        "Call 102/108 immediately",
        "Help person sit upright",
        "Loosen tight clothing around neck/chest",
        "Keep calm, encourage slow breathing",
        "If they have inhaler, help them use it",
        "Monitor consciousness"
      ],
      "Diabetic Emergency (Low Sugar)": [
        "If conscious: Give sugary drink/candy immediately",
        "Wait 15 minutes, recheck",
        "If unconscious: Call 102/108, do NOT give food/drink",
        "Place in recovery position",
        "Monitor breathing",
        "Stay with them until help arrives"
      ],
    },
    "हिन्दी": {
      "Heart Attack": [
        "तुरंत 102/108 पर कॉल करें",
        "व्यक्ति को बैठने और आराम करने में मदद करें",
        "तंग कपड़े ढीले करें",
        "यदि उपलब्ध हो तो एस्पिरिन दें (चबाएं, निगलें नहीं)",
        "शांत रहें और सांस लेने की निगरानी करें",
        "यदि आवश्यक हो तो सीपीआर (CPR) करने के लिए तैयार रहें"
      ],
      "Stroke (FAST Method)": [
        "F: चेहरा - मुस्कुराने के लिए कहें, देखें कि क्या एक तरफ झुक रहा है",
        "A: हाथ - दोनों हाथ उठाएं, देखें कि क्या एक नीचे गिर रहा है",
        "S: बोलना - एक वाक्यांश दोहराने के लिए कहें, देखें कि क्या बोली लड़खड़ा रही है",
        "T: समय - कोई भी लक्षण दिखने पर तुरंत 102/108 पर कॉल करें",
        "नोट: व्यक्ति को सिर थोड़ा ऊपर उठाकर लेटे रहने दें।"
      ],
      "Severe Breathing Difficulty": [
        "तुरंत 102/108 पर कॉल करें",
        "व्यक्ति को सीधा बैठने में मदद करें",
        "गर्दन/छाती के पास के तंग कपड़े ढीले करें",
        "शांत रहें, धीरे सांस लेने के लिए प्रोत्साहित करें",
        "यदि उनके पास इनहेलर है, तो उसका उपयोग करने में मदद करें",
        "चेतना (Hosh) की निगरानी करें"
      ],
      "Diabetic Emergency (Low Sugar)": [
        "यदि होश में है: तुरंत मीठा पेय/कैंडी दें",
        "15 मिनट प्रतीक्षा करें, फिर से जाँचें",
        "यदि बेहोश है: 102/108 पर कॉल करें, भोजन/पेय न दें",
        "रिकवरी स्थिति (Recovery position) में लिटाएं",
        "साँस लेने की निगरानी करें",
        "मदद आने तक उनके साथ रहें"
      ],
    }
  };

  void _showFirstAidSheet(String title, List<String> steps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "$title First Aid",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              ...steps.asMap().entries.map((entry) {
                int idx = entry.key;
                String step = entry.value;
                bool isNote = step.startsWith("Note:") || step.startsWith("नोट:");
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isNote)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${idx + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.info_outline, color: Colors.blueAccent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: isNote ? FontWeight.bold : FontWeight.normal,
                            color: isNote ? Colors.blueAccent : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text("I Understand"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
    // Determine the steps based on language and title
    String dataKey = title;
    // Map specific titles to data keys if they differ
    if (title.contains("Heart")) dataKey = "Heart Attack";
    if (title.contains("Stroke")) dataKey = "Stroke (FAST Method)";
    if (title.contains("Breathing")) dataKey = "Severe Breathing Difficulty";
    if (title.contains("Diabetic")) dataKey = "Diabetic Emergency (Low Sugar)";

    final steps = _firstAidData[_selectedLanguage]?[dataKey] ?? ["Steps coming soon..."];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showFirstAidSheet(dataKey, steps),
        borderRadius: BorderRadius.circular(15),
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
                        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titleText = _selectedLanguage == "English" ? "Emergency First Aid" : "आपातकालीन प्राथमिक चिकित्सा";
    String subtitleText = _selectedLanguage == "English" ? "Quick guidance until help arrives" : "मदद आने तक त्वरित मार्गदर्शन";
    String indiaNumbersText = _selectedLanguage == "English" ? "India Emergency Numbers" : "भारत आपातकालीन नंबर";
    String ambulanceText = _selectedLanguage == "English" ? "Ambulance" : "एम्बुलेंस";
    String policeText = _selectedLanguage == "English" ? "Police" : "पुलिस";
    String fireText = _selectedLanguage == "English" ? "Fire" : "फायर";
    String backText = _selectedLanguage == "English" ? "← Back to Home" : "← होम पर वापस जाएं";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, size: 16, color: AyuTheme.sectionBarColor),
                      const SizedBox(width: 8),
                      const Text("Language", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            isDense: true,
                            items: ["English", "हिन्दी"].map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (val) => setState(() => _selectedLanguage = val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitleText,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_in_talk, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Text(
                              indiaNumbersText,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildEmergencyNumber(ambulanceText, "102 / 108"),
                        _buildEmergencyNumber(policeText, "100"),
                        _buildEmergencyNumber(fireText, "101"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // First Aid Cards
                  _buildFirstAidCard(
                    _selectedLanguage == "English" ? "Heart Attack" : "दिल का दौरा (Heart Attack)", 
                    _selectedLanguage == "English" ? "Tap for first aid steps" : "प्राथमिक चिकित्सा के लिए टैप करें", 
                    Icons.favorite, Colors.red
                  ),
                  _buildFirstAidCard(
                    _selectedLanguage == "English" ? "Stroke (FAST Method)" : "लकवा (Stroke - FAST विधि)", 
                    _selectedLanguage == "English" ? "Tap for first aid steps" : "प्राथमिक चिकित्सा के लिए टैप करें", 
                    Icons.psychology, Colors.purple
                  ),
                  _buildFirstAidCard(
                    _selectedLanguage == "English" ? "Severe Breathing Difficulty" : "सांस लेने में गंभीर कठिनाई", 
                    _selectedLanguage == "English" ? "Tap for first aid steps" : "प्राथमिक चिकित्सा के लिए टैप करें", 
                    Icons.air, Colors.blue
                  ),
                  _buildFirstAidCard(
                    _selectedLanguage == "English" ? "Diabetic Emergency (Low Sugar)" : "मधुमेह आपातकाल (कम शुगर)", 
                    _selectedLanguage == "English" ? "Tap for first aid steps" : "प्राथमिक चिकित्सा के लिए टैप करें", 
                    Icons.medical_services, Colors.orange
                  ),

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
                      child: Text(backText),
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
