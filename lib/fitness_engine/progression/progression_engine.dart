import '../data/exercise_catalog.dart';
import '../models/exercise.dart';
import '../models/workout_feedback.dart';

enum ProgressionAction {
  progress,
  maintain,
  regress,
}

class ProgressionDecision {
  const ProgressionDecision({
    required this.action,
    required this.exercise,
    required this.value,
  });

  final ProgressionAction action;
  final Exercise exercise;
  final int value;
}

/// Motor determinista de progresión.
///
/// [decide] mantiene las reglas originales para una única sesión.
/// [decideAdaptive] añade contexto de sesiones consecutivas para evitar
/// reaccionar demasiado poco a una tendencia clara.
class ProgressionEngine {
  const ProgressionEngine();

  ProgressionDecision decide({
    required Exercise exercise,
    required int currentValue,
    required WorkoutDifficulty difficulty,
  }) {
    return _decide(
      exercise: exercise,
      currentValue: currentValue,
      difficulty: difficulty,
      consecutiveSessions: 1,
    );
  }

  ProgressionDecision decideAdaptive({
    required Exercise exercise,
    required int currentValue,
    required WorkoutDifficulty difficulty,
    int consecutiveSessions = 1,
  }) {
    final streak = consecutiveSessions.clamp(1, 5).toInt();

    return _decide(
      exercise: exercise,
      currentValue: currentValue,
      difficulty: difficulty,
      consecutiveSessions: streak,
    );
  }

  ProgressionDecision _decide({
    required Exercise exercise,
    required int currentValue,
    required WorkoutDifficulty difficulty,
    required int consecutiveSessions,
  }) {
    switch (difficulty) {
      case WorkoutDifficulty.veryEasy:
        final amount = exercise.isTimed ? 10 : 2;
        final adaptiveAmount = consecutiveSessions >= 2
            ? (amount * 1.5).round()
            : amount;
        return _progress(
          exercise: exercise,
          currentValue: currentValue,
          amount: adaptiveAmount,
        );

      case WorkoutDifficulty.easy:
        final amount = exercise.isTimed ? 5 : 1;
        final adaptiveAmount = consecutiveSessions >= 2
            ? amount * 2
            : amount;
        return _progress(
          exercise: exercise,
          currentValue: currentValue,
          amount: adaptiveAmount,
        );

      case WorkoutDifficulty.good:
        return ProgressionDecision(
          action: ProgressionAction.maintain,
          exercise: exercise,
          value: _clampValue(exercise, currentValue),
        );

      case WorkoutDifficulty.hard:
        return _regressSlightly(
          exercise: exercise,
          currentValue: currentValue,
          consecutiveSessions: consecutiveSessions,
        );

      case WorkoutDifficulty.veryHard:
        return _regressStrongly(
          exercise: exercise,
          currentValue: currentValue,
        );
    }
  }

  ProgressionDecision _progress({
    required Exercise exercise,
    required int currentValue,
    required int amount,
  }) {
    final maximum = exercise.isTimed ? 90 : exercise.maxRepetitions;
    final nextValue = currentValue + amount;

    if (nextValue <= maximum) {
      return ProgressionDecision(
        action: ProgressionAction.progress,
        exercise: exercise,
        value: nextValue,
      );
    }

    final progression = _findProgression(exercise);

    if (progression != null) {
      return ProgressionDecision(
        action: ProgressionAction.progress,
        exercise: progression,
        value: progression.isTimed
            ? progression.defaultSeconds ?? 30
            : progression.minRepetitions,
      );
    }

    return ProgressionDecision(
      action: ProgressionAction.maintain,
      exercise: exercise,
      value: maximum,
    );
  }

  ProgressionDecision _regressSlightly({
    required Exercise exercise,
    required int currentValue,
    required int consecutiveSessions,
  }) {
    final minimum = exercise.isTimed ? 10 : exercise.minRepetitions;
    final baseReduction = exercise.isTimed ? 5 : 2;
    final reduction = consecutiveSessions >= 3
        ? (baseReduction * 1.5).round()
        : baseReduction;
    final nextValue = currentValue - reduction;

    return ProgressionDecision(
      action: ProgressionAction.regress,
      exercise: exercise,
      value: nextValue < minimum ? minimum : nextValue,
    );
  }

  ProgressionDecision _regressStrongly({
    required Exercise exercise,
    required int currentValue,
  }) {
    final regression = _findRegression(exercise);

    if (regression != null) {
      return ProgressionDecision(
        action: ProgressionAction.regress,
        exercise: regression,
        value: regression.isTimed
            ? regression.defaultSeconds ?? 20
            : regression.minRepetitions,
      );
    }

    final minimum = exercise.isTimed ? 10 : exercise.minRepetitions;
    final nextValue = (currentValue * 0.75).round();

    return ProgressionDecision(
      action: ProgressionAction.regress,
      exercise: exercise,
      value: nextValue < minimum ? minimum : nextValue,
    );
  }

  Exercise? _findProgression(Exercise exercise) {
    final id = exercise.progressionId;
    if (id == null) return null;
    return _findExercise(id);
  }

  Exercise? _findRegression(Exercise exercise) {
    final id = exercise.regressionId;
    if (id == null) return null;
    return _findExercise(id);
  }

  Exercise? _findExercise(String id) {
    for (final candidate in exerciseCatalog) {
      if (candidate.id == id) {
        return candidate;
      }
    }
    return null;
  }

  int _clampValue(Exercise exercise, int value) {
    if (exercise.isTimed) {
      if (value < 10) return 10;
      if (value > 90) return 90;
      return value;
    }

    if (value < exercise.minRepetitions) return exercise.minRepetitions;
    if (value > exercise.maxRepetitions) return exercise.maxRepetitions;
    return value;
  }
}
