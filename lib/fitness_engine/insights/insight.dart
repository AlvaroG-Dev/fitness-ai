enum InsightTone {
  positive,
  info,
  caution,
}

/// Una observación generada por la capa de análisis a partir del
/// historial del usuario.
///
/// Esta es la pieza pensada para evolucionar hacia una IA real: hoy
/// [WorkoutInsightsEngine] la rellena con reglas fijas sobre
/// tendencias del historial, pero el tipo `Insight` (mensaje ya
/// explicado, en lenguaje natural, con una razón) es exactamente lo
/// que necesitarías como salida si mañana sustituyes o complementas
/// las reglas por un modelo que interprete el historial completo y
/// converse con el usuario. El motor sigue siendo quien garantiza
/// que los cambios de carga son coherentes y seguros; esta capa solo
/// interpreta y explica.
class Insight {
  const Insight({
    required this.message,
    required this.tone,
  });

  final String message;
  final InsightTone tone;
}
