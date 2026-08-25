import 'dart:math';

import '../../fitness_engine/data/exercise_catalog.dart';
import '../../fitness_engine/models/exercise.dart';
import '../../fitness_engine/storage/progress_repository.dart';
import '../onboarding/onboarding_state.dart' as onboarding;

enum WorkoutBlockType {
  warmup,
  strength,
  circuit,
  superset,
  core,
  finisher,
  cooldown,
}

enum WorkoutStepType {
  reps,
  timed,
  rest,
}

class WorkoutStep {
  const WorkoutStep.reps({
    required this.exercise,
    required this.repetitions,
  })  : type = WorkoutStepType.reps,
        seconds = null;

  const WorkoutStep.timed({
    required this.exercise,
    required this.seconds,
  })  : type = WorkoutStepType.timed,
        repetitions = null;

  const WorkoutStep.rest({
    required this.seconds,
  })  : type = WorkoutStepType.rest,
        exercise = null,
        repetitions = null;

  final WorkoutStepType type;
  final Exercise? exercise;
  final int? repetitions;
  final int? seconds;
}

class WorkoutBlock {
  const WorkoutBlock({
    required this.title,
    required this.type,
    required this.steps,
    this.rounds = 1,
    this.restBetweenRounds = 45,
  });

  final String title;
  final WorkoutBlockType type;
  final List<WorkoutStep> steps;
  final int rounds;
  final int restBetweenRounds;
}

class GeneratedWorkout {
  const GeneratedWorkout({
    required this.title,
    required this.blocks,
  });

  final String title;
  final List<WorkoutBlock> blocks;

  List<WorkoutStep> get steps {
    final result = <WorkoutStep>[];

    for (final block in blocks) {
      for (var round = 0; round < block.rounds; round++) {
        result.addAll(block.steps);

        if (round < block.rounds - 1 && block.restBetweenRounds > 0) {
          result.add(WorkoutStep.rest(seconds: block.restBetweenRounds));
        }
      }
    }

    return result;
  }

  int get exerciseCount {
    return steps.where((step) => step.type != WorkoutStepType.rest).length;
  }

  int get totalSeconds {
    var total = 0;

    for (final step in steps) {
      if (step.type == WorkoutStepType.timed) {
        total += step.seconds ?? 0;
      }

      if (step.type == WorkoutStepType.rest) {
        total += step.seconds ?? 0;
      }

      if (step.type == WorkoutStepType.reps) {
        total += 35;
      }
    }

    return total;
  }
}

/// El Motor: genera un entrenamiento completo y seguro a partir del
/// perfil del usuario y, si está disponible, de su progreso.
///
/// Reglas de seguridad que aplica siempre, sin excepción:
///  - Toda sesión con al menos un ejercicio principal lleva
///    calentamiento real (movilidad/activación) y enfriamiento real
///    (estiramientos), nunca ejercicios de trabajo reciclados.
///  - Los ejercicios se filtran para que su nivel no se aleje
///    demasiado del nivel del usuario (nunca se cuela un ejercicio
///    avanzado en una sesión de principiante solo porque el catálogo
///    esté corto de opciones).
///  - Los ejercicios de impacto (saltos) se limitan según el nivel,
///    para no acumular estrés articular innecesario en una sesión.
class WorkoutGenerator {
  const WorkoutGenerator();

