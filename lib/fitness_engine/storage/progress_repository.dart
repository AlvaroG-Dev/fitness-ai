import '../data/exercise_catalog.dart';
import '../models/exercise.dart';
import '../models/workout_result.dart';
import '../progression/progression_service.dart';
import 'workout_history.dart';

/// Fachada principal del progreso.
///
/// La UI y el generador no necesitan conocer cómo se guarda
/// el historial ni cómo se calcula la progresión.
class ProgressRepository {
  ProgressRepository({
    WorkoutHistoryStore? history,
    ProgressionService? progressionService,
  })  : history = history ?? WorkoutHistoryStore.instance,
        progressionService =
            progressionService ?? const ProgressionService();

  final WorkoutHistoryStore history;
  final ProgressionService progressionService;

  Future<void> saveWorkout(WorkoutResult result) async {
    await history.add(result);
  }

  List<WorkoutResult> get workoutHistory => history.all;

  WorkoutResult? get lastWorkout => history.latest;

  /// Devuelve la siguiente carga teniendo en cuenta el resultado más
  /// reciente de la variante solicitada o de cualquier variante conectada
  /// por su cadena de progresión/regresión.
  ///
  /// Se consultan varias sesiones recientes para detectar tendencias,
  /// pero nunca se mezclan ejercicios de otro patrón de movimiento.
  ExerciseProgress? getExerciseProgress(String exerciseId) {
    final requested = _findExercise(exerciseId);
    if (requested == null) return null;

    final candidateIds = _relatedExerciseIds(requested);
    final recent = <ExerciseResult>[];

    for (final workout in history.all) {
      for (final result in workout.exercises) {
        if (candidateIds.contains(result.exerciseId)) {
          recent.add(result);
          if (recent.length >= 5) {
            return progressionService.calculateAdaptiveNext(recent);
          }
        }
      }
    }

    return progressionService.calculateAdaptiveNext(recent);
  }

  /// Historial reciente de una cadena de ejercicios relacionada.
  List<ExerciseResult> recentResultsForExercise(
    String exerciseId, {
    int limit = 10,
  }) {
    final requested = _findExercise(exerciseId);
    if (requested == null || limit <= 0) return const [];

    final candidateIds = _relatedExerciseIds(requested);
    final results = <ExerciseResult>[];

    for (final workout in history.all) {
      for (final result in workout.exercises) {
        if (!candidateIds.contains(result.exerciseId)) continue;
        results.add(result);
        if (results.length >= limit) return List.unmodifiable(results);
      }
    }

    return List.unmodifiable(results);
  }

  List<String> _relatedExerciseIds(Exercise requested) {
    final ids = <String>{requested.id};
    final queue = <String>[requested.id];

    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      final current = _findExercise(currentId);
      if (current == null) continue;

      final neighbours = [current.progressionId, current.regressionId];

      for (final id in neighbours) {
        if (id == null || ids.contains(id)) continue;

        final exercise = _findExercise(id);
        if (exercise == null) continue;
        if (exercise.role != ExerciseRole.main) continue;
        if (exercise.pattern != requested.pattern) continue;

        ids.add(id);
        queue.add(id);
      }
    }

    return ids.toList(growable: false);
  }

  Exercise? _findExercise(String id) {
    for (final exercise in exerciseCatalog) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  int completedWorkoutCount() => history.sessionCount;

  int totalTrainingSeconds() {
    var total = 0;
    for (final workout in history.all) {
      total += workout.elapsedSeconds;
    }
    return total;
  }

  double? get hoursSinceLastSession => history.hoursSinceLastSession;

  int get streak => history.streak;
}
