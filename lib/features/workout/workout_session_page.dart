import 'dart:async';

import 'package:flutter/material.dart';

import '../../fitness_engine/models/workout_feedback.dart';
import '../../fitness_engine/models/workout_result.dart';
import '../../fitness_engine/storage/progress_repository.dart';
import '../onboarding/onboarding_state.dart';
import 'workout_feedback_page.dart';
import 'workout_generator.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({
    super.key,
    required this.profile,
    required this.workout,
    required this.progressRepository,
  });

  final OnboardingState profile;
  final GeneratedWorkout workout;
  final ProgressRepository progressRepository;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  Timer? timer;

  int currentStep = 0;
  int elapsedSeconds = 0;
  int remainingSeconds = 0;

  bool paused = false;
  bool finished = false;

  final List<ExerciseResult> _exerciseResults = [];

  int get totalSteps => widget.workout.steps.length;

  WorkoutStep? get current {
    if (currentStep >= totalSteps) return null;
    return widget.workout.steps[currentStep];
  }

  int get completedSteps {
    if (currentStep >= totalSteps) return totalSteps;
    return currentStep;
  }

  double get progress {
    if (totalSteps == 0) return 1;
    return completedSteps / totalSteps;
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (paused || finished) return;

      setState(() {
        elapsedSeconds++;

        if ((current?.type == WorkoutStepType.timed ||
                current?.type == WorkoutStepType.rest) &&
            remainingSeconds > 0) {
          remainingSeconds--;

          if (remainingSeconds == 0) {
            _completeCurrentStep();
          }
        }
      });
    });

    _prepareCurrentStep();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _prepareCurrentStep() {
    final step = current;
    if (step == null) return;

    if (step.type == WorkoutStepType.timed ||
        step.type == WorkoutStepType.rest) {
      remainingSeconds = step.seconds ?? 0;
    } else {
      remainingSeconds = 0;
    }
  }

  void _recordCurrentStep() {
    final step = current;
    if (step == null) return;
    if (step.type == WorkoutStepType.rest) return;

    final exercise = step.exercise;
    if (exercise == null) return;

    final value = step.type == WorkoutStepType.timed
        ? (step.seconds ?? 0)
        : (step.repetitions ?? 0);

    // El feedback global (RPE) se conoce solo al terminar la sesión;
    // se rellena en `_finishWorkout` tras la pantalla de feedback.
    _exerciseResults.add(
      ExerciseResult(
        exerciseId: exercise.id,
        value: value,
        feedback: WorkoutDifficulty.good,
      ),
    );
  }

  void _completeCurrentStep() {
    if (finished) return;

    _recordCurrentStep();

    if (currentStep >= totalSteps - 1) {
      _finishWorkout();
      return;
    }

    setState(() {
      currentStep++;
      _prepareCurrentStep();
    });
  }

  void _finishWorkout() {
    timer?.cancel();

    setState(() {
      finished = true;
    });
  }

  void _togglePause() {
    if (finished) return;
    setState(() {
      paused = !paused;
    });
  }

  void _skipRest() {
    final step = current;
    if (step == null || step.type != WorkoutStepType.rest) return;
    _completeCurrentStep();
  }

  void _completeRepetitionStep() {
    final step = current;
    if (step == null || step.type != WorkoutStepType.reps) return;
    _completeCurrentStep();
  }

  void _onFeedbackCompleted(WorkoutFeedback feedback) {
    final results = [
      for (final result in _exerciseResults)
        ExerciseResult(
          exerciseId: result.exerciseId,
          value: result.value,
          feedback: feedback.difficulty,
        ),
    ];

    widget.progressRepository.saveWorkout(
      WorkoutResult(
        workoutTitle: widget.workout.title,
        completedAt: DateTime.now(),
        elapsedSeconds: elapsedSeconds,
        feedback: feedback.difficulty,
        exercises: results,
      ),
    );

    Navigator.of(context).pop(feedback);
  }

  String _blockTypeLabel(WorkoutStep step) {
    final index = _findBlockIndex();
    if (index == -1) return 'ENTRENAMIENTO';

    final block = _blockForStep(index);

    return switch (block.type) {
      WorkoutBlockType.warmup => 'CALENTAMIENTO',
      WorkoutBlockType.strength => 'FUERZA',
      WorkoutBlockType.circuit => 'CIRCUITO',
      WorkoutBlockType.superset => 'SUPERSET',
      WorkoutBlockType.core => 'CORE',
      WorkoutBlockType.finisher => 'FINISHER',
      WorkoutBlockType.cooldown => 'VUELTA A LA CALMA',
    };
  }

  int _findBlockIndex() {
    var counter = 0;

    for (var blockIndex = 0;
        blockIndex < widget.workout.blocks.length;
        blockIndex++) {
      final block = widget.workout.blocks[blockIndex];

      for (var round = 0; round < block.rounds; round++) {
        for (final _ in block.steps) {
          if (counter == currentStep) return blockIndex;
          counter++;
        }

        if (round < block.rounds - 1 && block.restBetweenRounds > 0) {
          if (counter == currentStep) return blockIndex;
          counter++;
        }
      }
    }

    return -1;
  }

  WorkoutBlock _blockForStep(int blockIndex) {
    return widget.workout.blocks[blockIndex];
  }

  int _currentRound() {
    var counter = 0;

    for (final block in widget.workout.blocks) {
      for (var round = 0; round < block.rounds; round++) {
        for (final _ in block.steps) {
          if (counter == currentStep) return round + 1;
          counter++;
        }

        if (round < block.rounds - 1 && block.restBetweenRounds > 0) {
          if (counter == currentStep) return round + 1;
          counter++;
        }
      }
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return WorkoutFeedbackPage(
        workout: widget.workout,
        elapsedSeconds: elapsedSeconds,
        onCompleted: _onFeedbackCompleted,
      );
    }

    final step = current;
    if (step == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  elapsedSeconds: elapsedSeconds,
                  progress: progress,
                  paused: paused,
                  onPause: _togglePause,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentStep(step),
                  ),
                ),
              ],
            ),
            if (paused) _PausedOverlay(onResume: _togglePause),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(WorkoutStep step) {
    if (step.type == WorkoutStepType.rest) {
      return _RestView(
        key: ValueKey('rest-$currentStep'),
        remainingSeconds: remainingSeconds,
        blockLabel: _blockTypeLabel(step),
        onSkip: _skipRest,
      );
    }

    final exercise = step.exercise;
    if (exercise == null) return const SizedBox.shrink();

    final blockLabel = _blockTypeLabel(step);
    final round = _currentRound();

    if (step.type == WorkoutStepType.timed) {
      return _TimedExerciseView(
        key: ValueKey('timed-$currentStep'),
        exerciseName: exercise.name,
        cue: exercise.cue,
        blockLabel: blockLabel,
        round: round,
        seconds: remainingSeconds,
        onComplete: _completeCurrentStep,
      );
    }

    return _RepetitionExerciseView(
      key: ValueKey('reps-$currentStep'),
      exerciseName: exercise.name,
      cue: exercise.cue,
      blockLabel: blockLabel,
      round: round,
      repetitions: step.repetitions ?? 0,
      onComplete: _completeRepetitionStep,
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0B0D10).withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_filled_rounded, color: accent, size: 64),
              const SizedBox(height: 16),
              const Text(
                'ENTRENAMIENTO PAUSADO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('REANUDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.elapsedSeconds,
    required this.progress,
    required this.paused,
    required this.onPause,
  });

  final int elapsedSeconds;
  final double progress;
  final bool paused;
  final VoidCallback onPause;

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPause,
                icon: Icon(
                  paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'ENTRENAMIENTO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatTime(elapsedSeconds),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepetitionExerciseView extends StatelessWidget {
  const _RepetitionExerciseView({
    super.key,
    required this.exerciseName,
    required this.cue,
    required this.blockLabel,
    required this.round,
    required this.repetitions,
    required this.onComplete,
  });

  final String exerciseName;
  final String cue;
  final String blockLabel;
  final int round;
  final int repetitions;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BlockBadge(label: blockLabel),
          const SizedBox(height: 20),
          Text(
            exerciseName,
            style: const TextStyle(
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ronda $round',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _CueBanner(cue: cue),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF15181D),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Text(
                  '$repetitions',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'REPETICIONES',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: onComplete,
              child: const Text('SERIE COMPLETADA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimedExerciseView extends StatelessWidget {
  const _TimedExerciseView({
    super.key,
    required this.exerciseName,
    required this.cue,
    required this.blockLabel,
    required this.round,
    required this.seconds,
    required this.onComplete,
  });

  final String exerciseName;
  final String cue;
  final String blockLabel;
  final int round;
  final int seconds;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BlockBadge(label: blockLabel),
          const SizedBox(height: 20),
          Text(
            exerciseName,
            style: const TextStyle(
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ronda $round',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _CueBanner(cue: cue),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 34),
            decoration: BoxDecoration(
              color: const Color(0xFF15181D),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Text(
                  '$seconds',
                  style: TextStyle(
                    color: accent,
                    fontSize: 78,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'SEGUNDOS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 58,
            child: OutlinedButton(
              onPressed: onComplete,
              child: const Text('TERMINAR AHORA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  const _RestView({
    super.key,
    required this.remainingSeconds,
    required this.blockLabel,
    required this.onSkip,
  });

  final int remainingSeconds;
  final String blockLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RECUPERACIÓN',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              blockLabel,
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 34),
            Text(
              '$remainingSeconds',
              style: TextStyle(
                color: accent,
                fontSize: 96,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'SEGUNDOS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: onSkip,
                child: const Text('ESTOY LISTO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockBadge extends StatelessWidget {
  const _BlockBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CueBanner extends StatelessWidget {
  const _CueBanner({required this.cue});

  final String cue;

  @override
  Widget build(BuildContext context) {
    if (cue.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            cue,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
