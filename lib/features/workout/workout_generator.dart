import '../../fitness_engine/data/exercise_catalog.dart';
import '../../fitness_engine/models/exercise.dart';
import '../onboarding/onboarding_state.dart' as onboarding;

class WorkoutExercise {
  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.exerciseRestSeconds,
  });

  final Exercise exercise;
  final int sets;
  final int reps;
  final int restSeconds;
  final int exerciseRestSeconds;
}

class GeneratedWorkout {
  const GeneratedWorkout({required this.title, required this.exercises});

  final String title;
  final List<WorkoutExercise> exercises;
}

class WorkoutGenerator {
  const WorkoutGenerator();

  GeneratedWorkout generate(onboarding.OnboardingState profile) {
    final targetCount = switch (profile.duration) {
      onboarding.WorkoutDuration.ten => 4,
      onboarding.WorkoutDuration.fifteen => 5,
      onboarding.WorkoutDuration.twenty => 6,
      onboarding.WorkoutDuration.thirty => 8,
      onboarding.WorkoutDuration.fortyFivePlus => 10,
      null => 5,
    };

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

    final available = exerciseCatalog.where(
      (exercise) => exercise.equipment.every(allowedEquipment.contains),
    );

    final targetMuscles = <MuscleGroup>{};
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
        targetMuscles.add(muscle);
      }
    }
    if (profile.goals.contains('full_body')) {
      targetMuscles.addAll(MuscleGroup.values);
    }

    final userLevel = switch (profile.level) {
      onboarding.FitnessLevel.beginner => 1,
      onboarding.FitnessLevel.intermediate => 3,
      onboarding.FitnessLevel.advanced => 5,
      null => 2,
    };

    final candidates = available
        .where(
          (exercise) =>
              targetMuscles.isEmpty ||
              exercise.muscles.any(targetMuscles.contains),
        )
        .toList()
      ..sort(
        (a, b) => (a.level - userLevel)
            .abs()
            .compareTo((b.level - userLevel).abs()),
      );

    final selected = <Exercise>[];
    final patterns = <MovementPattern>{};
    for (final exercise in candidates) {
      if (patterns.add(exercise.pattern)) {
        selected.add(exercise);
      }
      if (selected.length == targetCount) {
        break;
      }
    }
    for (final exercise in candidates) {
      if (selected.length == targetCount) {
        break;
      }
      if (!selected.contains(exercise)) {
        selected.add(exercise);
      }
    }

    final sets = switch (profile.level) {
      onboarding.FitnessLevel.advanced => 4,
      onboarding.FitnessLevel.intermediate => 3,
      _ => 2,
    };

    return GeneratedWorkout(
      title: _title(profile),
      exercises: selected
          .map(
            (exercise) => WorkoutExercise(
              exercise: exercise,
              sets: sets,
              reps: _repsFor(exercise, userLevel),
              restSeconds: _setRestFor(exercise, userLevel),
              exerciseRestSeconds: _exerciseRestFor(exercise, userLevel),
            ),
          )
          .toList(),
    );
  }

  String _title(onboarding.OnboardingState profile) {
    if (profile.goals.contains('full_body') || profile.goals.length > 1) {
      return 'Full Body adaptado';
    }
    final goal = profile.goals.isEmpty ? null : profile.goals.first;
    return switch (goal) {
      'arms' => 'Brazos',
      'chest' => 'Pecho',
      'abs' => 'Abdominales',
      'legs' => 'Piernas',
      'back' => 'Espalda',
      _ => 'Entrenamiento de hoy',
    };
  }

  int _repsFor(Exercise exercise, int level) {
    switch (exercise.pattern) {
      case MovementPattern.core:
      case MovementPattern.cardio:
        return level <= 1 ? 20 : level <= 3 ? 30 : 40;
      case MovementPattern.mobility:
        return level <= 1 ? 8 : level <= 3 ? 10 : 12;
      default:
        return switch (level) {
          1 => exercise.level >= 3 ? 6 : 8,
          2 => 9,
          3 => 10,
          4 => 12,
          _ => 15,
        };
    }
  }

  int _setRestFor(Exercise exercise, int level) {
    if (exercise.pattern == MovementPattern.core ||
        exercise.pattern == MovementPattern.mobility) {
      return 20;
    }
    return level >= 4 ? 40 : 45;
  }

  int _exerciseRestFor(Exercise exercise, int level) {
    if (exercise.pattern == MovementPattern.cardio) {
      return 30;
    }
    return level <= 1 ? 60 : 45;
  }
}
