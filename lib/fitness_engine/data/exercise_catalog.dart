import '../models/exercise.dart';

const exerciseCatalog = <Exercise>[
  // ============================================================
  // PECHO / EMPUJE
  // ============================================================

  Exercise(
    id: 'incline_push_up',
    name: 'Flexiones inclinadas',
    description:
    'Una variante más accesible de las flexiones tradicionales.',
    muscles: {
      MuscleGroup.chest,
      MuscleGroup.arms,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.push,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 20,

    // Progresión:
    // incline push-up → push-up
    progressionId: 'push_up',
  ),

  Exercise(
    id: 'push_up',
    name: 'Flexiones',
    description:
    'Mantén el cuerpo alineado y baja el pecho de forma controlada.',
    muscles: {
      MuscleGroup.chest,
      MuscleGroup.arms,
      MuscleGroup.shoulders,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.push,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 6,
    maxRepetitions: 20,

    // Regresión:
    // push-up → incline push-up
    regressionId: 'incline_push_up',

    // Progresión:
    // push-up → pike push-up
    progressionId: 'pike_push_up',
  ),

  Exercise(
    id: 'pike_push_up',
    name: 'Flexiones pike',
    description:
    'Adopta una posición en V y realiza una flexión enfocando el trabajo en hombros.',
    muscles: {
      MuscleGroup.shoulders,
      MuscleGroup.arms,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.push,
    level: 4,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 5,
    maxRepetitions: 12,

    // Regresión:
    // pike push-up → push-up
    regressionId: 'push_up',
  ),

  // ============================================================
  // PIERNAS
  // ============================================================

  Exercise(
    id: 'bodyweight_squat',
    name: 'Sentadillas',
    description:
    'Baja de forma controlada manteniendo las rodillas alineadas.',
    muscles: {
      MuscleGroup.legs,
      MuscleGroup.glutes,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.squat,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 25,
  ),

  Exercise(
    id: 'reverse_lunge',
    name: 'Zancadas atrás',
    description:
    'Da un paso atrás y controla la bajada antes de volver.',
    muscles: {
      MuscleGroup.legs,
      MuscleGroup.glutes,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.lunge,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 6,
    maxRepetitions: 16,
  ),

  Exercise(
    id: 'glute_bridge',
    name: 'Puente de glúteos',
    description:
    'Eleva la cadera apretando los glúteos en la parte superior.',
    muscles: {
      MuscleGroup.glutes,
      MuscleGroup.legs,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.hinge,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 20,
  ),

  // ============================================================
  // CORE
  // ============================================================

  Exercise(
    id: 'plank',
    name: 'Plancha',
    description:
    'Mantén el cuerpo recto y el abdomen activo durante todo el ejercicio.',
    muscles: {
      MuscleGroup.abs,
      MuscleGroup.shoulders,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.core,
    level: 2,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  Exercise(
    id: 'side_plank',
    name: 'Plancha lateral',
    description:
    'Mantén la cadera elevada y el cuerpo alineado.',
    muscles: {
      MuscleGroup.abs,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.core,
    level: 3,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 20,
  ),

  Exercise(
    id: 'mountain_climber',
    name: 'Mountain climbers',
    description:
    'Lleva las rodillas hacia el pecho manteniendo un ritmo estable.',
    muscles: {
      MuscleGroup.abs,
      MuscleGroup.legs,
      MuscleGroup.shoulders,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.cardio,
    level: 2,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  // ============================================================
  // CARDIO
  // ============================================================

  Exercise(
    id: 'jumping_jacks',
    name: 'Jumping jacks',
    description:
    'Realiza saltos controlados coordinando brazos y piernas.',
    muscles: {
      MuscleGroup.legs,
      MuscleGroup.shoulders,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.cardio,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  Exercise(
    id: 'high_knees',
    name: 'Rodillas al pecho',
    description:
    'Corre en el sitio elevando las rodillas de forma dinámica.',
    muscles: {
      MuscleGroup.legs,
      MuscleGroup.abs,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.cardio,
    level: 2,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  // ============================================================
  // ESPALDA
  // ============================================================

  Exercise(
    id: 'superman',
    name: 'Superman',
    description:
    'Eleva brazos y piernas de forma controlada manteniendo el abdomen activo.',
    muscles: {
      MuscleGroup.back,
      MuscleGroup.glutes,
    },
    equipment: {
      Equipment.none,
    },
    pattern: MovementPattern.pull,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 15,
  ),
];