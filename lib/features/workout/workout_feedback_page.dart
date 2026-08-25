import 'package:flutter/material.dart';

import '../../fitness_engine/models/workout_feedback.dart';
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
  final ValueChanged<WorkoutFeedback> onCompleted;

  @override
  State<WorkoutFeedbackPage> createState() =>
      _WorkoutFeedbackPageState();
}

class _WorkoutFeedbackPageState
    extends State<WorkoutFeedbackPage> {
  WorkoutDifficulty? selected;

  final options = const [
    (
    difficulty: WorkoutDifficulty.veryEasy,
    emoji: '😌',
    title: 'Muy fácil',
    subtitle: 'Podría haber hecho bastante más',
    ),
    (
    difficulty: WorkoutDifficulty.easy,
    emoji: '🙂',
    title: 'Fácil',
    subtitle: 'Me quedaban algunas fuerzas',
    ),
    (
    difficulty: WorkoutDifficulty.good,
    emoji: '😐',
    title: 'Bien',
    subtitle: 'La dificultad fue adecuada',
    ),
    (
    difficulty: WorkoutDifficulty.hard,
    emoji: '😮',
    title: 'Difícil',
    subtitle: 'Me costó bastante',
    ),
    (
    difficulty: WorkoutDifficulty.veryHard,
    emoji: '🥵',
    title: 'Demasiado difícil',
    subtitle: 'Me costó terminarlo',
    ),
  ];

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).colorScheme.primary;

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
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24,
          ),
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
                    value: _formatTime(
                      widget.elapsedSeconds,
                    ),
                    label: 'TIEMPO',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value:
                    '${widget.workout.exerciseCount}',
                    label: 'EJERCICIOS',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              '¿Cómo te ha resultado?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Tu respuesta ayudará a adaptar '
                  'tus próximos entrenamientos.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ...options.map(
                  (option) {
                final isSelected =
                    selected == option.difficulty;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        selected =
                            option.difficulty;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 180),
                      padding:
                      const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withValues(
                          alpha: 0.14,
                        )
                            : const Color(0xFF15181D),
                        borderRadius:
                        BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? accent
                              : Colors.white10,
                          width:
                          isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            option.emoji,
                            style:
                            const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.title,
                                  style:
                                  const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  option.subtitle,
                                  style:
                                  const TextStyle(
                                    color:
                                    Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons
                                .check_circle_rounded
                                : Icons
                                .circle_outlined,
                            color: isSelected
                                ? accent
                                : Colors.white30,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: selected == null
                    ? null
                    : () {
                  widget.onCompleted(
                    WorkoutFeedback(
                      difficulty: selected!,
                    ),
                  );
                },
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
        vertical: 17,
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