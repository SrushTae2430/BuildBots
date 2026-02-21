import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'home/home.dart';
import 'services/api_service.dart';
import 'ayu_theme.dart';

void main() {
  runApp(const MedAssist());
}

class MedAssist extends StatelessWidget {
  const MedAssist({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AyuCare',
      debugShowCheckedModeBanner: false,
      theme: AyuTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Artificial delay for splash feel
    await Future.delayed(const Duration(seconds: 2));
    
    final profile = await ApiService.getProfile();
    
    if (mounted) {
      if (profile.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userProfile: profile)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AyuTheme.headerGradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "AyuCare",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Privacy-First Healthcare",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}