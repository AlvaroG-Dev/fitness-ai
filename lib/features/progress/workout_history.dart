import 'package:flutter/foundation.dart';

class WorkoutRecord {
  const WorkoutRecord({
    required this.completedAt,
    required this.duration,
    required this.exerciseCount,
    required this.totalReps,
    required this.difficulty,
  });

  final DateTime completedAt;
  final Duration duration;
  final int exerciseCount;
  final int totalReps;
  final Effort difficulty;
}

enum Effort { easy, normal, hard }

class WorkoutHistory extends ChangeNotifier {
  WorkoutHistory._();
  static final WorkoutHistory instance = WorkoutHistory._();

  final List<WorkoutRecord> _records = [];

  List<WorkoutRecord> get records => List.unmodifiable(_records);
  int get sessions => _records.length;
  int get totalMinutes => _records.fold(0, (sum, r) => sum + r.duration.inMinutes);

  void add(WorkoutRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  int get streak {
    if (_records.isEmpty) return 0;
    final days = _records
        .map((r) => DateTime(r.completedAt.year, r.completedAt.month, r.completedAt.day))
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
}
