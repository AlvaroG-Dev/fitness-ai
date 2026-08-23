enum MuscleGroup { arms, chest, abs, legs, back }

enum Equipment { none, backpack, resistanceBand, dumbbells, pullUpBar }

enum MovementPattern { push, pull, squat, hinge, lunge, core, cardio, mobility }

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscles,
    required this.pattern,
    required this.level,
    this.equipment = const {Equipment.none},
    this.regressionId,
    this.progressionId,
  });

  final String id;
  final String name;
  final Set<MuscleGroup> muscles;
  final MovementPattern pattern;
  final int level;
  final Set<Equipment> equipment;
  final String? regressionId;
  final String? progressionId;
}
