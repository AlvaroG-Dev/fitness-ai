import 'package:flutter/material.dart';

import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/onboarding_state.dart';
import '../fitness_engine/storage/progress_repository.dart';

class FitnessAiApp extends StatelessWidget {
  const FitnessAiApp({
    super.key,
    this.initialProfile,
  });

  final OnboardingState? initialProfile;

  @override
  Widget build(
      BuildContext context,
      ) {
    const background =
    Color(0xFF0B0D10);

    const surface =
    Color(0xFF15181D);

    const accent =
    Color(0xFFB8F23D);

    final progressRepository =
    ProgressRepository();

    return MaterialApp(
      title: 'Fitness AI',

      debugShowCheckedModeBanner:
      false,

      theme: ThemeData(
        brightness:
        Brightness.dark,

        scaffoldBackgroundColor:
        background,

        colorScheme:
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness:
          Brightness.dark,
          surface: surface,
        ),

        useMaterial3: true,

        fontFamily: 'sans',
      ),

      home: initialProfile == null
          ? OnboardingFlow(
        progressRepository:
        progressRepository,
      )
          : HomeShell(
        profile:
        initialProfile!,
        progressRepository:
        progressRepository,
      ),
    );
  }
}