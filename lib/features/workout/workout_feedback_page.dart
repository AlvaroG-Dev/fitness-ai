import 'package:flutter/material.dart';

import '../../fitness_engine/models/exercise.dart';
import '../../fitness_engine/models/workout_feedback.dart';
import '../../fitness_engine/models/workout_result.dart';
import 'workout_generator.dart';

class WorkoutFeedbackPage extends StatefulWidget {
  const WorkoutFeedbackPage({
    super.key,
    required this.elapsedSeconds,
    required this.workout,
    required this.onCompleted,
  });

  final int elapsedSeconds;
  final GeneratedWorkout workout;
  final ValueChanged<WorkoutResult> onCompleted;

  @override
  State<WorkoutFeedbackPage> createState() => _WorkoutFeedbackPageState();
}

class _WorkoutFeedbackPageState extends State<WorkoutFeedbackPage> {
  WorkoutDifficulty? overallDifficulty;

  final Map<String, WorkoutDifficulty> exerciseFeedback = {};

  static const options = [
    (
      difficulty: WorkoutDifficulty.veryEasy,
      emoji: '😌',
      title: 'Muy fácil',
      shortTitle: 'Muy fácil',
      subtitle: 'Podría haber hecho bastante más',
    ),
    (
      difficulty: WorkoutDifficulty.easy,
      emoji: '🙂',
      title: 'Fácil',
      shortTitle: 'Fácil',
      subtitle: 'Me quedaban algunas fuerzas',
    ),
    (
      difficulty: WorkoutDifficulty.good,
      emoji: '😐',
      title: 'Bien',
      shortTitle: 'Bien',
      subtitle: 'La dificultad fue adecuada',
    ),
    (
      difficulty: WorkoutDifficulty.hard,
      emoji: '😮',
      title: 'Difícil',
      shortTitle: 'Difícil',
      subtitle: 'Me costó bastante',
    ),
    (
      difficulty: WorkoutDifficulty.veryHard,
      emoji: '🥵',
      title: 'Demasiado difícil',
      shortTitle: 'Muy difícil',
      subtitle: 'Me costó terminarlo',
    ),
  ];

  List<_FeedbackExercise> get mainExercises {
    final seen = <String>{};
    final result = <_FeedbackExercise>[];

    for (final step in widget.workout.steps) {
      final exercise = step.exercise;
      if (exercise == null || exercise.role != ExerciseRole.main) continue;
      if (!seen.add(exercise.id)) continue;

      final value = step.type == WorkoutStepType.timed
          ? step.seconds ?? 0
          : step.repetitions ?? 0;

      result.add(
        _FeedbackExercise(
          exercise: exercise,
          value: value,
          timed: step.type == WorkoutStepType.timed,
        ),
      );
    }

    return result;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool get allExerciseFeedbackSelected =>
      mainExercises.every((item) => exerciseFeedback.containsKey(item.exercise.id));

  void _selectExerciseFeedback(String exerciseId, WorkoutDifficulty difficulty) {
    setState(() {
      exerciseFeedback[exerciseId] = difficulty;
    });
  }

  void _save() {
    if (overallDifficulty == null || !allExerciseFeedbackSelected) return;

    final exerciseResults = <ExerciseResult>[];

    for (final item in mainExercises) {
      final feedback = exerciseFeedback[item.exercise.id];
      if (feedback == null) continue;

      exerciseResults.add(
        ExerciseResult(
          exerciseId: item.exercise.id,
          value: item.value,
          feedback: feedback,
        ),
      );
    }

    final result = WorkoutResult(
      workoutTitle: widget.workout.title,
      completedAt: DateTime.now(),
      elapsedSeconds: widget.elapsedSeconds,
      feedback: overallDifficulty!,
      exercises: exerciseResults,
    );

    widget.onCompleted(result);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final exercises = mainExercises;
    final canSave = overallDifficulty != null && allExerciseFeedbackSelected;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ENTRENAMIENTO COMPLETADO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Center(
              child: Icon(
                Icons.check_circle_rounded,
                size: 72,
                color: accent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '¡Buen trabajo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.workout.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: _formatTime(widget.elapsedSeconds),
                    label: 'TIEMPO',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '${exercises.length}',
                    label: 'EJERCICIOS',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              '¿Cómo te ha resultado?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Primero valora la sesión completa. Después podrás valorar cada ejercicio por separado para que la progresión sea más precisa.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OverallOption(
                  option: option,
                  selected: overallDifficulty == option.difficulty,
                  accent: accent,
                  onTap: () => setState(
                    () => overallDifficulty = option.difficulty,
                  ),
                ),
              ),
            ),
            if (exercises.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'FEEDBACK POR EJERCICIO',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Esto es lo que usará el motor para decidir tu siguiente carga.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              ...exercises.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ExerciseFeedbackCard(
                    item: item,
                    selected: exerciseFeedback[item.exercise.id],
                    accent: accent,
                    onSelected: (difficulty) => _selectExerciseFeedback(
                      item.exercise.id,
                      difficulty,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (!canSave)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Selecciona la dificultad general y el feedback de todos los ejercicios para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                child: const Text(
                  'GUARDAR Y CONTINUAR',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackExercise {
  const _FeedbackExercise({
    required this.exercise,
    required this.value,
    required this.timed,
  });

  final Exercise exercise;
  final int value;
  final bool timed;
}

class _OverallOption extends StatelessWidget {
  const _OverallOption({
    required this.option,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final ({
    WorkoutDifficulty difficulty,
    String emoji,
    String title,
    String shortTitle,
    String subtitle,
  }) option;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : Colors.white10,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? accent : Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseFeedbackCard extends StatelessWidget {
  const _ExerciseFeedbackCard({
    required this.item,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final _FeedbackExercise item;
  final WorkoutDifficulty? selected;
  final Color accent;
  final ValueChanged<WorkoutDifficulty> onSelected;

  String _valueLabel() {
    return item.timed ? '${item.value} s' : '${item.value} reps';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected == null ? Colors.white10 : accent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.exercise.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _valueLabel(),
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final option in options)
                _DifficultyChip(
                  emoji: option.emoji,
                  label: option.shortTitle,
                  selected: selected == option.difficulty,
                  accent: accent,
                  onTap: () => onSelected(option.difficulty),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? accent : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
