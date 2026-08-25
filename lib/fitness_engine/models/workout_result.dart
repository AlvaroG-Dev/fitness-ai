import 'workout_feedback.dart';

class ExerciseResult {
  const ExerciseResult({
    required this.exerciseId,
    required this.value,
    required this.feedback,
  });

  final String exerciseId;

  /// Repeticiones o segundos realizados.
  final int value;

  final WorkoutDifficulty feedback;
}

class WorkoutResult {
  const WorkoutResult({
    required this.workoutTitle,
    required this.completedAt,
    required this.elapsedSeconds,
    required this.feedback,
    required this.exercises,
  });

  final String workoutTitle;
  final DateTime completedAt;
  final int elapsedSeconds;
  final WorkoutDifficulty feedback;
  final List<ExerciseResult> exercises;
}
