/// Percepción de esfuerzo (RPE simplificado) que da el usuario al
/// terminar un entrenamiento o un ejercicio concreto.
enum WorkoutDifficulty {
  veryEasy,
  easy,
  good,
  hard,
  veryHard,
}

class ExerciseFeedback {
  const ExerciseFeedback({
    required this.exerciseId,
    required this.difficulty,
  });

  final String exerciseId;
  final WorkoutDifficulty difficulty;
}

class WorkoutFeedback {
  const WorkoutFeedback({
    required this.difficulty,
    this.exerciseFeedback = const [],
  });

  final WorkoutDifficulty difficulty;
  final List<ExerciseFeedback> exerciseFeedback;
}
