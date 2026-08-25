import 'dart:async';

import 'package:flutter/material.dart';

import '../../fitness_engine/models/workout_result.dart';
import '../../fitness_engine/storage/progress_repository.dart';
import '../../fitness_engine/models/workout_feedback.dart';
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
  State<WorkoutSessionPage> createState() =>
      _WorkoutSessionPageState();
}

class _WorkoutSessionPageState
    extends State<WorkoutSessionPage> {
  Timer? timer;

  int currentStep = 0;
  int elapsedSeconds = 0;
  int remainingSeconds = 0;

  // Duración original del paso temporizado actual.
  // Se utiliza para calcular el progreso de una recuperación.
  int currentStepTotalSeconds = 0;

  bool paused = false;
  bool finished = false;

  final List<ExerciseResult> _exerciseResults = [];

  List<WorkoutStep> get steps =>
      widget.workout.steps;

  int get totalSteps => steps.length;

  WorkoutStep? get current {
    if (currentStep < 0 ||
        currentStep >= totalSteps) {
      return null;
    }

    return steps[currentStep];
  }

  WorkoutStep? get nextStep {
    final nextIndex = currentStep + 1;

    if (nextIndex >= totalSteps) {
      return null;
    }

    return steps[nextIndex];
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

  int get currentBlockIndex {
    var counter = 0;

    for (var blockIndex = 0;
    blockIndex < widget.workout.blocks.length;
    blockIndex++) {
      final block =
      widget.workout.blocks[blockIndex];

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

  WorkoutBlock? get currentBlock {
    final index = currentBlockIndex;

    if (index < 0 ||
        index >= widget.workout.blocks.length) {
      return null;
    }

    return widget.workout.blocks[index];
  }

  int get currentRound {
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

  int get currentBlockTotalSteps {
    final block = currentBlock;

    if (block == null) {
      return 0;
    }

    return block.steps.length;
  }

  int get currentBlockStep {
    final block = currentBlock;

    if (block == null) {
      return 0;
    }

    var counter = 0;

    for (var blockIndex = 0;
    blockIndex < widget.workout.blocks.length;
    blockIndex++) {
      final candidate =
      widget.workout.blocks[blockIndex];

      for (var round = 0;
      round < candidate.rounds;
      round++) {
        for (var stepIndex = 0;
        stepIndex < candidate.steps.length;
        stepIndex++) {
          if (blockIndex == currentBlockIndex &&
              counter == currentStep) {
            return stepIndex + 1;
          }

          counter++;
        }

        if (round < candidate.rounds - 1 &&
            candidate.restBetweenRounds > 0) {
          if (blockIndex == currentBlockIndex &&
              counter == currentStep) {
            return candidate.steps.length;
          }

          counter++;
        }
      }
    }

    return 1;
  }

  String get currentBlockLabel {
    final block = currentBlock;

    if (block == null) {
      return 'ENTRENAMIENTO';
    }

    return _blockTypeLabel(block.type);
  }

  String get currentBlockTitle {
    final block = currentBlock;

    if (block == null) {
      return 'Entrenamiento';
    }

    return block.title;
  }

  @override
  void initState() {
    super.initState();

    _prepareCurrentStep();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (!mounted ||
            paused ||
            finished) {
          return;
        }

        elapsedSeconds++;

        final step = current;

        if (step != null &&
            (step.type == WorkoutStepType.timed ||
                step.type == WorkoutStepType.rest) &&
            remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });

          if (remainingSeconds == 0) {
            _completeCurrentStep();
            return;
          }

          return;
        }

        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _prepareCurrentStep() {
    final step = current;

    if (step == null) {
      remainingSeconds = 0;
      currentStepTotalSeconds = 0;
      return;
    }

    if (step.type == WorkoutStepType.timed ||
        step.type == WorkoutStepType.rest) {
      remainingSeconds = step.seconds ?? 0;
      currentStepTotalSeconds = step.seconds ?? 0;
    } else {
      remainingSeconds = 0;
      currentStepTotalSeconds = 0;
    }
  }

  void _recordCurrentStep() {
    final step = current;

    if (step == null ||
        step.type == WorkoutStepType.rest) {
      return;
    }

    final exercise = step.exercise;

    if (exercise == null) {
      return;
    }

    final value =
    step.type == WorkoutStepType.timed
        ? step.seconds ?? 0
        : step.repetitions ?? 0;

    _exerciseResults.add(
      ExerciseResult(
        exerciseId: exercise.id,
        value: value,
        feedback: WorkoutDifficulty.good,
      ),
    );
  }

  void _completeCurrentStep() {
    if (finished) {
      return;
    }

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
    if (finished) {
      return;
    }

    setState(() {
      paused = !paused;
    });
  }

  void _skipRest() {
    final step = current;

    if (step == null ||
        step.type != WorkoutStepType.rest) {
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

  void _onFeedbackCompleted(
      WorkoutResult result,
      ) {
    widget.progressRepository.saveWorkout(result);

    Navigator.of(context).pop(result);
  }

  String _blockTypeLabel(
      WorkoutBlockType type,
      ) {
    return switch (type) {
      WorkoutBlockType.warmup =>
      'CALENTAMIENTO',
      WorkoutBlockType.strength =>
      'FUERZA',
      WorkoutBlockType.circuit =>
      'CIRCUITO',
      WorkoutBlockType.superset =>
      'SUPERSET',
      WorkoutBlockType.core =>
      'CORE',
      WorkoutBlockType.finisher =>
      'FINISHER',
      WorkoutBlockType.cooldown =>
      'VUELTA A LA CALMA',
    };
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

    if (step == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFF0B0D10),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  elapsedSeconds:
                  elapsedSeconds,
                  progress: progress,
                  currentStep:
                  currentStep + 1,
                  totalSteps:
                  totalSteps,
                  sectionLabel:
                  currentBlockLabel,
                  sectionTitle:
                  currentBlockTitle,
                  paused: paused,
                  onPause: _togglePause,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(
                      milliseconds: 250,
                    ),
                    child: _buildCurrentStep(
                      step,
                    ),
                  ),
                ),
              ],
            ),
            if (paused)
              _PausedOverlay(
                onResume: _togglePause,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
      WorkoutStep step,
      ) {
    if (step.type ==
        WorkoutStepType.rest) {
      return _RestView(
        key: ValueKey(
          'rest-$currentStep',
        ),
        remainingSeconds:
        remainingSeconds,
        totalSeconds:
        currentStepTotalSeconds,
        blockLabel:
        currentBlockLabel,
        blockTitle:
        currentBlockTitle,
        round: currentRound,
        currentBlockStep:
        currentBlockStep,
        totalBlockSteps:
        currentBlockTotalSteps,
        nextStep: nextStep,
        onSkip: _skipRest,
      );
    }

    final exercise = step.exercise;

    if (exercise == null) {
      return const SizedBox.shrink();
    }

    if (step.type ==
        WorkoutStepType.timed) {
      return _TimedExerciseView(
        key: ValueKey(
          'timed-$currentStep',
        ),
        exerciseName:
        exercise.name,
        cue: exercise.cue,
        blockLabel:
        currentBlockLabel,
        blockTitle:
        currentBlockTitle,
        round: currentRound,
        currentBlockStep:
        currentBlockStep,
        totalBlockSteps:
        currentBlockTotalSteps,
        seconds:
        remainingSeconds,
        nextStep: nextStep,
        onComplete:
        _completeCurrentStep,
      );
    }

    return _RepetitionExerciseView(
      key: ValueKey(
        'reps-$currentStep',
      ),
      exerciseName:
      exercise.name,
      cue: exercise.cue,
      blockLabel:
      currentBlockLabel,
      blockTitle:
      currentBlockTitle,
      round: currentRound,
      currentBlockStep:
      currentBlockStep,
      totalBlockSteps:
      currentBlockTotalSteps,
      repetitions:
      step.repetitions ?? 0,
      nextStep: nextStep,
      onComplete:
      _completeRepetitionStep,
    );
  }
}

// ============================================================
// TOP BAR
// ============================================================

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.elapsedSeconds,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    required this.sectionLabel,
    required this.sectionTitle,
    required this.paused,
    required this.onPause,
  });

  final int elapsedSeconds;
  final double progress;
  final int currentStep;
  final int totalSteps;
  final String sectionLabel;
  final String sectionTitle;
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
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        8,
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
                      ? Icons
                      .play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      sectionLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      sectionTitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      '${_formatTime(elapsedSeconds)} · '
                          '$currentStep/$totalSteps',
                      style:
                      const TextStyle(
                        color:
                        Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 48,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          ClipRRect(
            borderRadius:
            BorderRadius.circular(8),
            child:
            LinearProgressIndicator(
              value: progress.clamp(
                0.0,
                1.0,
              ),
              minHeight: 5,
              backgroundColor:
              Colors.white10,
              valueColor:
              AlwaysStoppedAnimation<
                  Color>(
                accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAUSA
// ============================================================

class _PausedOverlay
    extends StatelessWidget {
  const _PausedOverlay({
    required this.onResume,
  });

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return Positioned.fill(
      child: Container(
        color: const Color(
          0xFF0B0D10,
        ).withValues(
          alpha: 0.94,
        ),
        child: Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .pause_circle_filled_rounded,
                color: accent,
                size: 64,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'ENTRENAMIENTO PAUSADO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                width: 200,
                height: 52,
                child:
                FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(
                    Icons
                        .play_arrow_rounded,
                  ),
                  label:
                  const Text(
                    'REANUDAR',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EJERCICIO DE REPETICIONES
// ============================================================

class _RepetitionExerciseView
    extends StatelessWidget {
  const _RepetitionExerciseView({
    super.key,
    required this.exerciseName,
    required this.cue,
    required this.blockLabel,
    required this.blockTitle,
    required this.round,
    required this.currentBlockStep,
    required this.totalBlockSteps,
    required this.repetitions,
    required this.nextStep,
    required this.onComplete,
  });

  final String exerciseName;
  final String cue;
  final String blockLabel;
  final String blockTitle;
  final int round;
  final int currentBlockStep;
  final int totalBlockSteps;
  final int repetitions;
  final WorkoutStep? nextStep;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            label: blockLabel,
            title: blockTitle,
            round: round,
            currentStep:
            currentBlockStep,
            totalSteps:
            totalBlockSteps,
          ),
          const SizedBox(
            height: 22,
          ),
          Text(
            exerciseName,
            style: const TextStyle(
              fontSize: 38,
              height: 1.05,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          if (cue.isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            _CueBanner(
              cue: cue,
            ),
          ],
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(
              vertical: 34,
              horizontal: 20,
            ),
            decoration:
            BoxDecoration(
              color:
              const Color(0xFF15181D),
              borderRadius:
              BorderRadius.circular(28),
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
                    fontWeight:
                    FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text(
                  'REPETICIONES',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          _NextExercise(
            nextStep: nextStep,
            accent: accent,
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

// ============================================================
// EJERCICIO TEMPORIZADO
// ============================================================

class _TimedExerciseView
    extends StatelessWidget {
  const _TimedExerciseView({
    super.key,
    required this.exerciseName,
    required this.cue,
    required this.blockLabel,
    required this.blockTitle,
    required this.round,
    required this.currentBlockStep,
    required this.totalBlockSteps,
    required this.seconds,
    required this.nextStep,
    required this.onComplete,
  });

  final String exerciseName;
  final String cue;
  final String blockLabel;
  final String blockTitle;
  final int round;
  final int currentBlockStep;
  final int totalBlockSteps;
  final int seconds;
  final WorkoutStep? nextStep;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            label: blockLabel,
            title: blockTitle,
            round: round,
            currentStep:
            currentBlockStep,
            totalSteps:
            totalBlockSteps,
          ),
          const SizedBox(
            height: 22,
          ),
          Text(
            exerciseName,
            style: const TextStyle(
              fontSize: 38,
              height: 1.05,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          if (cue.isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            _CueBanner(
              cue: cue,
            ),
          ],
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(
              vertical: 30,
            ),
            decoration:
            BoxDecoration(
              color:
              const Color(0xFF15181D),
              borderRadius:
              BorderRadius.circular(28),
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
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                const Text(
                  'SEGUNDOS',
                  style: TextStyle(
                    color:
                    Colors.white54,
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          _NextExercise(
            nextStep: nextStep,
            accent: accent,
          ),
          const Spacer(),
          SizedBox(
            height: 58,
            child:
            OutlinedButton(
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

// ============================================================
// DESCANSO
// ============================================================

class _RestView
    extends StatelessWidget {
  const _RestView({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.blockLabel,
    required this.blockTitle,
    required this.round,
    required this.currentBlockStep,
    required this.totalBlockSteps,
    required this.nextStep,
    required this.onSkip,
  });

  final int remainingSeconds;
  final int totalSeconds;

  final String blockLabel;
  final String blockTitle;
  final int round;
  final int currentBlockStep;
  final int totalBlockSteps;

  final WorkoutStep? nextStep;
  final VoidCallback onSkip;

  double get progress {
    if (totalSeconds <= 0) {
      return 0;
    }

    final elapsed =
        totalSeconds - remainingSeconds;

    return (elapsed / totalSeconds)
        .clamp(0.0, 1.0);
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    if (minutes <= 0) {
      return '$secs';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          // --------------------------------------------------
          // CABECERA
          // --------------------------------------------------

          _SectionHeader(
            label: blockLabel,
            title: blockTitle,
            round: round,
            currentStep:
            currentBlockStep,
            totalSteps:
            totalBlockSteps,
          ),

          const SizedBox(
            height: 20,
          ),

          // --------------------------------------------------
          // TEXTO DE RECUPERACIÓN
          // --------------------------------------------------

          const Text(
            'RECUPERACIÓN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 2.5,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Tómate un momento para recuperar',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),

          // --------------------------------------------------
          // TEMPORIZADOR
          // --------------------------------------------------

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 28,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFF15181D,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        28,
                      ),
                      border:
                      Border.all(
                        color:
                        Colors.white10,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatSeconds(
                            remainingSeconds,
                          ),
                          style: TextStyle(
                            color: accent,
                            fontSize: 88,
                            height: 0.95,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          'SEGUNDOS',
                          style:
                          TextStyle(
                            color:
                            Colors.white54,
                            fontSize: 13,
                            letterSpacing:
                            2,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // ------------------------------------------------
                        // PROGRESO DE LA RECUPERACIÓN
                        // ------------------------------------------------

                        Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 24,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'RECUPERACIÓN',
                                    style:
                                    TextStyle(
                                      color:
                                      Colors.white38,
                                      fontSize:
                                      9,
                                      letterSpacing:
                                      1.2,
                                      fontWeight:
                                      FontWeight
                                          .w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style:
                                    TextStyle(
                                      color:
                                      accent,
                                      fontSize:
                                      10,
                                      fontWeight:
                                      FontWeight
                                          .w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              ClipRRect(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  8,
                                ),
                                child:
                                LinearProgressIndicator(
                                  value:
                                  progress,
                                  minHeight:
                                  6,
                                  backgroundColor:
                                  Colors
                                      .white10,
                                  valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                    accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          // --------------------------------------------------
          // SIGUIENTE EJERCICIO
          // --------------------------------------------------

          _NextExercise(
            nextStep: nextStep,
            accent: accent,
          ),

          const SizedBox(
            height: 14,
          ),

          // --------------------------------------------------
          // BOTÓN
          // --------------------------------------------------

          SizedBox(
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
    );
  }
}

// ============================================================
// CABECERA DE SECCIÓN
// ============================================================

class _SectionHeader
    extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.title,
    required this.round,
    required this.currentStep,
    required this.totalSteps,
  });

  final String label;
  final String title;
  final int round;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    final safeTotal =
    totalSteps <= 0
        ? 1
        : totalSteps;

    final safeCurrent =
    currentStep.clamp(
      1,
      safeTotal,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _BlockBadge(
              label: label,
            ),
            const Spacer(),
            Text(
              'RONDA $round',
              style:
              const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight:
                FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style:
                const TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$safeCurrent/$safeTotal',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 7,
        ),
        ClipRRect(
          borderRadius:
          BorderRadius.circular(6),
          child:
          LinearProgressIndicator(
            value:
            safeCurrent /
                safeTotal,
            minHeight: 4,
            backgroundColor:
            Colors.white10,
            valueColor:
            AlwaysStoppedAnimation<
                Color>(
              accent,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SIGUIENTE EJERCICIO
// ============================================================

class _NextExercise
    extends StatelessWidget {
  const _NextExercise({
    required this.nextStep,
    required this.accent,
  });

  final WorkoutStep? nextStep;
  final Color accent;

  String _name() {
    if (nextStep == null) {
      return 'Fin del entrenamiento';
    }

    if (nextStep!.type ==
        WorkoutStepType.rest) {
      return 'Descanso';
    }

    return nextStep!.exercise?.name ??
        'Ejercicio';
  }

  String _value() {
    if (nextStep == null) {
      return '';
    }

    if (nextStep!.type ==
        WorkoutStepType.rest) {
      return '${nextStep!.seconds ?? 0} s';
    }

    if (nextStep!.type ==
        WorkoutStepType.timed) {
      return '${nextStep!.seconds ?? 0} s';
    }

    return '${nextStep!.repetitions ?? 0} reps';
  }

  IconData _icon() {
    if (nextStep == null) {
      return Icons.flag_rounded;
    }

    if (nextStep!.type ==
        WorkoutStepType.rest) {
      return Icons
          .hourglass_bottom_rounded;
    }

    if (nextStep!.type ==
        WorkoutStepType.timed) {
      return Icons.timer_outlined;
    }

    return Icons.repeat_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isEnd = nextStep == null;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFF111419),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
            BoxDecoration(
              color: accent.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              _icon(),
              color: accent,
              size: 18,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  isEnd
                      ? 'SIGUIENTE'
                      : 'SIGUIENTE EJERCICIO',
                  style:
                  const TextStyle(
                    color:
                    Colors.white38,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  _name(),
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (!isEnd)
            Text(
              _value(),
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight:
                FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CUE
// ============================================================

class _CueBanner
    extends StatelessWidget {
  const _CueBanner({
    required this.cue,
  });

  final String cue;

  @override
  Widget build(BuildContext context) {
    if (cue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration:
      BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.04,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Colors.white54,
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Text(
              cue,
              style:
              const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BADGE
// ============================================================

class _BlockBadge
    extends StatelessWidget {
  const _BlockBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration:
      BoxDecoration(
        color: accent.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: accent.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight:
          FontWeight.w900,
        ),
      ),
    );
  }
}