import '../models/workout_result.dart';
import '../progression/progression_service.dart';
import 'workout_history.dart';

/// Fachada de acceso al progreso del usuario.
///
/// Es la puerta de entrada que usan las features de UI: por debajo
/// coordina el histórico ([WorkoutHistoryStore]) y el cálculo de
/// progresión ([ProgressionService]) sin que el resto de la app
/// necesite conocer esos detalles.
class ProgressRepository {
  ProgressRepository({
    WorkoutHistoryStore? history,
    ProgressionService? progressionService,
  })  : history = history ?? WorkoutHistoryStore.instance,
        progressionService = progressionService ?? const ProgressionService();

  final WorkoutHistoryStore history;
  final ProgressionService progressionService;

  void saveWorkout(WorkoutResult result) {
    history.add(result);
  }

  List<WorkoutResult> get workoutHistory => history.all;

  WorkoutResult? get lastWorkout => history.latest;

  ExerciseProgress? getExerciseProgress(String exerciseId) {
    final result = history.latestResultForExercise(exerciseId);
    if (result == null) return null;
    return progressionService.calculateNext(result);
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
}
