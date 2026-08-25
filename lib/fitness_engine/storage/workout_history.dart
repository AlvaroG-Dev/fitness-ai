import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_feedback.dart';
import '../models/workout_result.dart';

/// Almacén persistente del historial de entrenamientos.
///
/// En producción utiliza SharedPreferences.
///
/// Para tests existe [WorkoutHistoryStore.forTesting], que utiliza
/// únicamente memoria y no requiere ningún plugin de Flutter.
class WorkoutHistoryStore extends ChangeNotifier {
  WorkoutHistoryStore._internal({
    bool inMemory = false,
  }) : _inMemory = inMemory;

  static final WorkoutHistoryStore instance =
  WorkoutHistoryStore._internal();

  /// Crea un almacén aislado para tests.
  ///
  /// No utiliza SharedPreferences ni plugins nativos.
  @visibleForTesting
  factory WorkoutHistoryStore.forTesting() {
    return WorkoutHistoryStore._internal(
      inMemory: true,
    );
  }

  static const String _storageKey =
      'fitness_ai_workout_history_v1';

  final List<WorkoutResult> _results = [];

  final bool _inMemory;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  List<WorkoutResult> get all =>
      List.unmodifiable(_results.reversed);

  int get sessionCount => _results.length;

  WorkoutResult? get latest =>
      _results.isEmpty ? null : _results.last;

  int get totalMinutes {
    var totalSeconds = 0;

    for (final result in _results) {
      totalSeconds += result.elapsedSeconds;
    }

    return totalSeconds ~/ 60;
  }

  /// Carga el historial guardado en el dispositivo.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Los almacenes de test no tienen almacenamiento persistente.
    if (_inMemory) {
      _initialized = true;
      notifyListeners();
      return;
    }

    final preferences =
    await SharedPreferences.getInstance();

    final raw = preferences.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);

        if (decoded is List) {
          _results
            ..clear()
            ..addAll(
              decoded
                  .whereType<Map>()
                  .map(
                    (item) => _workoutResultFromJson(
                  Map<String, dynamic>.from(item),
                ),
              ),
            );
        }
      } catch (_) {
        _results.clear();
      }
    }

    _initialized = true;
    notifyListeners();
  }

  /// Guarda un entrenamiento completado.
  Future<void> add(WorkoutResult result) async {
    _results.add(result);

    if (!_inMemory) {
      await _persist();
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final preferences =
    await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _results
          .map(_workoutResultToJson)
          .toList(),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
  }

  List<ExerciseResult> resultsForExercise(
      String exerciseId,
      ) {
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

  ExerciseResult? latestResultForExercise(
      String exerciseId,
      ) {
    final results =
    resultsForExercise(exerciseId);

    return results.isEmpty
        ? null
        : results.last;
  }

  /// Racha de días consecutivos.
  int get streak {
    if (_results.isEmpty) {
      return 0;
    }

    final days = _results
        .map(
          (result) => DateTime(
        result.completedAt.year,
        result.completedAt.month,
        result.completedAt.day,
      ),
    )
        .toSet();

    var cursor = DateTime.now();

    cursor = DateTime(
      cursor.year,
      cursor.month,
      cursor.day,
    );

    if (!days.contains(cursor)) {
      cursor = cursor.subtract(
        const Duration(days: 1),
      );
    }

    var count = 0;

    while (days.contains(cursor)) {
      count++;

      cursor = cursor.subtract(
        const Duration(days: 1),
      );
    }

    return count;
  }

  /// Horas desde el último entrenamiento.
  double? get hoursSinceLastSession {
    if (latest == null) {
      return null;
    }

    return DateTime.now()
        .difference(latest!.completedAt)
        .inMinutes /
        60;
  }

  /// Limpia el historial.
  @visibleForTesting
  Future<void> clear() async {
    _results.clear();

    if (!_inMemory) {
      final preferences =
      await SharedPreferences.getInstance();

      await preferences.remove(_storageKey);
    }

    notifyListeners();
  }
}

/// ------------------------------------------------------------
/// SERIALIZACIÓN
/// ------------------------------------------------------------

Map<String, dynamic> _workoutResultToJson(
    WorkoutResult result,
    ) {
  return {
    'workoutTitle': result.workoutTitle,
    'completedAt':
    result.completedAt.toIso8601String(),
    'elapsedSeconds': result.elapsedSeconds,
    'feedback': result.feedback.name,
    'exercises': result.exercises
        .map(
          (exercise) => {
        'exerciseId': exercise.exerciseId,
        'value': exercise.value,
        'feedback': exercise.feedback.name,
      },
    )
        .toList(),
  };
}

WorkoutResult _workoutResultFromJson(
    Map<String, dynamic> json,
    ) {
  final exercisesRaw =
  json['exercises'];

  final exercises = <ExerciseResult>[];

  if (exercisesRaw is List) {
    for (final raw in exercisesRaw) {
      if (raw is! Map) {
        continue;
      }

      final map =
      Map<String, dynamic>.from(raw);

      exercises.add(
        ExerciseResult(
          exerciseId:
          map['exerciseId'] as String,
          value:
          (map['value'] as num).toInt(),
          feedback:
          _difficultyFromString(
            map['feedback'] as String,
          ),
        ),
      );
    }
  }

  return WorkoutResult(
    workoutTitle:
    json['workoutTitle'] as String,
    completedAt:
    DateTime.parse(
      json['completedAt'] as String,
    ),
    elapsedSeconds:
    (json['elapsedSeconds'] as num).toInt(),
    feedback:
    _difficultyFromString(
      json['feedback'] as String,
    ),
    exercises: exercises,
  );
}

WorkoutDifficulty _difficultyFromString(
    String value,
    ) {
  return WorkoutDifficulty.values.firstWhere(
        (difficulty) =>
    difficulty.name == value,
    orElse: () =>
    WorkoutDifficulty.good,
  );
}