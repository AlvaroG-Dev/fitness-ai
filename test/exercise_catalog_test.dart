import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_ai/fitness_engine/data/exercise_catalog.dart';

void main() {
  test('catalog contains unique exercise ids', () {
    final ids = exerciseCatalog.map((exercise) => exercise.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('all progression and regression references exist', () {
    final ids = exerciseCatalog.map((exercise) => exercise.id).toSet();

    for (final exercise in exerciseCatalog) {
      expect(exercise.regressionId == null || ids.contains(exercise.regressionId), isTrue);
      expect(exercise.progressionId == null || ids.contains(exercise.progressionId), isTrue);
    }
  });
}
