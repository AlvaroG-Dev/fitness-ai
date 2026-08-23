import 'package:flutter/material.dart';

import '../onboarding/onboarding_state.dart';
import 'workout_generator.dart';
import 'workout_session_page.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key, required this.profile});
  final OnboardingState profile;

  @override
  Widget build(BuildContext context) {
    final workout = const WorkoutGenerator().generate(profile);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + bottomInset),
          children: [
            Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)), const Expanded(child: Text('ENTRENAR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.8))), const SizedBox(width: 48)]),
            const SizedBox(height: 18),
            Text(workout.title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('${workout.exercises.length} ejercicios · preparado para tu nivel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            ...workout.exercises.asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ExerciseCard(number: entry.key + 1, item: entry.value))),
            const SizedBox(height: 8),
            SizedBox(height: 56, child: FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutSessionPage(profile: profile))), icon: const Icon(Icons.play_arrow_rounded), label: const Text('EMPEZAR ENTRENAMIENTO'))),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.number, required this.item});
  final int number;
  final WorkoutExercise item;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF15181D), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Row(children: [
        Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle), child: Text('$number', style: TextStyle(color: accent, fontWeight: FontWeight.w900))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.exercise.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${item.sets} series · ${item.reps} repeticiones · ${item.restSeconds}s', style: const TextStyle(color: Colors.white54, fontSize: 12))])),
      ]),
    );
  }
}
