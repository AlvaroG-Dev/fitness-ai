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

/// Traduce resultados de sesiones pasadas en la próxima carga
/// objetivo por ejercicio, apoyándose en el [ProgressionEngine].
class ProgressionService {
  const ProgressionService({
    this.engine = const ProgressionEngine(),
  });

  final ProgressionEngine engine;

  ExerciseProgress? calculateNext(ExerciseResult result) {
    Exercise? exercise;

    for (final candidate in exerciseCatalog) {
      if (candidate.id == result.exerciseId) {
        exercise = candidate;
        break;
      }
    }

    if (exercise == null) {
      return null;
    }

    final decision = engine.decide(
      exercise: exercise,
      currentValue: result.value,
      difficulty: result.feedback,
    );

    return ExerciseProgress(
      exerciseId: decision.exercise.id,
      currentValue: decision.value,
      difficulty: result.feedback,
      action: decision.action,
    );
  }

  List<ExerciseProgress> calculateWorkoutProgress(WorkoutResult workout) {
    final result = <ExerciseProgress>[];

    for (final exercise in workout.exercises) {
      final progress = calculateNext(exercise);

      if (progress != null) {
        result.add(progress);
      }
    }

    return result;
  }
}
