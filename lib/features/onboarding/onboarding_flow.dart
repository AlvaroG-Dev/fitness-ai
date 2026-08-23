import 'package:flutter/material.dart';

import '../workout/workout_page.dart';
import 'onboarding_state.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final controller = PageController();
  final goals = <String>{};
  final equipment = <Equipment>{Equipment.none};
  FitnessLevel? level;
  WorkoutDuration? duration;
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get ready => switch (page) {
        0 => goals.isNotEmpty,
        1 => level != null,
        2 => duration != null,
        _ => true,
      };

  void next() {
    if (!ready) return;
    if (page == 3) {
      final profile = OnboardingState(
        goals: Set.from(goals),
        level: level,
        duration: duration,
        equipment: Set.from(equipment),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WorkoutPage(profile: profile)),
      );
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void toggleGoal(String id) {
    setState(() {
      if (id == 'full_body') {
        goals
          ..clear()
          ..add(id);
      } else {
        goals.remove('full_body');
        if (!goals.add(id)) goals.remove(id);
      }
    });
  }

  void back() {
    if (page > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(page: page, onBack: page == 0 ? null : back),
            Expanded(
              child: PageView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => setState(() => page = value),
                children: [
                  _GoalsStep(selected: goals, onTap: toggleGoal),
                  _SingleChoiceStep<FitnessLevel>(
                    title: '¿Cuál es tu nivel?',
                    subtitle: 'Podremos ajustarlo según tu progreso.',
                    values: const [
                      (FitnessLevel.beginner, 'Principiante', 'Estoy empezando'),
                      (FitnessLevel.intermediate, 'Intermedio', 'Entreno con frecuencia'),
                      (FitnessLevel.advanced, 'Avanzado', 'Tengo experiencia'),
                    ],
                    selected: level,
                    onTap: (value) => setState(() => level = value),
                  ),
                  _SingleChoiceStep<WorkoutDuration>(
                    title: '¿Cuánto tiempo tienes?',
                    subtitle: 'La sesión se adaptará al tiempo disponible.',
                    values: const [
                      (WorkoutDuration.ten, '10 min', 'Rápido y directo'),
                      (WorkoutDuration.fifteen, '15 min', 'Sesión corta'),
                      (WorkoutDuration.twenty, '20 min', 'Equilibrado'),
                      (WorkoutDuration.thirty, '30 min', 'Sesión completa'),
                      (WorkoutDuration.fortyFivePlus, '45+ min', 'Tengo tiempo'),
                    ],
                    selected: duration,
                    onTap: (value) => setState(() => duration = value),
                  ),
                  _EquipmentStep(
                    selected: equipment,
                    onTap: (value) => setState(() {
                      if (value == Equipment.none) {
                        equipment
                          ..clear()
                          ..add(Equipment.none);
                      } else {
                        equipment.remove(Equipment.none);
                        if (!equipment.add(value)) equipment.remove(value);
                        if (equipment.isEmpty) equipment.add(Equipment.none);
                      }
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 10 + bottom),
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 4,
                          margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            color: index <= page ? accent : Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: ready ? next : null,
                      child: Text(
                        page == 3 ? 'GENERAR ENTRENAMIENTO' : 'CONTINUAR',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.page, required this.onBack});

  final int page;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: onBack == null
                  ? null
                  : IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
            ),
            const Expanded(
              child: Text(
                'FITNESS AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Center(
                child: Text(
                  '${page + 1}/4',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
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

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({required this.selected, required this.onTap});

  final Set<String> selected;
  final ValueChanged<String> onTap;

  static const items = [
    ('arms', 'Brazos', Icons.fitness_center),
    ('chest', 'Pecho', Icons.accessibility_new),
    ('abs', 'Abdominales', Icons.grid_view_rounded),
    ('legs', 'Piernas', Icons.directions_run),
    ('back', 'Espalda', Icons.airline_seat_recline_normal),
    ('full_body', 'Todo el cuerpo', Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      children: [
        const Text(
          '¿Qué quieres\nmejorar?',
          style: TextStyle(
            fontSize: 38,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Elige una o varias zonas.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 22),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Tile(
              title: item.$2,
              icon: item.$3,
              selected: selected.contains(item.$1),
              onTap: () => onTap(item.$1),
            ),
          ),
        ),
      ],
    );
  }
}

class _SingleChoiceStep<T> extends StatelessWidget {
  const _SingleChoiceStep({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<(T, String, String)> values;
  final T? selected;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        ...values.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Tile(
              title: item.$2,
              subtitle: item.$3,
              selected: selected == item.$1,
              onTap: () => onTap(item.$1),
            ),
          ),
        ),
      ],
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  const _EquipmentStep({required this.selected, required this.onTap});

  final Set<Equipment> selected;
  final ValueChanged<Equipment> onTap;

  static const items = [
    (Equipment.none, 'Nada', 'Solo peso corporal'),
    (Equipment.backpack, 'Mochila', 'Puedes añadir peso'),
    (Equipment.bands, 'Bandas', 'Bandas elásticas'),
    (Equipment.dumbbells, 'Mancuernas', 'Una o dos'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      children: [
        const Text(
          '¿Qué tienes disponible?',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          'Puedes seleccionar varias opciones.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Tile(
              title: item.$2,
              subtitle: item.$3,
              selected: selected.contains(item.$1),
              onTap: () => onTap(item.$1),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : Colors.white10,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: selected ? accent : Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 14),
            ],
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? accent : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
