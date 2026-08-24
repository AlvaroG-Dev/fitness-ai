import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_ai/fitness_engine/data/exercise_catalog.dart';
import 'package:fitness_ai/fitness_engine/models/workout_feedback.dart';
import 'package:fitness_ai/fitness_engine/progression/progression_engine.dart';

void main() {
  const engine = ProgressionEngine();

  test('ejercicio fácil aumenta repeticiones', () {
    final pushUp = exerciseCatalog.firstWhere(
          (exercise) => exercise.id == 'push_up',
    );

    final result = engine.decide(
      exercise: pushUp,
      currentValue: 10,
      difficulty: WorkoutDifficulty.easy,
    );

    expect(result.action, ProgressionAction.progress);
    expect(result.value, 11);
    expect(result.exercise.id, 'push_up');
  });

  test('ejercicio muy difícil puede regresar', () {
    final pushUp = exerciseCatalog.firstWhere(
          (exercise) => exercise.id == 'push_up',
    );

    final result = engine.decide(
      exercise: pushUp,
      currentValue: 10,
      difficulty: WorkoutDifficulty.veryHard,
    );

    expect(result.action, ProgressionAction.regress);
    expect(
      result.exercise.id,
      'incline_push_up',
    );
  });

  test('plancha aumenta tiempo', () {
    final plank = exerciseCatalog.firstWhere(
          (exercise) => exercise.id == 'plank',
    );

    final result = engine.decide(
      exercise: plank,
      currentValue: 30,
      difficulty: WorkoutDifficulty.easy,
    );

    expect(result.action, ProgressionAction.progress);
    expect(result.value, 35);
  });

  test('dificultad adecuada mantiene el ejercicio', () {
    final squat = exerciseCatalog.firstWhere(
          (exercise) => exercise.id == 'bodyweight_squat',
    );

    final result = engine.decide(
      exercise: squat,
      currentValue: 12,
      difficulty: WorkoutDifficulty.good,
    );

    expect(result.action, ProgressionAction.maintain);
    expect(result.value, 12);
  });
}