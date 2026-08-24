import 'workout_feedback.dart';

class WorkoutResult {
  const WorkoutResult({
    required this.date,
    required this.durationSeconds,
    required this.feedback,
  });

  final DateTime date;
  final int durationSeconds;
  final WorkoutFeedback feedback;
}