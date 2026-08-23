import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final Set<String> _selectedGoals = <String>{};

  static const goals = <({String id, String title, IconData icon})>[
    (id: 'arms', title: 'Brazos', icon: Icons.fitness_center),
    (id: 'chest', title: 'Pecho', icon: Icons.accessibility_new),
    (id: 'abs', title: 'Abdominales', icon: Icons.grid_view_rounded),
    (id: 'legs', title: 'Piernas', icon: Icons.directions_run),
    (id: 'back', title: 'Espalda', icon: Icons.airline_seat_recline_normal),
    (id: 'full_body', title: 'Todo el cuerpo', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FITNESS AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
              const Spacer(),
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
              const SizedBox(height: 28),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final selected = _selectedGoals.contains(goal.id);
                    return _GoalCard(
                      title: goal.title,
                      icon: goal.icon,
                      selected: selected,
                      onTap: () => setState(() {
                        if (goal.id == 'full_body') {
                          _selectedGoals
                            ..clear()
                            ..add(goal.id);
                        } else {
                          _selectedGoals.remove('full_body');
                          if (selected) {
                            _selectedGoals.remove(goal.id);
                          } else {
                            _selectedGoals.add(goal.id);
                          }
                        }
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _selectedGoals.isEmpty ? null : () {},
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : Colors.white.withValues(alpha: 0.07),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: selected ? accent : Colors.white70),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
