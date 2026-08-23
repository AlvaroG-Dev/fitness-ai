import 'package:flutter/material.dart';

import '../onboarding/onboarding_state.dart';
import '../workout/workout_generator.dart';
import '../workout/workout_page.dart';
import '../workout/workout_session_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.profile});
  final OnboardingState profile;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  void startWorkout() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutSessionPage(profile: widget.profile)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(profile: widget.profile, onStart: startWorkout),
      _TrainTab(profile: widget.profile, onStart: startWorkout),
      const _ProgressTab(),
      _ProfileTab(profile: widget.profile),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department_rounded), label: 'Entrenar'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Progreso'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.profile, required this.onStart});
  final OnboardingState profile;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    final workout = const WorkoutGenerator().generate(profile);
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 24), children: [
      const _TopBar(title: 'FITNESS AI'), const SizedBox(height: 26),
      const Text('Buenos días 👋', style: TextStyle(fontSize: 16, color: Colors.white60)), const SizedBox(height: 4),
      const Text('¿Listo para entrenar?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 22),
      _TodayCard(workout: workout, onStart: onStart), const SizedBox(height: 26), const _SectionTitle(title: 'Tu progreso'), const SizedBox(height: 12),
      const Row(children: [Expanded(child: _StatCard(value: '0', label: 'sesiones')), SizedBox(width: 10), Expanded(child: _StatCard(value: '0 min', label: 'entrenados')), SizedBox(width: 10), Expanded(child: _StatCard(value: '0', label: 'racha'))]),
      const SizedBox(height: 26), const _SectionTitle(title: 'Para ti'), const SizedBox(height: 12), const _InfoCard(icon: Icons.auto_awesome_rounded, title: 'Entrenamiento adaptativo', text: 'Tu plan se ajustará según tus objetivos y evolución.'),
    ]));
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.workout, required this.onStart});
  final GeneratedWorkout workout;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF15181D), borderRadius: BorderRadius.circular(24), border: Border.all(color: accent.withValues(alpha: .45))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(10)), child: Text('PARA HOY', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900))), const Spacer(), const Icon(Icons.auto_awesome_rounded, color: Colors.white54)]),
      const SizedBox(height: 18), Text(workout.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('${workout.exercises.length} ejercicios · adaptado a ti', style: const TextStyle(color: Colors.white60)), const SizedBox(height: 18),
      SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(onPressed: onStart, icon: const Icon(Icons.play_arrow_rounded), label: const Text('EMPEZAR'))),
    ]));
  }
}

class _TrainTab extends StatelessWidget {
  const _TrainTab({required this.profile, required this.onStart});
  final OnboardingState profile;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const _TopBar(title: 'ENTRENAR'), const SizedBox(height: 26), const Text('Elige cómo quieres entrenar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 18), InkWell(onTap: onStart, borderRadius: BorderRadius.circular(18), child: const _InfoCard(icon: Icons.auto_awesome_rounded, title: 'Entrenamiento para ti', text: 'Generado según tu perfil actual. Toca para empezar.')), const SizedBox(height: 12), const _InfoCard(icon: Icons.timer_outlined, title: 'Sesiones rápidas', text: 'Entrenamientos para cuando tienes poco tiempo.'), const SizedBox(height: 12), const _InfoCard(icon: Icons.grid_view_rounded, title: 'Por zona muscular', text: 'Brazos, pecho, abdominales, piernas, espalda o cuerpo completo.'), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutPage(profile: profile))), icon: const Icon(Icons.list_alt_rounded), label: const Text('VER ENTRENAMIENTO'))]));
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();
  @override
  Widget build(BuildContext context) => const SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_TopBar(title: 'PROGRESO'), SizedBox(height: 26), Text('Tu progreso', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), SizedBox(height: 18), _InfoCard(icon: Icons.insights_rounded, title: 'Aún estamos empezando', text: 'Cuando completes entrenamientos aparecerán aquí tus estadísticas, racha y evolución.')])));
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.profile});
  final OnboardingState profile;
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const _TopBar(title: 'PERFIL'), const SizedBox(height: 26), const Text('Tu perfil', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 18), _InfoCard(icon: Icons.flag_outlined, title: 'Objetivos', text: profile.goals.join(', ')), _InfoCard(icon: Icons.speed_rounded, title: 'Nivel', text: profile.level?.name ?? '-'), _InfoCard(icon: Icons.schedule_rounded, title: 'Tiempo', text: profile.duration?.name ?? '-'), _InfoCard(icon: Icons.fitness_center_rounded, title: 'Equipamiento', text: profile.equipment.map((e) => e.name).join(', '))]));
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)), child: Icon(Icons.bolt_rounded, color: Theme.of(context).colorScheme.primary)), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2)), const Spacer(), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))]);
}

class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.title}); final String title; @override Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)); }
class _StatCard extends StatelessWidget { const _StatCard({required this.value, required this.label}); final String value, label; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: const Color(0xFF15181D), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)), child: Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11))])); }
class _InfoCard extends StatelessWidget { const _InfoCard({required this.icon, required this.title, required this.text}); final IconData icon; final String title, text; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF15181D), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 4), Text(text, style: const TextStyle(color: Colors.white60, height: 1.35))]))])); }
