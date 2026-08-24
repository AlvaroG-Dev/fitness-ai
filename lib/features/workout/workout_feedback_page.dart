import 'package:flutter/material.dart';

import '../../fitness_engine/models/workout_feedback.dart';
import 'workout_generator.dart';

class WorkoutFeedbackPage extends StatefulWidget {
  const WorkoutFeedbackPage({
    super.key,
    required this.workout,
  });

  final GeneratedWorkout workout;

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

  void _save() {
    final difficulty = selected;

    if (difficulty == null) {
      return;
    }

    Navigator.of(context).pop(
      WorkoutFeedback(
        difficulty: difficulty,
      ),
    );
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
        centerTitle: false,
        title: const Text(
          'TU ENTRENAMIENTO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                widget.workout.title,
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Cómo te ha resultado?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu respuesta ayudará a adaptar '
                    'tus próximos entrenamientos.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected =
                        selected == option.difficulty;

                    return InkWell(
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
                        const EdgeInsets.all(17),
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
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
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
                            AnimatedSwitcher(
                              duration:
                              const Duration(
                                milliseconds: 160,
                              ),
                              child: isSelected
                                  ? Icon(
                                Icons
                                    .check_circle_rounded,
                                key: const ValueKey(
                                  'selected',
                                ),
                                color: accent,
                              )
                                  : const Icon(
                                Icons
                                    .circle_outlined,
                                key: ValueKey(
                                  'unselected',
                                ),
                                color: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed:
                  selected == null ? null : _save,
                  child: const Text(
                    'GUARDAR',
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
      ),
    );
  }
}