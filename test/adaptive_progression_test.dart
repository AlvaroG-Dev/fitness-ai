import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_ai/fitness_engine/models/workout_feedback.dart';
import 'package:fitness_ai/fitness_engine/models/workout_result.dart';
import 'package:fitness_ai/fitness_engine/progression/progression_engine.dart';
import 'package:fitness_ai/fitness_engine/progression/progression_service.dart';
import 'package:fitness_ai/fitness_engine/storage/progress_repository.dart';
import 'package:fitness_ai/fitness_engine/storage/workout_history.dart';

void main() {
  late WorkoutHistoryStore history;
  late ProgressRepository repository;

  setUp(() {
    history = WorkoutHistoryStore.forTesting();
    repository = ProgressRepository(history: history);
  });

  tearDown(() async {
    await history.clear();
  });

  test('dos sesiones fáciles consecutivas aumentan más la carga', () async {
    await repository.saveWorkout(_result(
      value: 10,
      difficulty: WorkoutDifficulty.easy,
      date: DateTime(2026, 8, 23),
    ));
    await repository.saveWorkout(_result(
      value: 11,
      difficulty: WorkoutDifficulty.easy,
      date: DateTime(2026, 8, 24),
    ));

    final progress = repository.getExerciseProgress('push_up');

    expect(progress, isNotNull);
    expect(progress!.action, ProgressionAction.progress);
    expect(progress.exerciseId, 'push_up');
    expect(progress.currentValue, 13);
  });

  test('tres sesiones duras consecutivas reducen progresivamente la carga', () async {
    await repository.saveWorkout(_result(
      value: 12,
      difficulty: WorkoutDifficulty.hard,
      date: DateTime(2026, 8, 22),
    ));
    await repository.saveWorkout(_result(
      value: 10,
      difficulty: WorkoutDifficulty.hard,
      date: DateTime(2026, 8, 23),
    ));
    await repository.saveWorkout(_result(
      value: 9,
      difficulty: WorkoutDifficulty.hard,
      date: DateTime(2026, 8, 24),
    ));

    final progress = repository.getExerciseProgress('push_up');

    expect(progress, isNotNull);
    expect(progress!.action, ProgressionAction.regress);
    expect(progress.exerciseId, 'push_up');
    expect(progress.currentValue, 6);
  });

  test('muy difícil cambia a la variante de regresión', () async {
    await repository.saveWorkout(_result(
      value: 10,
      difficulty: WorkoutDifficulty.veryHard,
      date: DateTime(2026, 8, 24),
    ));

    final progress = repository.getExerciseProgress('push_up');

    expect(progress, isNotNull);
    expect(progress!.action, ProgressionAction.regress);
    expect(progress.exerciseId, 'incline_push_up');
    expect(progress.currentValue, 8);
  });

  test('una sesión fácil seguida de una muy difícil no arrastra la racha anterior', () async {
    await repository.saveWorkout(_result(
      value: 10,
      difficulty: WorkoutDifficulty.easy,
      date: DateTime(2026, 8, 23),
    ));
    await repository.saveWorkout(_result(
      value: 10,
      difficulty: WorkoutDifficulty.veryHard,
      date: DateTime(2026, 8, 24),
    ));

    final progress = repository.getExerciseProgress('push_up');

    expect(progress, isNotNull);
    expect(progress!.exerciseId, 'incline_push_up');
    expect(progress.currentValue, 8);
  });

  test('el repositorio puede recuperar feedback reciente de una cadena relacionada', () async {
    await repository.saveWorkout(_result(
      exerciseId: 'incline_push_up',
      value: 8,
      difficulty: WorkoutDifficulty.good,
      date: DateTime(2026, 8, 23),
    ));
    await repository.saveWorkout(_result(
      exerciseId: 'push_up',
      value: 10,
      difficulty: WorkoutDifficulty.easy,
      date: DateTime(2026, 8, 24),
    ));

    final recent = repository.recentResultsForExercise('push_up');

    expect(recent, hasLength(2));
    expect(recent.first.exerciseId, 'push_up');
    expect(recent.last.exerciseId, 'incline_push_up');
  });

  test('ProgressionService conserva el cálculo de una sola sesión', () {
    const service = ProgressionService();

    final result = service.calculateNext(
      const ExerciseResult(
        exerciseId: 'push_up',
        value: 10,
        feedback: WorkoutDifficulty.veryEasy,
      ),
    );

    expect(result, isNotNull);
    expect(result!.action, ProgressionAction.progress);
    expect(result.currentValue, 12);
  });
}

WorkoutResult _result({
  String exerciseId = 'push_up',
  required int value,
  required WorkoutDifficulty difficulty,
  required DateTime date,
}) {
  return WorkoutResult(
    workoutTitle: 'Test',
    completedAt: date,
    elapsedSeconds: 600,
    feedback: difficulty,
    exercises: [
      ExerciseResult(
        exerciseId: exerciseId,
        value: value,
        feedback: difficulty,
      ),
    ],
  );
}
