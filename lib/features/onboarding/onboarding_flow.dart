import 'package:flutter/material.dart';

import '../../fitness_engine/storage/progress_repository.dart';
import '../home/home_shell.dart';
import 'onboarding_state.dart';
import 'onboarding_store.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.progressRepository,
    this.initialProfile,
  });

  final ProgressRepository progressRepository;

  final OnboardingState? initialProfile;

  @override
  State<OnboardingFlow> createState() =>
      _OnboardingFlowState();
}

class _OnboardingFlowState
    extends State<OnboardingFlow> {
  late final PageController controller;

  late final Set<String> goals;

  late final Set<Equipment> equipment;

  FitnessLevel? level;

  WorkoutDuration? duration;

  int dumbbellCount = 2;

  double dumbbellWeightKg = 5;

  int page = 0;

  @override
  void initState() {
    super.initState();

    controller =
        PageController();

    final initial =
        widget.initialProfile;

    goals =
    Set<String>.from(
      initial?.goals ?? {},
    );

    equipment =
    Set<Equipment>.from(
      initial?.equipment ??
          {
            Equipment.none,
          },
    );

    level =
        initial?.level;

    duration =
        initial?.duration;

    dumbbellCount =
        initial?.dumbbellCount ??
            2;

    dumbbellWeightKg =
        initial?.dumbbellWeightKg ??
            5;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get hasDumbbells =>
      equipment.contains(
        Equipment.dumbbells,
      );

  int get totalPages =>
      hasDumbbells ? 5 : 4;

  bool get ready {
    switch (page) {
      case 0:
        return goals.isNotEmpty;

      case 1:
        return level != null;

      case 2:
        return duration != null;

      case 3:
        if (hasDumbbells) {
          return true;
        }

        return equipment.isNotEmpty;

      case 4:
        return dumbbellCount > 0 &&
            dumbbellWeightKg > 0;

      default:
        return false;
    }
  }

  Future<void> next() async {
    if (!ready) {
      return;
    }

    if (page >= totalPages - 1) {
      await _finish();

      return;
    }

    await controller.nextPage(
      duration:
      const Duration(
        milliseconds: 220,
      ),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final profile =
    OnboardingState(
      goals:
      Set<String>.from(goals),
      level:
      level,
      duration:
      duration,
      equipment:
      Set<Equipment>.from(
        equipment,
      ),
      dumbbellCount:
      hasDumbbells
          ? dumbbellCount
          : 0,
      dumbbellWeightKg:
      hasDumbbells
          ? dumbbellWeightKg
          : 0,
    );

    await const OnboardingStore()
        .save(profile);

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            HomeShell(
              profile: profile,
              progressRepository:
              widget
                  .progressRepository,
            ),
      ),
    );
  }

  void toggleGoal(
      String id,
      ) {
    setState(() {
      if (id == 'full_body') {
        goals
          ..clear()
          ..add(id);

        return;
      }

      goals.remove(
        'full_body',
      );

      if (!goals.add(id)) {
        goals.remove(id);
      }
    });
  }

  void toggleEquipment(
      Equipment value,
      ) {
    setState(() {
      if (value ==
          Equipment.none) {
        equipment
          ..clear()
          ..add(
            Equipment.none,
          );

        return;
      }

      equipment.remove(
        Equipment.none,
      );

      if (!equipment.add(value)) {
        equipment.remove(value);
      }

      if (equipment.isEmpty) {
        equipment.add(
          Equipment.none,
        );
      }
    });
  }

  void back() {
    if (page == 0) {
      return;
    }

    controller.previousPage(
      duration:
      const Duration(
        milliseconds: 180,
      ),
      curve: Curves.easeOut,
    );
  }

  void _setDumbbellCount(
      double value,
      ) {
    setState(() {
      dumbbellCount =
          value.round();
    });
  }

  void _setDumbbellWeight(
      double value,
      ) {
    setState(() {
      dumbbellWeightKg =
          value;
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final bottom =
        MediaQuery.viewPaddingOf(
          context,
        ).bottom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              page: page,
              totalPages: totalPages,
              onBack:
              page == 0
                  ? null
                  : back,
            ),

            Expanded(
              child: PageView(
                controller:
                controller,
                physics:
                const NeverScrollableScrollPhysics(),

                onPageChanged:
                    (value) {
                  setState(
                        () => page = value,
                  );
                },

                children: [
                  _GoalsStep(
                    selected:
                    goals,
                    onTap:
                    toggleGoal,
                  ),

                  _SingleChoiceStep<
                      FitnessLevel>(
                    title:
                    '¿Cuál es tu nivel?',
                    subtitle:
                    'Podremos ajustarlo según tu progreso.',
                    values: const [
                      (
                      FitnessLevel
                          .beginner,
                      'Principiante',
                      'Estoy empezando',
                      ),
                      (
                      FitnessLevel
                          .intermediate,
                      'Intermedio',
                      'Entreno con frecuencia',
                      ),
                      (
                      FitnessLevel
                          .advanced,
                      'Avanzado',
                      'Tengo experiencia',
                      ),
                    ],
                    selected:
                    level,
                    onTap:
                        (value) {
                      setState(
                            () =>
                        level =
                            value,
                      );
                    },
                  ),

                  _SingleChoiceStep<
                      WorkoutDuration>(
                    title:
                    '¿Cuánto tiempo tienes?',
                    subtitle:
                    'La sesión se adaptará al tiempo disponible.',
                    values: const [
                      (
                      WorkoutDuration
                          .ten,
                      '10 min',
                      'Rápido y directo',
                      ),
                      (
                      WorkoutDuration
                          .fifteen,
                      '15 min',
                      'Sesión corta',
                      ),
                      (
                      WorkoutDuration
                          .twenty,
                      '20 min',
                      'Equilibrado',
                      ),
                      (
                      WorkoutDuration
                          .thirty,
                      '30 min',
                      'Sesión completa',
                      ),
                      (
                      WorkoutDuration
                          .fortyFivePlus,
                      '45+ min',
                      'Tengo tiempo',
                      ),
                    ],
                    selected:
                    duration,
                    onTap:
                        (value) {
                      setState(
                            () =>
                        duration =
                            value,
                      );
                    },
                  ),

                  _EquipmentStep(
                    selected:
                    equipment,
                    onTap:
                    toggleEquipment,
                  ),

                  if (hasDumbbells)
                    _DumbbellDetailsStep(
                      count:
                      dumbbellCount,
                      weight:
                      dumbbellWeightKg,
                      onCountChanged:
                      _setDumbbellCount,
                      onWeightChanged:
                      _setDumbbellWeight,
                    ),
                ],
              ),
            ),

            Padding(
              padding:
              EdgeInsets.fromLTRB(
                24,
                8,
                24,
                10 + bottom,
              ),
              child: Column(
                children: [
                  Row(
                    children:
                    List.generate(
                      totalPages,
                          (index) =>
                          Expanded(
                            child:
                            AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                180,
                              ),
                              height: 4,
                              margin:
                              EdgeInsets.only(
                                right:
                                index ==
                                    totalPages -
                                        1
                                    ? 0
                                    : 6,
                              ),
                              decoration:
                              BoxDecoration(
                                color: index <=
                                    page
                                    ? Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .primary
                                    : Colors
                                    .white12,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  4,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 54,
                    child:
                    FilledButton(
                      onPressed:
                      ready
                          ? next
                          : null,
                      child: Text(
                        page ==
                            totalPages -
                                1
                            ? 'CREAR MI PLAN'
                            : 'CONTINUAR',
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

// ============================================================
// HEADER
// ============================================================

class _Header
    extends StatelessWidget {
  const _Header({
    required this.page,
    required this.totalPages,
    required this.onBack,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onBack;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),
      child: Container(
        height: 54,
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
            SizedBox(
              width: 48,
              child:
              onBack == null
                  ? null
                  : IconButton(
                onPressed:
                onBack,
                icon:
                const Icon(
                  Icons
                      .arrow_back_rounded,
                ),
              ),
            ),

            const Expanded(
              child: Text(
                'FITNESS AI',
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing:
                  2.4,
                ),
              ),
            ),

            SizedBox(
              width: 48,
              child: Center(
                child: Text(
                  '${page + 1}/$totalPages',
                  style:
                  const TextStyle(
                    fontSize: 12,
                    color:
                    Colors.white54,
                    fontWeight:
                    FontWeight.w700,
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

// ============================================================
// GOALS
// ============================================================

class _GoalsStep
    extends StatelessWidget {
  const _GoalsStep({
    required this.selected,
    required this.onTap,
  });

  final Set<String> selected;
  final ValueChanged<String> onTap;

  static const items = [
    (
    'arms',
    'Brazos',
    Icons.fitness_center,
    ),
    (
    'chest',
    'Pecho',
    Icons.accessibility_new,
    ),
    (
    'abs',
    'Abdominales',
    Icons.grid_view_rounded,
    ),
    (
    'legs',
    'Piernas',
    Icons.directions_run,
    ),
    (
    'back',
    'Espalda',
    Icons.airline_seat_recline_normal,
    ),
    (
    'full_body',
    'Todo el cuerpo',
    Icons.person,
    ),
  ];

  @override
  Widget build(
      BuildContext context,
      ) {
    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16,
      ),
      children: [
        const Text(
          '¿Qué quieres\nmejorar?',
          style:
          TextStyle(
            fontSize: 38,
            height: 1.05,
            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          'Elige una o varias zonas.',
          style:
          TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.62,
            ),
            fontSize: 16,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        ...items.map(
              (item) => Padding(
            padding:
            const EdgeInsets.only(
              bottom: 10,
            ),
            child: _Tile(
              title:
              item.$2,
              icon:
              item.$3,
              selected:
              selected.contains(
                item.$1,
              ),
              onTap: () =>
                  onTap(
                    item.$1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SINGLE CHOICE
// ============================================================

class _SingleChoiceStep<T>
    extends StatelessWidget {
  const _SingleChoiceStep({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;

  final List<
      (T, String, String)> values;

  final T? selected;

  final ValueChanged<T> onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16,
      ),
      children: [
        Text(
          title,
          style:
          const TextStyle(
            fontSize: 36,
            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          subtitle,
          style:
          TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.62,
            ),
            fontSize: 16,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        ...values.map(
              (item) => Padding(
            padding:
            const EdgeInsets.only(
              bottom: 10,
            ),
            child: _Tile(
              title:
              item.$2,
              subtitle:
              item.$3,
              selected:
              selected ==
                  item.$1,
              onTap: () =>
                  onTap(
                    item.$1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EQUIPMENT
// ============================================================

class _EquipmentStep
    extends StatelessWidget {
  const _EquipmentStep({
    required this.selected,
    required this.onTap,
  });

  final Set<Equipment> selected;

  final ValueChanged<Equipment> onTap;

  static const items = [
    (
    Equipment.none,
    'Nada',
    'Solo peso corporal',
    Icons.accessibility_new,
    ),
    (
    Equipment.backpack,
    'Mochila',
    'Puedes añadir peso',
    Icons.backpack_outlined,
    ),
    (
    Equipment.bands,
    'Bandas',
    'Bandas elásticas',
    Icons.cable_rounded,
    ),
    (
    Equipment.dumbbells,
    'Mancuernas',
    'Una o varias mancuernas',
    Icons.fitness_center_rounded,
    ),
  ];

  @override
  Widget build(
      BuildContext context,
      ) {
    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16,
      ),
      children: [
        const Text(
          '¿Qué tienes\ndisponible?',
          style:
          TextStyle(
            fontSize: 36,
            height: 1.05,
            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          'Puedes seleccionar varias opciones.',
          style:
          TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.62,
            ),
            fontSize: 16,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        ...items.map(
              (item) => Padding(
            padding:
            const EdgeInsets.only(
              bottom: 10,
            ),
            child: _Tile(
              title:
              item.$2,
              subtitle:
              item.$3,
              icon:
              item.$4,
              selected:
              selected.contains(
                item.$1,
              ),
              onTap: () =>
                  onTap(
                    item.$1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DUMBBELLS
// ============================================================

class _DumbbellDetailsStep
    extends StatelessWidget {
  const _DumbbellDetailsStep({
    required this.count,
    required this.weight,
    required this.onCountChanged,
    required this.onWeightChanged,
  });

  final int count;
  final double weight;

  final ValueChanged<double>
  onCountChanged;

  final ValueChanged<double>
  onWeightChanged;

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
        24,
        16,
        24,
        20,
      ),
      children: [
        const Text(
          'Cuéntame sobre\ntus mancuernas',
          style:
          TextStyle(
            fontSize: 36,
            height: 1.05,
            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        const Text(
          'Así podremos adaptar mejor los ejercicios con peso.',
          style:
          TextStyle(
            color:
            Colors.white54,
            fontSize: 16,
          ),
        ),

        const SizedBox(
          height: 32,
        ),

        Container(
          padding:
          const EdgeInsets.all(
            20,
          ),
          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFF15181D,
            ),
            borderRadius:
            BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color:
              Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
            children: [
              const Text(
                'CANTIDAD',
                style:
                TextStyle(
                  color:
                  Colors.white54,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing:
                  1.5,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                '$count ${count == 1 ? 'mancuerna' : 'mancuernas'}',
                style:
                TextStyle(
                  color:
                  accent,
                  fontSize: 25,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value:
                count.toDouble(),
                onChanged:
                onCountChanged,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'PESO DE CADA MANCUERNA',
                style:
                TextStyle(
                  color:
                  Colors.white54,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing:
                  1.5,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                style:
                TextStyle(
                  color:
                  accent,
                  fontSize: 25,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              Slider(
                min: 0.5,
                max: 50,
                divisions: 99,
                value:
                weight,
                onChanged:
                onWeightChanged,
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        Container(
          padding:
          const EdgeInsets.all(
            16,
          ),
          decoration:
          BoxDecoration(
            color:
            accent.withValues(
              alpha: 0.08,
            ),
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color:
              accent.withValues(
                alpha: 0.2,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color:
                accent,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Tienes una mancuerna de ${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg.'
                      : 'Tienes $count mancuernas de ${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg cada una.',
                  style:
                  const TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 13,
                    height:
                    1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TILE
// ============================================================

class _Tile
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return InkWell(
      borderRadius:
      BorderRadius.circular(
        18,
      ),
      onTap: onTap,
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 160,
        ),
        padding:
        const EdgeInsets.all(
          17,
        ),
        decoration:
        BoxDecoration(
          color: selected
              ? accent.withValues(
            alpha: 0.14,
          )
              : const Color(
            0xFF15181D,
          ),
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: selected
                ? accent
                : Colors.white10,
            width:
            selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: selected
                    ? accent
                    : Colors.white70,
                size: 28,
              ),
              const SizedBox(
                width: 14,
              ),
            ],

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
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  if (subtitle !=
                      null) ...[
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle!,
                      style:
                      TextStyle(
                        color: Colors
                            .white
                            .withValues(
                          alpha:
                          0.56,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons
                  .check_circle
                  : Icons
                  .circle_outlined,
              color: selected
                  ? accent
                  : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}