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
  int seconds = 0;
  Timer? timer;

  WorkoutExercise get current => workout.exercises[exerciseIndex];
  bool get lastSet => setIndex + 1 >= current.sets;
  bool get lastExercise => exerciseIndex + 1 >= workout.exercises.length;

  @override
  void initState() {
    super.initState();
    workout = const WorkoutGenerator().generate(widget.profile);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void completeSet() {
    if (lastSet) {
      if (lastExercise) {
        timer?.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => WorkoutCompletePage(durationSeconds: seconds, exerciseCount: workout.exercises.length)));
      } else {
        setState(() {
          exerciseIndex++;
          setIndex = 0;
        });
      }
    } else {
      setState(() => setIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final progress = (exerciseIndex + setIndex / current.sets) / workout.exercises.length;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Row(children: [
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                const Expanded(child: Text('ENTRENAMIENTO', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.8))),
                Text('$minutes:${secs.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 6)),
              const SizedBox(height: 30),
              Text('EJERCICIO ${exerciseIndex + 1} DE ${workout.exercises.length}', style: TextStyle(color: accent, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
              const SizedBox(height: 12),
              Text(current.exercise.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, height: 1.05, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('${current.sets} series · ${current.reps} repeticiones · ${current.restSeconds}s descanso', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
              const Spacer(),
              Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF15181D), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: Column(children: [Text('SERIE ${setIndex + 1}', style: TextStyle(color: accent, fontWeight: FontWeight.w900, letterSpacing: 1.2)), const SizedBox(height: 12), Text('${current.reps}', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900)), const Text('repeticiones', style: TextStyle(color: Colors.white54))])),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 58, child: FilledButton.icon(onPressed: completeSet, icon: Icon(lastSet && lastExercise ? Icons.check_rounded : Icons.arrow_forward_rounded), label: Text(lastSet && lastExercise ? 'TERMINAR' : 'SERIE COMPLETADA'))),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutCompletePage extends StatelessWidget {
  const WorkoutCompletePage({super.key, required this.durationSeconds, required this.exerciseCount});
  final int durationSeconds;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    final minutes = durationSeconds ~/ 60;
    return Scaffold(
      body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 82, height: 82, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .14), shape: BoxShape.circle), child: Icon(Icons.check_rounded, size: 48, color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 24), const Text('¡Entrenamiento completado!', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text('$exerciseCount ejercicios · $minutes min', style: const TextStyle(color: Colors.white60)), const SizedBox(height: 28), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('VOLVER A INICIO')))]))),
    );
  }
}
