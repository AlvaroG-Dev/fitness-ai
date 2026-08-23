enum FitnessLevel { beginner, intermediate, advanced }

enum WorkoutDuration { ten, fifteen, twenty, thirty, fortyFivePlus }

enum Equipment { none, backpack, bands, dumbbells }

class OnboardingState {
  const OnboardingState({
    this.goals = const <String>{},
    this.level,
    this.duration,
    this.equipment = const <Equipment>{Equipment.none},
  });

  final Set<String> goals;
  final FitnessLevel? level;
  final WorkoutDuration? duration;
  final Set<Equipment> equipment;

  OnboardingState copyWith({
    Set<String>? goals,
    FitnessLevel? level,
    WorkoutDuration? duration,
    Set<Equipment>? equipment,
  }) {
    return OnboardingState(
      goals: goals ?? this.goals,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      equipment: equipment ?? this.equipment,
    );
  }
}
