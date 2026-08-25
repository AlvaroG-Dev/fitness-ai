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

/// Rol del ejercicio dentro de una sesión.
///
/// Es independiente del [MovementPattern]: un ejercicio de movilidad
/// puede ser calentamiento o enfriamiento, y eso determina en qué
/// bloque de la sesión puede aparecer.
///
/// Esto evita el error de usar ejercicios "de trabajo" (con
/// intensidad real) como si fueran calentamiento, que es una causa
/// habitual de lesiones por empezar la sesión en frío.
enum ExerciseRole {
  warmup,
  main,
  cooldown,
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.cue,
    required this.muscles,
    required this.equipment,
    required this.pattern,
    required this.level,
    required this.metric,
    this.role = ExerciseRole.main,
    this.highImpact = false,
    this.defaultSeconds,
    this.minRepetitions = 6,
    this.maxRepetitions = 20,
    this.progressionId,
    this.regressionId,
  });

  final String id;
  final String name;
  final String description;

  /// Indicación técnica breve mostrada durante la ejecución.
  /// Sirve para reducir el riesgo de mala ejecución/lesión.
  final String cue;

  final Set<MuscleGroup> muscles;
  final Set<Equipment> equipment;

  final MovementPattern pattern;
  final ExerciseRole role;

  /// Dificultad del ejercicio de 1 a 5.
  final int level;

  /// Indica si el ejercicio se prescribe por repeticiones
  /// o por tiempo.
  final ExerciseMetric metric;

  /// Ejercicios con impacto (saltos) exigen más cuidado en la
  /// planificación: no deben acumularse sin descanso ni asignarse
  /// en exceso a principiantes.
  final bool highImpact;

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