  GeneratedWorkout generate(
    onboarding.OnboardingState profile, {
    ProgressRepository? progress,
  }) {
    final targetCount = _exerciseCount(profile.duration);

    final allowedEquipment = <Equipment>{Equipment.none};

    if (profile.equipment.contains(onboarding.Equipment.backpack)) {
      allowedEquipment.add(Equipment.backpack);
    }
    if (profile.equipment.contains(onboarding.Equipment.bands)) {
      allowedEquipment.add(Equipment.resistanceBand);
    }
    if (profile.equipment.contains(onboarding.Equipment.dumbbells)) {
      allowedEquipment.add(Equipment.dumbbells);
    }

    final targetMuscles = _targetMuscles(profile);
    final userLevel = _userLevel(profile);
    final maxLevelGap = _maxLevelGap(profile.level);
    final maxHighImpact = _maxHighImpact(profile.level);

    var candidates = exerciseCatalog
        .where((exercise) => exercise.role == ExerciseRole.main)
        .where(
          (exercise) => exercise.equipment.every(allowedEquipment.contains),
        )
        .where(
          (exercise) =>
              targetMuscles.isEmpty ||
              exercise.muscles.any(targetMuscles.contains),
        )
        .where(
          (exercise) => (exercise.level - userLevel).abs() <= maxLevelGap,
        )
        .toList();

    // Ordena por cercanía de nivel, pero baraja ligeramente los
    // empates para que sesiones consecutivas no sean siempre
    // idénticas: la variedad ayuda a la adherencia y evita el
    // estancamiento por repetir siempre el mismo patrón exacto.
    candidates = _stableShuffleByLevelDistance(candidates, userLevel);

    var selected = _selectExercises(candidates, targetCount);
    selected = _capHighImpact(selected, candidates, maxHighImpact);

    if (selected.isEmpty) {
      return const GeneratedWorkout(title: 'Entrenamiento', blocks: []);
    }

    final resolved = [
      for (final exercise in selected) _resolve(exercise, userLevel, progress),
    ];

    final warmup = _createWarmup(resolved, targetMuscles);
    final main = _createMainBlock(resolved, profile);
    final finisher = _createFinisher(resolved, profile);
    final cooldown = _createCooldown(resolved, targetMuscles);

    return GeneratedWorkout(
      title: _workoutTitle(profile),
      blocks: [
        warmup,
        main,
        if (finisher != null) finisher,
        cooldown,
      ],
    );
  }

  // ------------------------------------------------------------
  // Resolución de carga: usa el progreso guardado si existe,
  // y si no, calcula un valor de partida razonable según nivel.
  // ------------------------------------------------------------

  _ResolvedExercise _resolve(
    Exercise exercise,
    int userLevel,
    ProgressRepository? progress,
  ) {
    final suggestion = progress?.getExerciseProgress(exercise.id);

    if (suggestion == null) {
      return _ResolvedExercise(
        exercise: exercise,
        value: exercise.isTimed
            ? _exerciseSeconds(exercise, userLevel)
            : _repetitions(exercise, userLevel),
      );
    }

    // La progresión puede sugerir una variante distinta (más o
    // menos exigente) dentro de la misma cadena.
    final nextExercise = exerciseCatalog.firstWhere(
      (candidate) => candidate.id == suggestion.exerciseId,
      orElse: () => exercise,
    );

    return _ResolvedExercise(exercise: nextExercise, value: suggestion.currentValue);
  }

  // ------------------------------------------------------------
  // Selección de ejercicios principales
  // ------------------------------------------------------------

  int _exerciseCount(onboarding.WorkoutDuration? duration) {
    return switch (duration) {
      onboarding.WorkoutDuration.ten => 4,
      onboarding.WorkoutDuration.fifteen => 5,
      onboarding.WorkoutDuration.twenty => 6,
      onboarding.WorkoutDuration.thirty => 8,
      onboarding.WorkoutDuration.fortyFivePlus => 10,
      null => 5,
    };
  }

  int _userLevel(onboarding.OnboardingState profile) {
    return switch (profile.level) {
      onboarding.FitnessLevel.beginner => 1,
      onboarding.FitnessLevel.intermediate => 3,
      onboarding.FitnessLevel.advanced => 5,
      null => 2,
    };
  }

  /// Cuánto puede alejarse el nivel de un ejercicio del nivel del
  /// usuario. Los principiantes tienen el margen más estrecho: es
  /// la protección clave contra recibir ejercicios demasiado
  /// avanzados para su condición física.
  int _maxLevelGap(onboarding.FitnessLevel? level) {
    return switch (level) {
      onboarding.FitnessLevel.beginner => 1,
      onboarding.FitnessLevel.intermediate => 2,
      onboarding.FitnessLevel.advanced => 3,
      null => 1,
    };
  }

  int _maxHighImpact(onboarding.FitnessLevel? level) {
    return switch (level) {
      onboarding.FitnessLevel.beginner => 0,
      onboarding.FitnessLevel.intermediate => 2,
      onboarding.FitnessLevel.advanced => 3,
      null => 0,
    };
  }

  Set<MuscleGroup> _targetMuscles(onboarding.OnboardingState profile) {
    final result = <MuscleGroup>{};

    for (final goal in profile.goals) {
      final muscle = switch (goal) {
        'arms' => MuscleGroup.arms,
        'chest' => MuscleGroup.chest,
        'abs' => MuscleGroup.abs,
        'legs' => MuscleGroup.legs,
        'back' => MuscleGroup.back,
        'full_body' => null,
        _ => null,
      };

      if (muscle != null) {
        result.add(muscle);
      }
    }

    if (profile.goals.contains('full_body')) {
      result.addAll(MuscleGroup.values);
    }

    return result;
  }

