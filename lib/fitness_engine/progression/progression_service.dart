import '../data/exercise_catalog.dart';
import '../models/exercise.dart';
import '../models/workout_feedback.dart';
import '../models/workout_result.dart';
import 'progression_engine.dart';

class ExerciseProgress {
  const ExerciseProgress({
    required this.exerciseId,
    required this.currentValue,
    required this.difficulty,
    required this.action,
  });

  final String exerciseId;
  final int currentValue;
  final WorkoutDifficulty difficulty;
  final ProgressionAction action;
}

/// Convierte el historial de una sesión o de varias sesiones en la
/// siguiente carga recomendada para un ejercicio.
class ProgressionService {
  const ProgressionService({
    this.engine = const ProgressionEngine(),
  });

  final ProgressionEngine engine;

  /// Mantiene compatibilidad con el cálculo de una única sesión.
  ExerciseProgress? calculateNext(ExerciseResult result) {
    return calculateAdaptiveNext([result]);
  }

  /// Calcula la siguiente carga usando resultados del ejercicio y de sus
  /// variantes relacionados, ordenados del más reciente al más antiguo.
  ///
  /// Solo se considera la racha consecutiva que empieza en el resultado
  /// más reciente. Un cambio de esfuerzo rompe la racha para no sobrerreaccionar.
  ExerciseProgress? calculateAdaptiveNext(
    Iterable<ExerciseResult> recentResults,
  ) {
    final results = recentResults.toList(growable: false);
    if (results.isEmpty) return null;

    final latest = results.first;
    final exercise = _findExercise(latest.exerciseId);
    if (exercise == null) return null;

    final streak = _consecutiveDifficulty(results);

    final decision = engine.decideAdaptive(
      exercise: exercise,
      currentValue: latest.value,
      difficulty: latest.feedback,
      consecutiveSessions: streak,
    );

    return ExerciseProgress(
      exerciseId: decision.exercise.id,
      currentValue: decision.value,
      difficulty: latest.feedback,
      action: decision.action,
    );
  }

  List<ExerciseProgress> calculateWorkoutProgress(
    WorkoutResult workout,
  ) {
    final progress = <ExerciseProgress>[];
    final seen = <String>{};

    for (final exerciseResult in workout.exercises) {
      if (!seen.add(exerciseResult.exerciseId)) continue;

      final next = calculateNext(exerciseResult);
      if (next != null) {
        progress.add(next);
      }
    }

    return progress;
  }

  int _consecutiveDifficulty(List<ExerciseResult> results) {
    if (results.isEmpty) return 0;

    final firstBand = _effortBand(results.first.feedback);
    var count = 0;

    for (final result in results) {
      if (_effortBand(result.feedback) != firstBand) break;
      count++;
      if (count >= 5) break;
    }

    return count;
  }

  int _effortBand(WorkoutDifficulty difficulty) {
    return switch (difficulty) {
      WorkoutDifficulty.veryEasy || WorkoutDifficulty.easy => 1,
      WorkoutDifficulty.good => 2,
      WorkoutDifficulty.hard || WorkoutDifficulty.veryHard => 3,
    };
  }

  Exercise? _findExercise(String id) {
    for (final exercise in exerciseCatalog) {
      if (exercise.id == id) {
        return exercise;
      }
    }

    return null;
  }
}
