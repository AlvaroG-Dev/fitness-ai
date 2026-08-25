import 'package:flutter/material.dart';

import '../../fitness_engine/storage/progress_repository.dart';
import '../onboarding/onboarding_flow.dart';
import '../onboarding/onboarding_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.progressRepository,
  });

  final OnboardingState profile;

  final ProgressRepository
  progressRepository;

  String _levelLabel() {
    return switch (profile.level) {
      FitnessLevel.beginner =>
      'Principiante',
      FitnessLevel.intermediate =>
      'Intermedio',
      FitnessLevel.advanced =>
      'Avanzado',
      null => 'Sin definir',
    };
  }

  String _durationLabel() {
    return switch (profile.duration) {
      WorkoutDuration.ten =>
      '10 minutos',
      WorkoutDuration.fifteen =>
      '15 minutos',
      WorkoutDuration.twenty =>
      '20 minutos',
      WorkoutDuration.thirty =>
      '30 minutos',
      WorkoutDuration.fortyFivePlus =>
      '45+ minutos',
      null => 'Sin definir',
    };
  }

  String _equipmentLabel() {
    if (profile.equipment
        .contains(Equipment.none)) {
      return 'Peso corporal';
    }

    final result =
    <String>[];

    if (profile.equipment
        .contains(Equipment.backpack)) {
      result.add('Mochila');
    }

    if (profile.equipment
        .contains(Equipment.bands)) {
      result.add('Bandas');
    }

    if (profile.equipment
        .contains(Equipment.dumbbells)) {
      result.add(
        '${profile.dumbbellCount} × '
            '${profile.dumbbellWeightKg.toStringAsFixed(
          profile.dumbbellWeightKg % 1 == 0
              ? 0
              : 1,
        )} kg',
      );
    }

    return result.join(' · ');
  }

  Future<void> _editProfile(
      BuildContext context,
      ) async {
    await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) =>
            OnboardingFlow(
              progressRepository:
              progressRepository,
              initialProfile:
              profile,
            ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        30,
      ),
      children: [
        const Text(
          'PERFIL',
          style:
          TextStyle(
            fontSize: 34,
            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        const Text(
          'Tu configuración de entrenamiento.',
          style:
          TextStyle(
            color:
            Colors.white54,
            fontSize: 14,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        _ProfileCard(
          icon:
          Icons.speed_rounded,
          title: 'Nivel',
          value:
          _levelLabel(),
          accent:
          accent,
        ),

        const SizedBox(
          height: 10,
        ),

        _ProfileCard(
          icon:
          Icons.timer_outlined,
          title: 'Duración',
          value:
          _durationLabel(),
          accent:
          accent,
        ),

        const SizedBox(
          height: 10,
        ),

        _ProfileCard(
          icon:
          Icons.fitness_center_rounded,
          title: 'Equipamiento',
          value:
          _equipmentLabel(),
          accent:
          accent,
        ),

        const SizedBox(
          height: 10,
        ),

        _ProfileCard(
          icon:
          Icons.track_changes_rounded,
          title: 'Objetivos',
          value:
          profile.goals.isEmpty
              ? 'Sin definir'
              : profile.goals
              .map(
            _goalLabel,
          )
              .join(' · '),
          accent:
          accent,
        ),

        const SizedBox(
          height: 28,
        ),

        SizedBox(
          height: 56,
          child:
          FilledButton.icon(
            onPressed: () =>
                _editProfile(
                  context,
                ),
            icon: const Icon(
              Icons.edit_rounded,
            ),
            label: const Text(
              'EDITAR PERFIL',
            ),
          ),
        ),
      ],
    );
  }

  String _goalLabel(
      String goal,
      ) {
    return switch (goal) {
      'arms' => 'Brazos',
      'chest' => 'Pecho',
      'abs' => 'Abdominales',
      'legs' => 'Piernas',
      'back' => 'Espalda',
      'full_body' =>
      'Todo el cuerpo',
      _ => goal,
    };
  }
}

class _ProfileCard
    extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFF15181D,
        ),
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
          Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
            BoxDecoration(
              color:
              accent.withValues(
                alpha: 0.1,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color:
              accent,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Colors.white54,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  value,
                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}