  List<Exercise> _stableShuffleByLevelDistance(
    List<Exercise> candidates,
    int userLevel,
  ) {
    final random = Random();
    final grouped = <int, List<Exercise>>{};

    for (final exercise in candidates) {
      final distance = (exercise.level - userLevel).abs();
      grouped.putIfAbsent(distance, () => []).add(exercise);
    }

    final distances = grouped.keys.toList()..sort();
    final result = <Exercise>[];

    for (final distance in distances) {
      final group = grouped[distance]!..shuffle(random);
      result.addAll(group);
    }

    return result;
  }

  List<Exercise> _selectExercises(List<Exercise> candidates, int count) {
    final selected = <Exercise>[];
    final patterns = <MovementPattern>{};

    for (final exercise in candidates) {
      if (patterns.add(exercise.pattern)) {
        selected.add(exercise);
      }
      if (selected.length == count) break;
    }

    for (final exercise in candidates) {
      if (selected.length == count) break;
      if (!selected.contains(exercise)) {
        selected.add(exercise);
      }
    }

    return selected;
  }

  /// Sustituye el exceso de ejercicios de impacto por alternativas
  /// de bajo impacto del mismo patrón cuando es posible, para no
  /// sobrecargar articulaciones en una sola sesión.
  List<Exercise> _capHighImpact(
    List<Exercise> selected,
    List<Exercise> candidates,
    int maxHighImpact,
  ) {
    final highImpactCount = selected.where((e) => e.highImpact).length;
    if (highImpactCount <= maxHighImpact) {
      return selected;
    }

    final result = List<Exercise>.from(selected);
    var excess = highImpactCount - maxHighImpact;

    for (var i = 0; i < result.length && excess > 0; i++) {
      if (!result[i].highImpact) continue;

      final replacement = candidates.firstWhere(
        (candidate) =>
            !candidate.highImpact &&
            !result.contains(candidate) &&
            candidate.pattern == result[i].pattern,
        orElse: () => result[i],
      );

      if (replacement.id != result[i].id) {
        result[i] = replacement;
        excess--;
      }
    }

    return result;
  }

  // ------------------------------------------------------------
  // Bloques
  // ------------------------------------------------------------

  WorkoutBlock _createWarmup(
    List<_ResolvedExercise> selected,
    Set<MuscleGroup> targetMuscles,
  ) {
    final pool = exerciseCatalog
        .where((exercise) => exercise.role == ExerciseRole.warmup)
        .toList();

    final relevant = pool
        .where((exercise) => exercise.muscles.any(targetMuscles.contains))
        .toList();
    final general = pool.where((e) => !relevant.contains(e)).toList();

    final chosen = <Exercise>[];

    // Siempre eleva pulsaciones de forma progresiva antes de nada.
    final cardio = pool.firstWhere(
      (e) => e.pattern == MovementPattern.cardio,
      orElse: () => pool.first,
    );
    chosen.add(cardio);

    for (final exercise in [...relevant, ...general]) {
      if (chosen.length >= 3) break;
      if (!chosen.contains(exercise)) chosen.add(exercise);
    }

    return WorkoutBlock(
      title: 'Calentamiento',
      type: WorkoutBlockType.warmup,
      rounds: 1,
      restBetweenRounds: 0,
      steps: [
        for (final exercise in chosen)
          if (exercise.isTimed)
            WorkoutStep.timed(
              exercise: exercise,
              seconds: exercise.defaultSeconds ?? 25,
            )
          else
            WorkoutStep.reps(
              exercise: exercise,
              repetitions: exercise.minRepetitions,
            ),
      ],
    );
  }

  WorkoutBlock _createMainBlock(
    List<_ResolvedExercise> resolved,
    onboarding.OnboardingState profile,
  ) {
    final rounds = switch (profile.level) {
      onboarding.FitnessLevel.beginner => 2,
      onboarding.FitnessLevel.intermediate => 3,
      onboarding.FitnessLevel.advanced => 3,
      null => 2,
    };

    final useCircuit = resolved.length >= 4 &&
        profile.duration != onboarding.WorkoutDuration.ten;

    final steps = <WorkoutStep>[
      for (final item in resolved)
        if (item.exercise.isTimed)
          WorkoutStep.timed(exercise: item.exercise, seconds: item.value)
        else
          WorkoutStep.reps(exercise: item.exercise, repetitions: item.value),
    ];

    return WorkoutBlock(
      title: useCircuit ? 'Circuito principal' : 'Bloque principal',
      type: useCircuit ? WorkoutBlockType.circuit : WorkoutBlockType.strength,
      rounds: rounds,
      steps: steps,
      restBetweenRounds: _roundRest(profile),
    );
  }

