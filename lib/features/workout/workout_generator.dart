import '../../fitness_engine/data/exercise_catalog.dart';
import '../../fitness_engine/models/exercise.dart';
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

        if (round < block.rounds - 1 &&
            block.restBetweenRounds > 0) {
          result.add(
            WorkoutStep.rest(
              seconds: block.restBetweenRounds,
            ),
          );
        }
      }
    }

    return result;
  }

  int get exerciseCount {
    return steps
        .where((step) => step.type != WorkoutStepType.rest)
        .length;
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

class WorkoutGenerator {
  const WorkoutGenerator();

  GeneratedWorkout generate(
      onboarding.OnboardingState profile,
      ) {
    final targetCount = _exerciseCount(profile.duration);

    final allowedEquipment = <Equipment>{
      Equipment.none,
    };

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

    final candidates = exerciseCatalog
        .where(
          (exercise) => exercise.equipment.every(
        allowedEquipment.contains,
      ),
    )
        .where(
          (exercise) =>
      targetMuscles.isEmpty ||
          exercise.muscles.any(targetMuscles.contains),
    )
        .toList()
      ..sort(
            (a, b) {
          final aDistance = (a.level - userLevel).abs();
          final bDistance = (b.level - userLevel).abs();

          return aDistance.compareTo(bDistance);
        },
      );

    final selected = _selectExercises(
      candidates,
      targetCount,
    );

    if (selected.isEmpty) {
      return const GeneratedWorkout(
        title: 'Entrenamiento',
        blocks: [],
      );
    }

    final warmup = _createWarmup(
      selected,
      userLevel,
    );

    final main = _createMainBlock(
      selected,
      profile,
      userLevel,
    );

    final finisher = _createFinisher(
      selected,
      profile,
    );

    final cooldown = _createCooldown(
      selected,
    );

    return GeneratedWorkout(
      title: _workoutTitle(profile),
      blocks: [
        if (warmup != null) warmup,
        main,
        if (finisher != null) finisher,
        if (cooldown != null) cooldown,
      ],
    );
  }

  int _exerciseCount(
      onboarding.WorkoutDuration? duration,
      ) {
    return switch (duration) {
      onboarding.WorkoutDuration.ten => 4,
      onboarding.WorkoutDuration.fifteen => 5,
      onboarding.WorkoutDuration.twenty => 6,
      onboarding.WorkoutDuration.thirty => 8,
      onboarding.WorkoutDuration.fortyFivePlus => 10,
      null => 5,
    };
  }

  int _userLevel(
      onboarding.OnboardingState profile,
      ) {
    return switch (profile.level) {
      onboarding.FitnessLevel.beginner => 1,
      onboarding.FitnessLevel.intermediate => 3,
      onboarding.FitnessLevel.advanced => 5,
      null => 2,
    };
  }

  Set<MuscleGroup> _targetMuscles(
      onboarding.OnboardingState profile,
      ) {
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

  List<Exercise> _selectExercises(
      List<Exercise> candidates,
      int count,
      ) {
    final selected = <Exercise>[];
    final patterns = <MovementPattern>{};

    for (final exercise in candidates) {
      if (patterns.add(exercise.pattern)) {
        selected.add(exercise);
      }

      if (selected.length == count) {
        break;
      }
    }

    for (final exercise in candidates) {
      if (selected.length == count) {
        break;
      }

      if (!selected.contains(exercise)) {
        selected.add(exercise);
      }
    }

    return selected;
  }

  WorkoutBlock? _createWarmup(
      List<Exercise> exercises,
      int level,
      ) {
    if (exercises.isEmpty) {
      return null;
    }

    final count = exercises.length >= 3
        ? 3
        : exercises.length;

    return WorkoutBlock(
      title: 'Calentamiento',
      type: WorkoutBlockType.warmup,
      rounds: 1,
      steps: [
        for (final exercise in exercises.take(count))
          if (exercise.isTimed)
            WorkoutStep.timed(
              exercise: exercise,
              seconds: _exerciseSeconds(
                exercise,
                level,
              ),
            )
          else
            WorkoutStep.reps(
              exercise: exercise,
              repetitions: 6,
            ),
      ],
      restBetweenRounds: 0,
    );
  }

  WorkoutBlock _createMainBlock(
      List<Exercise> exercises,
      onboarding.OnboardingState profile,
      int level,
      ) {
    final rounds = switch (profile.level) {
      onboarding.FitnessLevel.beginner => 2,
      onboarding.FitnessLevel.intermediate => 3,
      onboarding.FitnessLevel.advanced => 3,
      null => 2,
    };

    final useCircuit =
        exercises.length >= 4 &&
            profile.duration != onboarding.WorkoutDuration.ten;

    final steps = <WorkoutStep>[];

    for (final exercise in exercises) {
      if (exercise.isTimed) {
        steps.add(
          WorkoutStep.timed(
            exercise: exercise,
            seconds: _exerciseSeconds(
              exercise,
              level,
            ),
          ),
        );
      } else {
        steps.add(
          WorkoutStep.reps(
            exercise: exercise,
            repetitions: _repetitions(
              exercise,
              level,
            ),
          ),
        );
      }
    }

    return WorkoutBlock(
      title: useCircuit
          ? 'Circuito principal'
          : 'Bloque principal',
      type: useCircuit
          ? WorkoutBlockType.circuit
          : WorkoutBlockType.strength,
      rounds: rounds,
      steps: steps,
      restBetweenRounds: _roundRest(profile),
    );
  }

  WorkoutBlock? _createFinisher(
      List<Exercise> exercises,
      onboarding.OnboardingState profile,
      ) {
    if (profile.duration == onboarding.WorkoutDuration.ten) {
      return null;
    }

    if (exercises.length < 3) {
      return null;
    }

    final selected = exercises.last;

    return WorkoutBlock(
      title: 'Finisher',
      type: WorkoutBlockType.finisher,
      rounds: 1,
      steps: [
        if (selected.isTimed)
          WorkoutStep.timed(
            exercise: selected,
            seconds: _exerciseSeconds(
              selected,
              _userLevel(profile),
            ),
          )
        else
          WorkoutStep.reps(
            exercise: selected,
            repetitions: _repetitions(
              selected,
              _userLevel(profile),
            ),
          ),
      ],
      restBetweenRounds: 0,
    );
  }

  WorkoutBlock? _createCooldown(
      List<Exercise> exercises,
      ) {
    if (exercises.isEmpty) {
      return null;
    }

    return WorkoutBlock(
      title: 'Recuperación',
      type: WorkoutBlockType.cooldown,
      rounds: 1,
      steps: [
        WorkoutStep.timed(
          exercise: exercises.first,
          seconds: 30,
        ),
      ],
      restBetweenRounds: 0,
    );
  }

  int _exerciseSeconds(
      Exercise exercise,
      int level,
      ) {
    final base = exercise.defaultSeconds ?? 30;

    final multiplier = switch (level) {
      1 => 0.75,
      2 => 0.85,
      3 => 1.0,
      4 => 1.10,
      _ => 1.20,
    };

    final result = (base * multiplier).round();

    if (result < 10) {
      return 10;
    }

    if (result > 90) {
      return 90;
    }

    return result;
  }

  int _repetitions(
      Exercise exercise,
      int level,
      ) {
    final adjustment = switch (level) {
      1 => -2,
      2 => -1,
      3 => 0,
      4 => 2,
      _ => 3,
    };

    var result = 10 + adjustment;

    if (result < exercise.minRepetitions) {
      result = exercise.minRepetitions;
    }

    if (result > exercise.maxRepetitions) {
      result = exercise.maxRepetitions;
    }

    return result;
  }

  int _roundRest(
      onboarding.OnboardingState profile,
      ) {
    return switch (profile.level) {
      onboarding.FitnessLevel.beginner => 60,
      onboarding.FitnessLevel.intermediate => 45,
      onboarding.FitnessLevel.advanced => 35,
      null => 60,
    };
  }

  String _workoutTitle(
      onboarding.OnboardingState profile,
      ) {
    if (profile.goals.contains('full_body')) {
      return 'Full Body adaptado';
    }

    if (profile.goals.length > 1) {
      return 'Entrenamiento completo';
    }

    if (profile.goals.contains('arms')) {
      return 'Brazos';
    }

    if (profile.goals.contains('chest')) {
      return 'Pecho';
    }

    if (profile.goals.contains('abs')) {
      return 'Abdominales';
    }

    if (profile.goals.contains('legs')) {
      return 'Piernas';
    }

    if (profile.goals.contains('back')) {
      return 'Espalda';
    }

    return 'Entrenamiento de hoy';
  }
}