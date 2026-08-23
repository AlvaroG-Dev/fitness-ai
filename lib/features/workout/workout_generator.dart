import '../../fitness_engine/data/exercise_catalog.dart';
import '../../fitness_engine/models/exercise.dart';
import '../onboarding/onboarding_state.dart';

class GeneratedWorkout {
  const GeneratedWorkout({required this.title, required this.exercises});

  final String title;
  final List<Exercise> exercises;
}

class WorkoutGenerator {
  const WorkoutGenerator();

  GeneratedWorkout generate(OnboardingState profile) {
    final targetCount = switch (profile.duration) {
      WorkoutDuration.ten => 4,
      WorkoutDuration.fifteen => 5,
      WorkoutDuration.twenty => 6,
      WorkoutDuration.thirty => 8,
      WorkoutDuration.fortyFivePlus => 10,
      null => 5,
    };

    final available = exerciseCatalog.where((exercise) {
      if (profile.equipment.contains(Equipment.none)) {
        return exercise.equipment.isEmpty;
      }
      return exercise.equipment.every(
        (item) => profile.equipment.any((equipment) => equipment.name == item),
      );
    }).toList();

    final goalKeywords = <String>{
      ...profile.goals,
      if (profile.goals.contains('full_body')) 'arms',
      if (profile.goals.contains('full_body')) 'chest',
      if (profile.goals.contains('full_body')) 'abs',
      if (profile.goals.contains('full_body')) 'legs',
      if (profile.goals.contains('full_body')) 'back',
    };

    final selected = <Exercise>[];
    for (final exercise in available) {
      if (exercise.muscleGroups.any(goalKeywords.contains)) {
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
