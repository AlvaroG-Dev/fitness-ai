enum ExerciseMetric {
  repetitions,
  seconds,
}

enum Equipment {
  none,
  backpack,
  resistanceBand,
  dumbbells,
}

enum MuscleGroup {
  arms,
  chest,
  abs,
  legs,
  back,
  shoulders,
  glutes,
}

enum MovementPattern {
  push,
  pull,
  squat,
  hinge,
  lunge,
  core,
  cardio,
  mobility,
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscles,
    required this.equipment,
    required this.pattern,
    required this.level,
    required this.metric,
    this.defaultSeconds,
    this.minRepetitions = 6,
    this.maxRepetitions = 20,
    this.progressionId,
    this.regressionId,
  });

  final String id;
  final String name;
  final String description;

  final Set<MuscleGroup> muscles;
  final Set<Equipment> equipment;

  final MovementPattern pattern;

  /// Dificultad del ejercicio de 1 a 5.
  final int level;

  /// Indica si el ejercicio se prescribe por repeticiones
  /// o por tiempo.
  final ExerciseMetric metric;

  /// Duración base para ejercicios medidos por tiempo.
  final int? defaultSeconds;

  /// Límites para ejercicios medidos por repeticiones.
  final int minRepetitions;
  final int maxRepetitions;

  /// Ejercicio inmediatamente más difícil.
  ///
  /// Ejemplo:
  ///
  /// flexiones inclinadas -> flexiones
  final String? progressionId;

  /// Ejercicio inmediatamente más fácil.
  ///
  /// Ejemplo:
  ///
  /// flexiones -> flexiones inclinadas
  final String? regressionId;

  bool get isTimed => metric == ExerciseMetric.seconds;

  bool get isRepetitionBased =>
      metric == ExerciseMetric.repetitions;
}