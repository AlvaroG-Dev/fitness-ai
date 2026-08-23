import 'package:flutter/material.dart';

import 'onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  final Set<String> _goals = <String>{};
  FitnessLevel? _level;
  WorkoutDuration? _duration;
  final Set<Equipment> _equipment = <Equipment>{Equipment.none};
  int _page = 0;

  static const goals = <({String id, String title, IconData icon})>[
    (id: 'arms', title: 'Brazos', icon: Icons.fitness_center),
    (id: 'chest', title: 'Pecho', icon: Icons.accessibility_new),
    (id: 'abs', title: 'Abdominales', icon: Icons.grid_view_rounded),
    (id: 'legs', title: 'Piernas', icon: Icons.directions_run),
    (id: 'back', title: 'Espalda', icon: Icons.airline_seat_recline_normal),
    (id: 'full_body', title: 'Todo el cuerpo', icon: Icons.person),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_page) {
        0 => _goals.isNotEmpty,
        1 => _level != null,
        2 => _duration != null,
        3 => _equipment.isNotEmpty,
        _ => false,
      };

  void _next() {
    if (!_canContinue) return;
    if (_page == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SummaryPage(
            state: OnboardingState(
              goals: Set<String>.from(_goals),
              level: _level,
              duration: _duration,
              equipment: Set<Equipment>.from(_equipment),
            ),
          ),
        ),
      );
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_page == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),
                  const Expanded(
                    child: Text(
                      'FITNESS AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  _GoalsStep(
                    selected: _goals,
                    goals: goals,
                    onChanged: (id) => setState(() {
                      if (id == 'full_body') {
                        _goals
                          ..clear()
                          ..add(id);
                      } else {
                        _goals.remove('full_body');
                        if (!_goals.add(id)) _goals.remove(id);
                      }
                    }),
                  ),
                  _ChoiceStep<FitnessLevel>(
                    title: '¿Cuál es tu nivel?',
                    subtitle: 'No te preocupes: podremos ajustarlo después.',
                    values: const [
                      (
                        FitnessLevel.beginner,
                        'Principiante',
                        'Estoy empezando',
                      ),
                      (
                        FitnessLevel.intermediate,
                        'Intermedio',
                        'Ya entreno con frecuencia',
                      ),
                      (
                        FitnessLevel.advanced,
                        'Avanzado',
                        'Tengo bastante experiencia',
                      ),
                    ],
                    selected: _level,
                    onSelected: (value) => setState(() => _level = value),
                  ),
                  _ChoiceStep<WorkoutDuration>(
                    title: '¿Cuánto tiempo tienes?',
                    subtitle:
                        'Crearemos la sesión alrededor del tiempo disponible.',
                    values: const [
                      (WorkoutDuration.ten, '10 min', 'Rápido y directo'),
                      (WorkoutDuration.fifteen, '15 min', 'Sesión corta'),
                      (WorkoutDuration.twenty, '20 min', 'Equilibrado'),
                      (WorkoutDuration.thirty, '30 min', 'Sesión completa'),
                      (
                        WorkoutDuration.fortyFivePlus,
                        '45+ min',
                        'Tengo tiempo',
                      ),
                    ],
                    selected: _duration,
                    onSelected: (value) => setState(() => _duration = value),
                  ),
                  _EquipmentStep(
                    selected: _equipment,
                    onChanged: (value) => setState(() {
                      if (value == Equipment.none) {
                        _equipment
                          ..clear()
                          ..add(Equipment.none);
                      } else {
                        _equipment.remove(Equipment.none);
                        if (!_equipment.add(value)) _equipment.remove(value);
                        if (_equipment.isEmpty) _equipment.add(Equipment.none);
                      }
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            color: index <= _page
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _canContinue ? _next : null,
                      child: Text(
                        _page == 3
                            ? 'CREAR MI ENTRENAMIENTO'
                            : 'CONTINUAR',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
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

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({
    required this.selected,
    required this.goals,
    required this.onChanged,
  });

  final Set<String> selected;
  final List<({String id, String title, IconData icon})> goals;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué quieres\nmejorar?',
            style: TextStyle(
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selecciona una o varias zonas. Nosotros nos encargamos del resto.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GoalCard(
                title: goal.title,
                icon: goal.icon,
                selected: selected.contains(goal.id),
                onTap: () => onChanged(goal.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceStep<T> extends StatelessWidget {
  const _ChoiceStep({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final List<(T, String, String)> values;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 28),
        ...values.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChoiceCard(
              title: item.$2,
              subtitle: item.$3,
              selected: selected == item.$1,
              onTap: () => onSelected(item.$1),
            ),
          ),
        ),
      ],
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  const _EquipmentStep({required this.selected, required this.onChanged});

  final Set<Equipment> selected;
  final ValueChanged<Equipment> onChanged;

  static const items = [
    (Equipment.none, 'Nada', 'Entrenar solo con tu cuerpo'),
    (Equipment.backpack, 'Mochila', 'Una mochila con algo de peso'),
    (Equipment.bands, 'Bandas', 'Bandas elásticas'),
    (Equipment.dumbbells, 'Mancuernas', 'Una o dos mancuernas'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      children: [
        const Text(
          '¿Qué tienes disponible?',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Puedes seleccionar varias opciones. Si no tienes nada, no pasa nada.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 28),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChoiceCard(
              title: item.$2,
              subtitle: item.$3,
              selected: selected.contains(item.$1),
              onTap: () => onChanged(item.$1),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.15)
              : const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.15)
              : const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: selected ? accent : Colors.white70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
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

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key, required this.state});

  final OnboardingState state;

  String _levelText() => switch (state.level) {
        FitnessLevel.beginner => 'Principiante',
        FitnessLevel.intermediate => 'Intermedio',
        FitnessLevel.advanced => 'Avanzado',
        null => '-',
      };

  String _durationText() => switch (state.duration) {
        WorkoutDuration.ten => '10 min',
        WorkoutDuration.fifteen => '15 min',
        WorkoutDuration.twenty => '20 min',
        WorkoutDuration.thirty => '30 min',
        WorkoutDuration.fortyFivePlus => '45+ min',
        null => '-',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Perfecto!',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ya tenemos lo necesario para preparar tu primer entrenamiento.',
            ),
            const SizedBox(height: 28),
            _SummaryTile(title: 'Objetivos', value: state.goals.join(', ')),
            _SummaryTile(title: 'Nivel', value: _levelText()),
            _SummaryTile(title: 'Tiempo', value: _durationText()),
            _SummaryTile(
              title: 'Equipamiento',
              value: state.equipment.map((e) => e.name).join(', '),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {},
                child: const Text('GENERAR ENTRENAMIENTO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: const Color(0xFF15181D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
