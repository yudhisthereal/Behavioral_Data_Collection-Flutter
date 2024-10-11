import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behavioral Data Collection  ',
      theme: ThemeData(
        primaryColor: const Color(0xFF422b97),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF422b97),
          secondary: const Color(0xFF1C74DB),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
