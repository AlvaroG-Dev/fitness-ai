import '../data/exercise_catalog.dart';
import '../models/exercise.dart';
import '../models/workout_feedback.dart';
import '../models/workout_result.dart';
import '../storage/workout_history.dart';
import 'insight.dart';

/// La "IA" del diagrama: se construye ENCIMA del motor y del
/// historial, nunca sustituye sus decisiones. Mientras el
/// [ProgressionEngine] decide sesión a sesión (dato último ->
/// regla fija), este motor de insights mira varias sesiones a la
/// vez para detectar patrones y explicarlos en lenguaje natural.
///
/// Hoy es un conjunto de reglas deterministas; es intencionadamente
/// simple, legible y sin dependencias externas para que:
///  1. funcione sin backend ni claves de API, y
///  2. sea fácil de sustituir/ampliar el día que quieras que estas
///     mismas señales las interprete un modelo de lenguaje (eso ya
///     requeriría una llamada a un servicio de IA desde tu propio
///     backend, algo fuera del alcance de este archivo).
class WorkoutInsightsEngine {
  const WorkoutInsightsEngine();

  List<Insight> analyze(WorkoutHistoryStore history) {
    final insights = <Insight>[];

    final recovery = _recoveryCaution(history);
    if (recovery != null) insights.add(recovery);

    final trend = _overallTrend(history);
    if (trend != null) insights.add(trend);

    final pattern = _strugglingPattern(history);
    if (pattern != null) insights.add(pattern);

    final streak = _streakInsight(history);
    if (streak != null) insights.add(streak);

    if (insights.isEmpty) {
      insights.add(
        const Insight(
          message: 'Completa alguna sesión más para que podamos '
              'empezar a detectar patrones en tu entrenamiento.',
          tone: InsightTone.info,
        ),
      );
    }

    return insights;
  }

  Insight? _recoveryCaution(WorkoutHistoryStore history) {
    final hours = history.hoursSinceLastSession;

    if (hours == null || hours >= 16) {
      return null;
    }

    return const Insight(
      message: 'Han pasado menos de 16 horas desde tu última sesión. '
          'Si vas a trabajar los mismos grupos musculares, prioriza '
          'la recuperación: hidratación, sueño y, si notas fatiga, '
          'baja la intensidad de hoy.',
      tone: InsightTone.caution,
    );
  }

  Insight? _overallTrend(WorkoutHistoryStore history) {
    final recent = history.all.take(3).toList();

    if (recent.length < 3) {
      return null;
    }

    final allHard = recent.every(
      (w) =>
          w.feedback == WorkoutDifficulty.hard ||
          w.feedback == WorkoutDifficulty.veryHard,
    );

    if (allHard) {
      return const Insight(
        message: 'Tus últimas 3 sesiones te han resultado exigentes. '
            'Vamos a moderar el volumen y priorizar la recuperación '
            'antes de seguir subiendo la carga.',
        tone: InsightTone.caution,
      );
    }

    final allEasy = recent.every(
      (w) =>
          w.feedback == WorkoutDifficulty.veryEasy ||
          w.feedback == WorkoutDifficulty.easy,
    );

    if (allEasy) {
      return const Insight(
        message: 'Tus últimas 3 sesiones te han resultado ligeras. '
            'Aumentaremos progresivamente la exigencia en los '
            'próximos entrenamientos.',
        tone: InsightTone.positive,
      );
    }

    return null;
  }

  /// Busca si un patrón de movimiento concreto (empuje, sentadilla...)
  /// ha sido "duro" o "muy duro" en sus últimas 3 apariciones,
  /// independientemente del ejercicio exacto (cuenta variantes de la
  /// misma cadena de progresión).
  Insight? _strugglingPattern(WorkoutHistoryStore history) {
    final byPattern = <MovementPattern, List<WorkoutDifficulty>>{};

    for (final workout in history.all) {
      for (final result in workout.exercises) {
        final exercise = _findExercise(result.exerciseId);
        if (exercise == null) continue;

        final list = byPattern.putIfAbsent(
          exercise.pattern,
          () => [],
        );

        if (list.length < 3) {
          list.add(result.feedback);
        }
      }
    }

    for (final entry in byPattern.entries) {
      if (entry.value.length < 3) continue;

      final allHard = entry.value.every(
        (d) =>
            d == WorkoutDifficulty.hard || d == WorkoutDifficulty.veryHard,
      );

      if (allHard) {
        return Insight(
          message: 'Llevas 3 sesiones seguidas con dificultad alta en '
              'ejercicios de ${_patternLabel(entry.key)}. Tu rendimiento '
              'no está mejorando en ese patrón, así que probablemente '
              'convenga cambiar a una variante más accesible durante '
              'unos entrenamientos antes de retomar la progresión.',
          tone: InsightTone.caution,
        );
      }
    }

    return null;
  }

  Insight? _streakInsight(WorkoutHistoryStore history) {
    final streak = history.streak;

    if (streak < 3) {
      return null;
    }

    return Insight(
      message: 'Llevas $streak días seguidos entrenando. Buen ritmo: '
          'recuerda que el descanso también forma parte del progreso.',
      tone: InsightTone.positive,
    );
  }

  Exercise? _findExercise(String id) {
    for (final candidate in exerciseCatalog) {
      if (candidate.id == id) return candidate;
    }
    return null;
  }

  String _patternLabel(MovementPattern pattern) {
    return switch (pattern) {
      MovementPattern.push => 'empuje (pecho/hombro/tríceps)',
      MovementPattern.pull => 'tirón/espalda',
      MovementPattern.squat => 'sentadilla',
      MovementPattern.hinge => 'cadera (isquios/glúteo)',
      MovementPattern.lunge => 'zancada',
      MovementPattern.core => 'core',
      MovementPattern.cardio => 'cardio',
      MovementPattern.mobility => 'movilidad',
    };
  }
}