  WorkoutBlock? _createFinisher(
    List<_ResolvedExercise> resolved,
    onboarding.OnboardingState profile,
  ) {
    if (profile.duration == onboarding.WorkoutDuration.ten) return null;
    if (profile.level == onboarding.FitnessLevel.beginner) return null;
    if (resolved.length < 3) return null;

    // Evita cerrar con un ejercicio de impacto: el finisher ya
    // exige lo suficiente sin sumarle riesgo de aterrizaje con
    // fatiga acumulada.
    final candidates = resolved.where((r) => !r.exercise.highImpact).toList();
    if (candidates.isEmpty) return null;

    final item = candidates.last;

    return WorkoutBlock(
      title: 'Finisher',
      type: WorkoutBlockType.finisher,
      rounds: 1,
      restBetweenRounds: 0,
      steps: [
        if (item.exercise.isTimed)
          WorkoutStep.timed(exercise: item.exercise, seconds: item.value)
        else
          WorkoutStep.reps(exercise: item.exercise, repetitions: item.value),
      ],
    );
  }

  WorkoutBlock _createCooldown(
    List<_ResolvedExercise> resolved,
    Set<MuscleGroup> targetMuscles,
  ) {
    final pool = exerciseCatalog
        .where((exercise) => exercise.role == ExerciseRole.cooldown)
        .toList();

    final relevant = pool
        .where((exercise) => exercise.muscles.any(targetMuscles.contains))
        .toList();
    final general = pool.where((e) => !relevant.contains(e)).toList();

    final chosen = <Exercise>[];
    for (final exercise in [...relevant, ...general]) {
      if (chosen.length >= 2) break;
      chosen.add(exercise);
    }

    if (chosen.isEmpty && pool.isNotEmpty) {
      chosen.add(pool.first);
    }

    return WorkoutBlock(
      title: 'Recuperación',
      type: WorkoutBlockType.cooldown,
      rounds: 1,
      restBetweenRounds: 0,
      steps: [
        for (final exercise in chosen)
          WorkoutStep.timed(
            exercise: exercise,
            seconds: exercise.defaultSeconds ?? 25,
          ),
      ],
    );
  }

  int _exerciseSeconds(Exercise exercise, int level) {
    final base = exercise.defaultSeconds ?? 30;

    final multiplier = switch (level) {
      1 => 0.75,
      2 => 0.85,
      3 => 1.0,
      4 => 1.10,
      _ => 1.20,
    };

    final result = (base * multiplier).round();

    if (result < 10) return 10;
    if (result > 90) return 90;
    return result;
  }

  int _repetitions(Exercise exercise, int level) {
    final adjustment = switch (level) {
      1 => -2,
      2 => -1,
      3 => 0,
      4 => 2,
      _ => 3,
    };

    var result = 10 + adjustment;

    if (result < exercise.minRepetitions) result = exercise.minRepetitions;
    if (result > exercise.maxRepetitions) result = exercise.maxRepetitions;

    return result;
  }

  int _roundRest(onboarding.OnboardingState profile) {
    return switch (profile.level) {
      onboarding.FitnessLevel.beginner => 60,
      onboarding.FitnessLevel.intermediate => 45,
      onboarding.FitnessLevel.advanced => 35,
      null => 60,
    };
  }

  String _workoutTitle(onboarding.OnboardingState profile) {
    if (profile.goals.contains('full_body')) return 'Full Body adaptado';
    if (profile.goals.length > 1) return 'Entrenamiento completo';
    if (profile.goals.contains('arms')) return 'Brazos';
    if (profile.goals.contains('chest')) return 'Pecho';
    if (profile.goals.contains('abs')) return 'Abdominales';
    if (profile.goals.contains('legs')) return 'Piernas';
    if (profile.goals.contains('back')) return 'Espalda';
    return 'Entrenamiento de hoy';
  }
}

class _ResolvedExercise {
  const _ResolvedExercise({required this.exercise, required this.value});

  final Exercise exercise;
  final int value;
}
