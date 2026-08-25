import 'package:flutter/material.dart';

import '../../fitness_engine/insights/insight.dart';
import '../../fitness_engine/insights/insights_engine.dart';
import '../../fitness_engine/storage/progress_repository.dart';
import '../onboarding/onboarding_state.dart';
import 'workout_generator.dart';
import 'workout_session_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({
    super.key,
    required this.profile,
    required this.progressRepository,
  });

  final OnboardingState profile;
  final ProgressRepository progressRepository;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late final GeneratedWorkout workout = const WorkoutGenerator().generate(
    widget.profile,
    progress: widget.progressRepository,
  );

  String _blockName(WorkoutBlockType type) {
    return switch (type) {
      WorkoutBlockType.warmup => 'Calentamiento',
      WorkoutBlockType.strength => 'Fuerza',
      WorkoutBlockType.circuit => 'Circuito',
      WorkoutBlockType.superset => 'Superset',
      WorkoutBlockType.core => 'Core',
      WorkoutBlockType.finisher => 'Finisher',
      WorkoutBlockType.cooldown => 'Vuelta a la calma',
    };
  }

  IconData _blockIcon(WorkoutBlockType type) {
    return switch (type) {
      WorkoutBlockType.warmup => Icons.local_fire_department_rounded,
      WorkoutBlockType.strength => Icons.fitness_center_rounded,
      WorkoutBlockType.circuit => Icons.loop_rounded,
      WorkoutBlockType.superset => Icons.bolt_rounded,
      WorkoutBlockType.core => Icons.accessibility_new_rounded,
      WorkoutBlockType.finisher => Icons.flash_on_rounded,
      WorkoutBlockType.cooldown => Icons.self_improvement_rounded,
    };
  }

  /// Aviso de recuperación: si la última sesión fue hace muy poco,
  /// lo mostramos antes de empezar. Esta señal la produce la capa
  /// de insights a partir del historial, no el motor de generación.
  Insight? get _recoveryInsight {
    final hours = widget.progressRepository.hoursSinceLastSession;
    if (hours == null || hours >= 16) return null;

    final insights = const WorkoutInsightsEngine().analyze(
      widget.progressRepository.history,
    );

    for (final insight in insights) {
      if (insight.tone == InsightTone.caution) return insight;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final generated = workout;
    final accent = Theme.of(context).colorScheme.primary;
    final recovery = _recoveryInsight;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'ENTRENAMIENTO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  Text(
                    generated.title,
                    style: const TextStyle(
                      fontSize: 34,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle(generated),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                    ),
                  ),
                  if (recovery != null) ...[
                    const SizedBox(height: 16),
                    _RecoveryBanner(message: recovery.message),
                  ],
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15181D),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            value: '${generated.exerciseCount}',
                            label: 'EJERCICIOS',
                          ),
                        ),
                        Expanded(
                          child: _SummaryItem(
                            value: _durationText(generated.totalSeconds),
                            label: 'APROX.',
                          ),
                        ),
                        Expanded(
                          child: _SummaryItem(
                            value: '${generated.blocks.length}',
                            label: 'BLOQUES',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...generated.blocks.map(
                    (block) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BlockCard(
                        title: _blockName(block.type),
                        icon: _blockIcon(block.type),
                        rounds: block.rounds,
                        exercises: block.steps.length,
                        rest: block.restBetweenRounds,
                        accent: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: generated.blocks.isEmpty
                      ? null
                      : () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorkoutSessionPage(
                                profile: widget.profile,
                                workout: generated,
                                progressRepository: widget.progressRepository,
                              ),
                            ),
                          );

                          if (result != null && context.mounted) {
                            Navigator.of(context).pop(result);
                          }
                        },
                  child: const Text('EMPEZAR ENTRENAMIENTO'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(GeneratedWorkout workout) {
    if (workout.blocks.length >= 4) {
      return 'Una sesión completa adaptada a tu perfil.';
    }
    return 'Preparado según tus objetivos y nivel.';
  }

  String _durationText(int seconds) {
    final minutes = (seconds / 60).ceil();
    return '$minutes min';
  }
}

class _RecoveryBanner extends StatelessWidget {
  const _RecoveryBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFFFC15E);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bedtime_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: color,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
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
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.title,
    required this.icon,
    required this.rounds,
    required this.exercises,
    required this.rest,
    required this.accent,
  });

  final String title;
  final IconData icon;
  final int rounds;
  final int exercises;
  final int rest;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$exercises ejercicios · '
                  '$rounds ${rounds == 1 ? 'ronda' : 'rondas'}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                if (rest > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    '$rest s entre rondas',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
        ],
      ),
    );
  }
}
