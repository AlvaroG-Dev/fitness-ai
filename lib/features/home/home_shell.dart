import 'package:flutter/material.dart';

import '../onboarding/onboarding_state.dart';
import '../workout/workout_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.profile,
  });

  final OnboardingState profile;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _HomeTab(
              profile: widget.profile,
              onStart: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutPage(
                      profile: widget.profile,
                    ),
                  ),
                );
              },
            ),
            _SimpleTab(
              icon: Icons.calendar_month_rounded,
              title: 'PLAN',
              text: 'Aquí aparecerá tu planificación semanal.',
            ),
            _SimpleTab(
              icon: Icons.bar_chart_rounded,
              title: 'PROGRESO',
              text: 'Aquí podrás ver cómo evolucionas.',
            ),
            _SimpleTab(
              icon: Icons.person_outline_rounded,
              title: 'PERFIL',
              text: 'Tu perfil y preferencias.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.profile,
    required this.onStart,
  });

  final OnboardingState profile;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        30,
      ),
      children: [
        const _TopBar(),
        const SizedBox(height: 28),
        const Text(
          'HOLA 👋',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '¿Entrenamos?',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 22),
        InkWell(
          onTap: onStart,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.24),
                  const Color(0xFF15181D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accent.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                        accent.withValues(alpha: 0.15),
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: accent,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Entrenamiento para ti',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Una sesión adaptada a tus objetivos, '
                      'nivel y tiempo disponible.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_fill_rounded,
                      size: 20,
                      color: accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EMPEZAR',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'ENTRENAR',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _QuickCard(
          icon: Icons.timer_outlined,
          title: 'Sesión rápida',
          text: 'Entrena cuando tengas poco tiempo.',
          onTap: onStart,
        ),
        const SizedBox(height: 10),
        _QuickCard(
          icon: Icons.grid_view_rounded,
          title: 'Por zona muscular',
          text: 'Brazos, pecho, abdomen, piernas o espalda.',
          onTap: onStart,
        ),
        const SizedBox(height: 10),
        _QuickCard(
          icon: Icons.fitness_center_rounded,
          title: 'Entrenamiento completo',
          text: 'Trabaja todo el cuerpo en una sesión.',
          onTap: onStart,
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: accent,
          ),
        ),
        const SizedBox(width: 11),
        const Text(
          'FITNESS AI',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleTab extends StatelessWidget {
  const _SimpleTab({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: accent,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}