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
  })  : history =
      history ?? WorkoutHistoryStore.instance,
        progressionService =
            progressionService ??
                const ProgressionService();

  final WorkoutHistoryStore history;
  final ProgressionService progressionService;

  Future<void> saveWorkout(
      WorkoutResult result,
      ) async {
    await history.add(result);
  }

  List<WorkoutResult> get workoutHistory =>
      history.all;

  WorkoutResult? get lastWorkout =>
      history.latest;

  ExerciseProgress? getExerciseProgress(
      String exerciseId,
      ) {
    final result =
    history.latestResultForExercise(
      exerciseId,
    );

    if (result == null) {
      return null;
    }

    return progressionService.calculateNext(
      result,
    );
  }

  int completedWorkoutCount() {
    return history.sessionCount;
  }

  int totalTrainingSeconds() {
    var total = 0;

    for (final workout in history.all) {
      total += workout.elapsedSeconds;
    }

    return total;
  }

  double? get hoursSinceLastSession =>
      history.hoursSinceLastSession;

  int get streak => history.streak;
}