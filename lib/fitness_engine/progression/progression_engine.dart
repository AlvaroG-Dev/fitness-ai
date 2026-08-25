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

  /// Repeticiones si el ejercicio es por reps.
  /// Segundos si el ejercicio es por tiempo.
  final int value;
}

/// El Motor: reglas deterministas de progresión de carga.
///
/// Dada la dificultad percibida en la última sesión, decide si el
/// usuario debe subir, mantener o bajar el estímulo del ejercicio,
/// y si conviene cambiar de variante (más o menos exigente) dentro
/// de la misma cadena de progresión/regresión.
///
/// Esto es intencionadamente "tonto": no interpreta tendencias ni
/// historial, solo aplica una regla fija a partir del último dato.
/// El análisis de tendencias a lo largo de varias sesiones vive en
/// la capa de insights (fitness_engine/insights), que se apoya en
/// este motor pero no lo sustituye.
class ProgressionEngine {
  const ProgressionEngine();

  ProgressionDecision decide({
    required Exercise exercise,
    required int currentValue,
    required WorkoutDifficulty difficulty,
  }) {
    switch (difficulty) {
      case WorkoutDifficulty.veryEasy:
        return _progress(
          exercise: exercise,
          currentValue: currentValue,
          amount: exercise.isTimed ? 10 : 2,
        );

      case WorkoutDifficulty.easy:
        return _progress(
          exercise: exercise,
          currentValue: currentValue,
          amount: exercise.isTimed ? 5 : 1,
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
  }) {
    final minimum = exercise.isTimed ? 10 : exercise.minRepetitions;
    final reduction = exercise.isTimed ? 5 : 2;
    final nextValue = currentValue - reduction;

    return ProgressionDecision(
      action: ProgressionAction.maintain,
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
