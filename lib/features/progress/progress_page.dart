import 'package:flutter/material.dart';

import '../../fitness_engine/insights/insight.dart';
import '../../fitness_engine/insights/insights_engine.dart';
import '../../fitness_engine/storage/progress_repository.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, required this.progressRepository});

  final ProgressRepository progressRepository;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    widget.progressRepository.history.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    widget.progressRepository.history.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.progressRepository.history;
    final insights = const WorkoutInsightsEngine().analyze(history);
    final accent = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'PROGRESO',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${history.sessionCount}',
                label: 'SESIONES',
                accent: accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '${history.totalMinutes}',
                label: 'MINUTOS',
                accent: accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '${history.streak}',
                label: 'RACHA (DÍAS)',
                accent: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'ANÁLISIS',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map(
          (insight) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _InsightCard(insight: insight),
          ),
        ),
        if (history.all.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'HISTORIAL',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...history.all.take(10).map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryTile(
                    title: result.workoutTitle,
                    date: result.completedAt,
                    minutes: result.elapsedSeconds ~/ 60,
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final Insight insight;

  Color get _color => switch (insight.tone) {
        InsightTone.positive => const Color(0xFFB8F23D),
        InsightTone.info => Colors.white54,
        InsightTone.caution => const Color(0xFFFFC15E),
      };

  IconData get _icon => switch (insight.tone) {
        InsightTone.positive => Icons.trending_up_rounded,
        InsightTone.info => Icons.info_outline_rounded,
        InsightTone.caution => Icons.priority_high_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight.message,
              style: const TextStyle(
                color: Colors.white70,
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.date,
    required this.minutes,
  });

  final String title;
  final DateTime date;
  final int minutes;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$minutes min',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDate(date),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
