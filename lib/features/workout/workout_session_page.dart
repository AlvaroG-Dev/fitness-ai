import 'dart:async';

import 'package:flutter/material.dart';

import '../onboarding/onboarding_state.dart';
import 'workout_feedback_page.dart';
import 'workout_generator.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({
    super.key,
    required this.profile,
    required this.workout,
  });

  final OnboardingState profile;
  final GeneratedWorkout workout;

  @override
  State<WorkoutSessionPage> createState() =>
      _WorkoutSessionPageState();
}

class _WorkoutSessionPageState
    extends State<WorkoutSessionPage> {
  Timer? timer;

  int currentStep = 0;
  int elapsedSeconds = 0;
  int remainingSeconds = 0;

  bool paused = false;
  bool finished = false;

  int get totalSteps => widget.workout.steps.length;

  WorkoutStep? get current {
    if (currentStep >= totalSteps) {
      return null;
    }

    return widget.workout.steps[currentStep];
  }

  int get completedSteps {
    if (currentStep >= totalSteps) {
      return totalSteps;
    }

    return currentStep;
  }

  double get progress {
    if (totalSteps == 0) {
      return 1;
    }

    return completedSteps / totalSteps;
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (paused || finished) {
          return;
        }

        setState(() {
          elapsedSeconds++;

          if (current?.type == WorkoutStepType.timed &&
              remainingSeconds > 0) {
            remainingSeconds--;

            if (remainingSeconds == 0) {
              _completeCurrentStep();
            }
          }

          if (current?.type == WorkoutStepType.rest &&
              remainingSeconds > 0) {
            remainingSeconds--;

            if (remainingSeconds == 0) {
              _completeCurrentStep();
            }
          }
        });
      },
    );

    _prepareCurrentStep();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _prepareCurrentStep() {
    final step = current;

    if (step == null) {
      return;
    }

    if (step.type == WorkoutStepType.timed ||
        step.type == WorkoutStepType.rest) {
      remainingSeconds = step.seconds ?? 0;
    } else {
      remainingSeconds = 0;
    }
  }

  void _completeCurrentStep() {
    if (finished) {
      return;
    }

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
    if (finished) {
      return;
    }

    setState(() {
      paused = !paused;
    });
  }

  void _skipRest() {
    final step = current;

    if (step == null) {
      return;
    }

    if (step.type != WorkoutStepType.rest) {
      return;
    }

    _completeCurrentStep();
  }

  void _completeRepetitionStep() {
    final step = current;

    if (step == null ||
        step.type != WorkoutStepType.reps) {
      return;
    }

    _completeCurrentStep();
  }

  String _blockTypeLabel(WorkoutStep step) {
    final index = _findBlockIndex();

    if (index == -1) {
      return 'ENTRENAMIENTO';
    }

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

      for (var round = 0;
      round < block.rounds;
      round++) {
        for (final _ in block.steps) {
          if (counter == currentStep) {
            return blockIndex;
          }

          counter++;
        }

        if (round < block.rounds - 1 &&
            block.restBetweenRounds > 0) {
          if (counter == currentStep) {
            return blockIndex;
          }

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
      for (var round = 0;
      round < block.rounds;
      round++) {
        for (final _ in block.steps) {
          if (counter == currentStep) {
            return round + 1;
          }

          counter++;
        }

        if (round < block.rounds - 1 &&
            block.restBetweenRounds > 0) {
          if (counter == currentStep) {
            return round + 1;
          }

          counter++;
        }
      }
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return _WorkoutCompletePage(
        profile: widget.profile,
        workout: widget.workout,
        elapsedSeconds: elapsedSeconds,
      );
    }

    final step = current;

    if (step == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              elapsedSeconds: elapsedSeconds,
              progress: progress,
              paused: paused,
              onPause: _togglePause,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 250,
                ),
                child: _buildCurrentStep(step),
              ),
            ),
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

    if (exercise == null) {
      return const SizedBox.shrink();
    }

    final blockLabel = _blockTypeLabel(step);
    final round = _currentRound();

    if (step.type == WorkoutStepType.timed) {
      return _TimedExerciseView(
        key: ValueKey('timed-$currentStep'),
        exerciseName: exercise.name,
        blockLabel: blockLabel,
        round: round,
        seconds: remainingSeconds,
        onComplete: _completeCurrentStep,
      );
    }

    return _RepetitionExerciseView(
      key: ValueKey('reps-$currentStep'),
      exerciseName: exercise.name,
      blockLabel: blockLabel,
      round: round,
      repetitions: step.repetitions ?? 0,
      onComplete: _completeRepetitionStep,
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
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPause,
                icon: Icon(
                  paused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
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
              valueColor: AlwaysStoppedAnimation<Color>(
                accent,
              ),
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
    required this.blockLabel,
    required this.round,
    required this.repetitions,
    required this.onComplete,
  });

  final String exerciseName;
  final String blockLabel;
  final int round;
  final int repetitions;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
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
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 36,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF15181D),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white10,
              ),
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
              child: const Text(
                'SERIE COMPLETADA',
              ),
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
    required this.blockLabel,
    required this.round,
    required this.seconds,
    required this.onComplete,
  });

  final String exerciseName;
  final String blockLabel;
  final int round;
  final int seconds;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
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
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 34,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF15181D),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white10,
              ),
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
              child: const Text(
                'TERMINAR AHORA',
              ),
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
          mainAxisAlignment:
          MainAxisAlignment.center,
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
                child: const Text(
                  'ESTOY LISTO',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockBadge extends StatelessWidget {
  const _BlockBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
          ),
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

class _WorkoutCompletePage extends StatelessWidget {
  const _WorkoutCompletePage({
    required this.profile,
    required this.workout,
    required this.elapsedSeconds,
  });

  final OnboardingState profile;
  final GeneratedWorkout workout;
  final int elapsedSeconds;

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _openFeedback(BuildContext context) async {
    final feedback = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutFeedbackPage(
          workout: workout,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (feedback != null) {
      Navigator.of(context).pop(feedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            24,
            30,
            24,
            32,
          ),
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 82,
              color: accent,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Entrenamiento\ncompletado!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              workout.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: _formatTime(elapsedSeconds),
                    label: 'TIEMPO',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '${workout.exerciseCount}',
                    label: 'EJERCICIOS',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '${workout.steps.length}',
                    label: 'BLOQUES',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF15181D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: accent,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Un último paso',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cuéntanos cómo te ha resultado '
                              'para adaptar tus próximos entrenamientos.',
                          style: TextStyle(
                            color: Colors.white54,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () => _openFeedback(context),
                child: const Text(
                  'CONTINUAR',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
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