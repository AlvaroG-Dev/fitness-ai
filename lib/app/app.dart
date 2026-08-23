import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_page.dart';

class FitnessAiApp extends StatelessWidget {
  const FitnessAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B0D10);
    const surface = Color(0xFF15181D);
    const accent = Color(0xFFB8F23D);

    return MaterialApp(
      title: 'Fitness AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: surface,
        ),
        useMaterial3: true,
        fontFamily: 'sans',
      ),
      home: const OnboardingPage(),
    );
  }
}
