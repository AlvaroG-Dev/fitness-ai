import 'dart:async';

import 'package:flutter/material.dart';

import '../onboarding/onboarding_state.dart';
import 'workout_generator.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key, required this.profile});

  final OnboardingState profile;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late final GeneratedWorkout workout;
  int exerciseIndex = 0;
  int setIndex = 0;
  int elapsedSeconds = 0;
  int phaseSeconds = 0;
  bool paused = false;
  bool resting = false;
  String restLabel = 'DESCANSO';
  Timer? timer;

  WorkoutExercise get current => workout.exercises[exerciseIndex];
  bool get lastSet => setIndex + 1 >= current.sets;
  bool get lastExercise => exerciseIndex + 1 >= workout.exercises.length;
  bool get needsRestAfterSet => !lastSet && (setIndex + 1).isEven;
  int get restDuration =>
      lastSet ? current.exerciseRestSeconds : current.restSeconds;
  int get restRemaining => restDuration - phaseSeconds;

  @override
  void initState() {
    super.initState();
    workout = const WorkoutGenerator().generate(widget.profile);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || paused) return;
      setState(() {
        elapsedSeconds++;
        if (resting) {
          phaseSeconds++;
          if (phaseSeconds >= restDuration) {
            resting = false;
            phaseSeconds = 0;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void completeSet() {
    if (resting || paused) return;
    if (lastSet && lastExercise) {
      _finish();
      return;
    }

    setState(() {
      if (lastSet) {
        exerciseIndex++;
        setIndex = 0;
        restLabel = 'RECUPERACIÓN';
        resting = true;
      } else if (needsRestAfterSet) {
        setIndex++;
        restLabel = 'DESCANSO';
        resting = true;
      } else {
        setIndex++;
        resting = false;
      }
      phaseSeconds = 0;
    });
  }

  void skipRest() {
    setState(() {
      resting = false;
      phaseSeconds = 0;
    });
  }

  void _finish() {
    timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutCompletePage(
          durationSeconds: elapsedSeconds,
          exerciseCount: workout.exercises.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final progress =
        (exerciseIndex + setIndex / current.sets) / workout.exercises.length;
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'ENTRENAMIENTO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => paused = !paused),
                    icon: Icon(
                      paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$minutes:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'EJERCICIO ${exerciseIndex + 1} DE ${workout.exercises.length}',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                current.exercise.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resting
                    ? '$restLabel. Prepárate para lo siguiente.'
                    : 'Mantén una técnica controlada. No necesitas ir con prisa.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 15),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: resting
                    ? _RestCard(
                        key: const ValueKey('rest'),
                        remaining: restRemaining.clamp(0, restDuration),
                        onSkip: skipRest,
                        accent: accent,
                      )
                    : _WorkCard(
                        key: const ValueKey('work'),
                        setNumber: setIndex + 1,
                        totalSets: current.sets,
                        reps: current.reps,
                        accent: accent,
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: paused || resting ? null : completeSet,
                  icon: Icon(
                    lastSet && lastExercise
                        ? Icons.check_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    lastSet && lastExercise
                        ? 'TERMINAR ENTRENAMIENTO'
                        : 'HE TERMINADO LA SERIE',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${current.sets} series · ${current.reps} repeticiones · descanso cada 2 series',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    super.key,
    required this.setNumber,
    required this.totalSets,
    required this.reps,
    required this.accent,
  });

  final int setNumber;
  final int totalSets;
  final int reps;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              'SERIE $setNumber DE $totalSets',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$reps',
              style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w900),
            ),
            const Text(
              'repeticiones objetivo',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
}

class _RestCard extends StatelessWidget {
  const _RestCard({
    super.key,
    required this.remaining,
    required this.onSkip,
    required this.accent,
  });

  final int remaining;
  final VoidCallback onSkip;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accent.withValues(alpha: .35)),
        ),
        child: Column(
          children: [
            const Text(
              'RECUPERACIÓN',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 6),
            Text(
              '$remaining',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
            ),
            const Text('segundos', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('ESTOY LISTO'),
            ),
          ],
        ),
      );
}

class WorkoutCompletePage extends StatelessWidget {
  const WorkoutCompletePage({
    super.key,
    required this.durationSeconds,
    required this.exerciseCount,
  });

  final int durationSeconds;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    final minutes = durationSeconds ~/ 60;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Entrenamiento completado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  '$exerciseCount ejercicios · $minutes min',
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('VOLVER A INICIO'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
