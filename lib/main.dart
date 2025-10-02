import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LeadLevelPredictorApp());
}

class LeadLevelPredictorApp extends StatelessWidget {
  const LeadLevelPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead Level Predictor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
