import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/onboarding/onboarding_state.dart';
import 'features/onboarding/onboarding_store.dart';
import 'fitness_engine/storage/workout_history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WorkoutHistoryStore.instance.initialize();

  const onboardingStore =
  OnboardingStore();

  final onboardingCompleted =
  await onboardingStore.isCompleted();

  OnboardingState? profile;

  if (onboardingCompleted) {
    profile =
    await onboardingStore.load();
  }

  runApp(
    FitnessAiApp(
      initialProfile: profile,
    ),
  );
}