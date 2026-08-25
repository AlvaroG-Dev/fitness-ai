import 'package:flutter/foundation.dart';

import '../models/workout_result.dart';

/// Almacén único del historial de entrenamientos completados.
///
/// Es un [ChangeNotifier] para que la UI (progreso, avisos de
/// recuperación...) pueda reaccionar automáticamente cuando se
/// guarda una sesión nueva.
///
/// NOTA: por ahora vive solo en memoria (se pierde al cerrar la
/// app). Cuando quieras persistencia real, este es el único sitio
/// que hay que tocar: envolver `_results` con algo como
/// `shared_preferences` o una base de datos local (por ejemplo
/// `sqflite` o `drift`), serializando/deserializando [WorkoutResult].
class WorkoutHistoryStore extends ChangeNotifier {
  WorkoutHistoryStore._internal();

  static final WorkoutHistoryStore instance =
      WorkoutHistoryStore._internal();

  final List<WorkoutResult> _results = [];

  List<WorkoutResult> get all => List.unmodifiable(_results.reversed);

  int get sessionCount => _results.length;

  int get totalMinutes {
    var totalSeconds = 0;
    for (final result in _results) {
      totalSeconds += result.elapsedSeconds;
    }
    return totalSeconds ~/ 60;
  }

  WorkoutResult? get latest => _results.isEmpty ? null : _results.last;

  void add(WorkoutResult result) {
    _results.add(result);
    notifyListeners();
  }

  List<ExerciseResult> resultsForExercise(String exerciseId) {
    final results = <ExerciseResult>[];

    for (final workout in _results) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == exerciseId) {
          results.add(exercise);
        }
      }
    }

    return List.unmodifiable(results);
  }

  ExerciseResult? latestResultForExercise(String exerciseId) {
    final results = resultsForExercise(exerciseId);
    return results.isEmpty ? null : results.last;
  }

  /// Racha de días consecutivos (incluyendo hoy o ayer) con al
  /// menos una sesión completada.
  int get streak {
    if (_results.isEmpty) return 0;

    final days = _results
        .map((r) => DateTime(
              r.completedAt.year,
              r.completedAt.month,
              r.completedAt.day,
            ))
        .toSet();

    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return count;
  }

  /// Horas transcurridas desde el fin de la última sesión.
  /// Útil para avisos de recuperación (ver [fitness_engine/insights]).
  double? get hoursSinceLastSession {
    if (latest == null) return null;
    return DateTime.now().difference(latest!.completedAt).inMinutes / 60;
  }

  @visibleForTesting
  void clear() {
    _results.clear();
    notifyListeners();
  }
}
