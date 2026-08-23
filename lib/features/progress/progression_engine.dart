import 'workout_history.dart';

class ProgressionDecision {
  const ProgressionDecision({required this.repsDelta, required this.message});
  final int repsDelta;
  final String message;
}

class ProgressionEngine {
  const ProgressionEngine();

  ProgressionDecision next(List<WorkoutRecord> history) {
    if (history.isEmpty) {
      return const ProgressionDecision(
        repsDelta: 0,
        message: 'Primera sesión: empezamos con una carga conservadora.',
      );
    }

    final latest = history.first;
    switch (latest.difficulty) {
      case Effort.easy:
        return const ProgressionDecision(
          repsDelta: 2,
          message: 'Te resultó fácil. Subiremos ligeramente el estímulo.',
        );
      case Effort.normal:
        return const ProgressionDecision(
          repsDelta: 0,
          message: 'Buen nivel. Mantendremos el estímulo y consolidaremos.',
        );
      case Effort.hard:
        return const ProgressionDecision(
          repsDelta: -2,
          message: 'Fue exigente. Priorizamos recuperación antes de progresar.',
        );
    }
  }
}
