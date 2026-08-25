import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_state.dart';

class OnboardingStore {
  const OnboardingStore();

  static const String _profileKey =
      'fitness_ai_onboarding_profile_v1';

  static const String _completedKey =
      'fitness_ai_onboarding_completed_v1';

  Future<bool> isCompleted() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getBool(_completedKey) ?? false;
  }

  Future<OnboardingState?> load() async {
    final preferences =
    await SharedPreferences.getInstance();

    final raw =
    preferences.getString(_profileKey);

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return null;
      }

      final map =
      Map<String, dynamic>.from(decoded);

      return OnboardingState(
        goals: _readGoals(map['goals']),
        level: _readFitnessLevel(
          map['level'],
        ),
        duration: _readDuration(
          map['duration'],
        ),
        equipment: _readEquipment(
          map['equipment'],
        ),
        dumbbellCount:
        (map['dumbbellCount'] as num?)
            ?.toInt() ??
            0,
        dumbbellWeightKg:
        (map['dumbbellWeightKg'] as num?)
            ?.toDouble() ??
            0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(
      OnboardingState state,
      ) async {
    final preferences =
    await SharedPreferences.getInstance();

    final data = <String, dynamic>{
      'goals': state.goals.toList(),
      'level': state.level?.name,
      'duration': state.duration?.name,
      'equipment': state.equipment
          .map((item) => item.name)
          .toList(),
      'dumbbellCount':
      state.dumbbellCount,
      'dumbbellWeightKg':
      state.dumbbellWeightKg,
    };

    await preferences.setString(
      _profileKey,
      jsonEncode(data),
    );

    await preferences.setBool(
      _completedKey,
      true,
    );
  }

  Future<void> clear() async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.remove(
      _profileKey,
    );

    await preferences.remove(
      _completedKey,
    );
  }

  Set<String> _readGoals(
      dynamic value,
      ) {
    if (value is! List) {
      return <String>{};
    }

    return value
        .whereType<String>()
        .toSet();
  }

  FitnessLevel? _readFitnessLevel(
      dynamic value,
      ) {
    if (value is! String) {
      return null;
    }

    for (final item
    in FitnessLevel.values) {
      if (item.name == value) {
        return item;
      }
    }

    return null;
  }

  WorkoutDuration? _readDuration(
      dynamic value,
      ) {
    if (value is! String) {
      return null;
    }

    for (final item
    in WorkoutDuration.values) {
      if (item.name == value) {
        return item;
      }
    }

    return null;
  }

  Set<Equipment> _readEquipment(
      dynamic value,
      ) {
    if (value is! List) {
      return <Equipment>{
        Equipment.none,
      };
    }

    final result = <Equipment>{};

    for (final raw in value) {
      if (raw is! String) {
        continue;
      }

      for (final equipment
      in Equipment.values) {
        if (equipment.name == raw) {
          result.add(equipment);
          break;
        }
      }
    }

    if (result.isEmpty) {
      result.add(Equipment.none);
    }

    return result;
  }
}