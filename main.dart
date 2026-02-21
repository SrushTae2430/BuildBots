import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MedAssist());
}

class MedAssist extends StatelessWidget {
  const MedAssist({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAssist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('ta'),
        Locale('te'),
        Locale('bn'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginPage(),
    );
  }
}
