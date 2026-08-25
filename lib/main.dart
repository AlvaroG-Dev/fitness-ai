import 'package:flutter/material.dart';

import 'app/app.dart';
import 'fitness_engine/storage/workout_history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WorkoutHistoryStore.instance.initialize();

  runApp(
    const FitnessAiApp(),
  );
}