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

/// Convierte el resultado de una sesión en la carga recomendada
/// para la siguiente sesión.
///
/// Flujo:
///
/// WorkoutResult
///      ↓
/// ProgressionService
///      ↓
/// ProgressionEngine
///      ↓
/// ExerciseProgress
///
/// El servicio no decide por sí mismo si progresar o regresar.
/// Esa responsabilidad pertenece exclusivamente al ProgressionEngine.
class ProgressionService {
  const ProgressionService({
    this.engine = const ProgressionEngine(),
  });

  final ProgressionEngine engine;

  /// Calcula la siguiente carga para un ejercicio realizado.
  ExerciseProgress? calculateNext(ExerciseResult result) {
    final exercise = _findExercise(result.exerciseId);

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

  /// Calcula la progresión de todos los ejercicios realizados
  /// durante una sesión.
  List<ExerciseProgress> calculateWorkoutProgress(
      WorkoutResult workout,
      ) {
    final progress = <ExerciseProgress>[];

    for (final exerciseResult in workout.exercises) {
      final next = calculateNext(exerciseResult);

      if (next != null) {
        progress.add(next);
      }
    }

    return progress;
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