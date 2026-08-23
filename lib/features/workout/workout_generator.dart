import '../../fitness_engine/data/exercise_catalog.dart';
import '../../fitness_engine/models/exercise.dart';
import '../onboarding/onboarding_state.dart' as onboarding;

class GeneratedWorkout {
  const GeneratedWorkout({required this.title, required this.exercises});

  final String title;
  final List<Exercise> exercises;
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
      if (muscle != null) targetMuscles.add(muscle);
    }
    if (profile.goals.contains('full_body')) {
      targetMuscles.addAll(MuscleGroup.values);
    }

    final selected = <Exercise>[];
    for (final exercise in available) {
      if (exercise.muscles.any(targetMuscles.contains)) {
        selected.add(exercise);
      }
      if (selected.length == targetCount) break;
    }

    if (selected.length < targetCount) {
      for (final exercise in available) {
        if (!selected.contains(exercise)) selected.add(exercise);
        if (selected.length == targetCount) break;
      }
    }

    return GeneratedWorkout(
      title: 'Entrenamiento de hoy',
      exercises: selected,
    );
  }
}
