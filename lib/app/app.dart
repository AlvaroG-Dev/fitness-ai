import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_flow.dart';
import '../fitness_engine/storage/progress_repository.dart';

class FitnessAiApp extends StatelessWidget {
  const FitnessAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B0D10);
    const surface = Color(0xFF15181D);
    const accent = Color(0xFFB8F23D);

    // Instancia única para toda la app: comparte el mismo historial
    // en memoria entre la generación de entrenamientos, la sesión y
    // la pantalla de progreso.
    final progressRepository = ProgressRepository();

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
      home: OnboardingFlow(progressRepository: progressRepository),
    );
  }
}
