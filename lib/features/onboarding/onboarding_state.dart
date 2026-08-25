enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
}

enum WorkoutDuration {
  ten,
  fifteen,
  twenty,
  thirty,
  fortyFivePlus,
}

enum Equipment {
  none,
  backpack,
  bands,
  dumbbells,
}

class OnboardingState {
  const OnboardingState({
    this.goals = const <String>{},
    this.level,
    this.duration,
    this.equipment = const <Equipment>{Equipment.none},
    this.dumbbellCount = 0,
    this.dumbbellWeightKg = 0,
  });

  final Set<String> goals;

  final FitnessLevel? level;

  final WorkoutDuration? duration;

  final Set<Equipment> equipment;

  /// Número de mancuernas disponibles.
  ///
  /// Ejemplo:
  /// 2 = tienes una pareja de mancuernas.
  final int dumbbellCount;

  /// Peso de cada mancuerna en kg.
  ///
  /// Ejemplo:
  /// 10 = dos mancuernas de 10 kg cada una.
  final double dumbbellWeightKg;

  bool get hasDumbbells =>
      equipment.contains(Equipment.dumbbells) &&
          dumbbellCount > 0 &&
          dumbbellWeightKg > 0;

  OnboardingState copyWith({
    Set<String>? goals,
    FitnessLevel? level,
    WorkoutDuration? duration,
    Set<Equipment>? equipment,
    int? dumbbellCount,
    double? dumbbellWeightKg,
  }) {
    return OnboardingState(
      goals: goals ?? this.goals,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      equipment: equipment ?? this.equipment,
      dumbbellCount:
      dumbbellCount ?? this.dumbbellCount,
      dumbbellWeightKg:
      dumbbellWeightKg ?? this.dumbbellWeightKg,
    );
  }
}