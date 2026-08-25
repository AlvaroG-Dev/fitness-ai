import '../models/exercise.dart';

/// Catálogo de ejercicios.
///
/// Reglas que sigue este catálogo (importantes para la seguridad
/// y eficacia de los entrenamientos generados):
///
/// 1. El calentamiento SIEMPRE usa ejercicios [ExerciseRole.warmup]:
///    movilidad articular y activación de baja intensidad. Nunca se
///    reutilizan ejercicios de trabajo "en frío" como calentamiento.
/// 2. El enfriamiento SIEMPRE usa ejercicios [ExerciseRole.cooldown]:
///    estiramientos estáticos suaves.
/// 3. Cada patrón de movimiento tiene al menos una variante de nivel
///    bajo (1) y otra de nivel alto (4-5), con cadenas explícitas de
///    progresión/regresión, para que el motor pueda subir o bajar la
///    dificultad sin salirse del patrón.
const exerciseCatalog = <Exercise>[
  // ============================================================
  // CALENTAMIENTO (movilidad y activación, sin carga real)
  // ============================================================

  Exercise(
    id: 'warmup_arm_circles',
    name: 'Círculos de brazos',
    description: 'Moviliza los hombros con círculos amplios.',
    cue: 'Hombros relajados, círculos grandes y controlados.',
    muscles: {MuscleGroup.shoulders},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'warmup_cat_cow',
    name: 'Gato-camello',
    description: 'Moviliza la columna en cuadrupedia.',
    cue: 'Redondea y arquea la espalda despacio, sin forzar.',
    muscles: {MuscleGroup.back, MuscleGroup.abs},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'warmup_hip_circles',
    name: 'Círculos de cadera',
    description: 'Moviliza la cadera en todas direcciones.',
    cue: 'Rodillas ligeramente flexionadas, movimiento amplio.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'warmup_leg_swings',
    name: 'Balanceo de piernas',
    description: 'Activa cadera e isquiotibiales antes del tren inferior.',
    cue: 'Apóyate en algo si lo necesitas, controla el rango.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'warmup_march',
    name: 'Marcha en el sitio',
    description: 'Eleva la frecuencia cardíaca de forma progresiva.',
    cue: 'Ritmo cómodo, brazos acompañando el movimiento.',
    muscles: {MuscleGroup.legs},
    equipment: {Equipment.none},
    pattern: MovementPattern.cardio,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  Exercise(
    id: 'warmup_bodyweight_good_morning',
    name: 'Bisagra de cadera suave',
    description: 'Activa isquiotibiales y glúteos con rango controlado.',
    cue: 'Espalda neutra, empuja la cadera hacia atrás.',
    muscles: {MuscleGroup.legs, MuscleGroup.back},
    equipment: {Equipment.none},
    pattern: MovementPattern.hinge,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 10,
  ),

  Exercise(
    id: 'warmup_scapular_push_up',
    name: 'Activación escapular',
    description: 'Prepara hombros y muñecas para el trabajo de empuje.',
    cue: 'En posición de plancha, junta y separa las escápulas.',
    muscles: {MuscleGroup.shoulders, MuscleGroup.chest},
    equipment: {Equipment.none},
    pattern: MovementPattern.push,
    role: ExerciseRole.warmup,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 10,
  ),

  // ============================================================
  // ENFRIAMIENTO (estiramientos estáticos suaves)
  // ============================================================

  Exercise(
    id: 'cooldown_childs_pose',
    name: 'Postura del niño',
    description: 'Estira espalda baja y cadera.',
    cue: 'Respira despacio, sin rebotes.',
    muscles: {MuscleGroup.back},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.cooldown,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  Exercise(
    id: 'cooldown_quad_stretch',
    name: 'Estiramiento de cuádriceps',
    description: 'Estira la parte frontal del muslo, de pie.',
    cue: 'Rodillas juntas, cadera hacia delante, sin dolor.',
    muscles: {MuscleGroup.legs},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.cooldown,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'cooldown_hamstring_stretch',
    name: 'Estiramiento de isquiotibiales',
    description: 'Estira la parte posterior de la pierna, sentado o de pie.',
    cue: 'Espalda larga, no fuerces hasta sentir dolor.',
    muscles: {MuscleGroup.legs},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.cooldown,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'cooldown_chest_doorway_stretch',
    name: 'Estiramiento de pecho',
    description: 'Abre el pecho y los hombros tras el trabajo de empuje.',
    cue: 'Apoya el antebrazo y gira el tronco suavemente.',
    muscles: {MuscleGroup.chest, MuscleGroup.shoulders},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.cooldown,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  Exercise(
    id: 'cooldown_seated_twist',
    name: 'Rotación de tronco sentado',
    description: 'Estira la zona lumbar y el core.',
    cue: 'Gira desde el tronco, no fuerces el cuello.',
    muscles: {MuscleGroup.abs, MuscleGroup.back},
    equipment: {Equipment.none},
    pattern: MovementPattern.mobility,
    role: ExerciseRole.cooldown,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 25,
  ),

  // ============================================================
  // PECHO / EMPUJE
  // ============================================================

  Exercise(
    id: 'wall_push_up',
    name: 'Flexiones en pared',
    description: 'La variante más accesible de empuje, ideal para empezar.',
    cue: 'Cuerpo recto, codos a 45º, empuja sin bloquear.',
    muscles: {MuscleGroup.chest, MuscleGroup.arms},
    equipment: {Equipment.none},
    pattern: MovementPattern.push,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 20,
    progressionId: 'incline_push_up',
  ),

  Exercise(
    id: 'incline_push_up',
    name: 'Flexiones inclinadas',
    description: 'Una variante más accesible de las flexiones tradicionales.',
    cue: 'Cadera alineada con los hombros, no la dejes caer.',
    muscles: {MuscleGroup.chest, MuscleGroup.arms},
    equipment: {Equipment.none},
    pattern: MovementPattern.push,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 20,
    regressionId: 'wall_push_up',
    progressionId: 'push_up',
  ),

  Exercise(
    id: 'push_up',
    name: 'Flexiones',
    description: 'Mantén el cuerpo alineado y baja el pecho de forma controlada.',
    cue: 'Cuerpo en línea recta, codos a 45º del torso.',
    muscles: {MuscleGroup.chest, MuscleGroup.arms, MuscleGroup.shoulders},
    equipment: {Equipment.none},
    pattern: MovementPattern.push,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 6,
    maxRepetitions: 20,
    regressionId: 'incline_push_up',
    progressionId: 'diamond_push_up',
  ),

  Exercise(
    id: 'diamond_push_up',
    name: 'Flexiones diamante',
    description: 'Variante estrecha que exige más de tríceps y pecho interno.',
    cue: 'Manos formando un diamante bajo el pecho, codos pegados.',
    muscles: {MuscleGroup.chest, MuscleGroup.arms},
    equipment: {Equipment.none},
    pattern: MovementPattern.push,
    level: 3,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 5,
    maxRepetitions: 15,
    regressionId: 'push_up',
    progressionId: 'pike_push_up',
  ),

  Exercise(
    id: 'pike_push_up',
    name: 'Flexiones pike',
    description: 'Adopta una posición en V y realiza una flexión enfocando el trabajo en hombros.',
    cue: 'Cadera elevada, mira hacia los pies, baja la cabeza con control.',
    muscles: {MuscleGroup.shoulders, MuscleGroup.arms},
    equipment: {Equipment.none},
    pattern: MovementPattern.push,
    level: 4,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 5,
    maxRepetitions: 12,
    regressionId: 'diamond_push_up',
  ),

  Exercise(
    id: 'backpack_floor_press',
    name: 'Press de suelo con mochila',
    description: 'Press de pecho tumbado usando una mochila como resistencia.',
    cue: 'Baja los codos 45º, controla la bajada, no rebotes en el suelo.',
    muscles: {MuscleGroup.chest, MuscleGroup.arms},
    equipment: {Equipment.backpack},
    pattern: MovementPattern.push,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 15,
  ),

  Exercise(
    id: 'dumbbell_shoulder_press',
    name: 'Press de hombros con mancuernas',
    description: 'Press vertical de pie o sentado para hombros.',
    cue: 'Core activo, no arquees la zona lumbar.',
    muscles: {MuscleGroup.shoulders, MuscleGroup.arms},
    equipment: {Equipment.dumbbells},
    pattern: MovementPattern.push,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 15,
  ),

  // ============================================================
  // ESPALDA / TIRÓN
  // ============================================================

  Exercise(
    id: 'bird_dog',
    name: 'Bird dog',
    description: 'Estabiliza el core mientras extiendes brazo y pierna opuestos.',
    cue: 'Cadera y hombros nivelados, movimiento lento.',
    muscles: {MuscleGroup.back, MuscleGroup.abs},
    equipment: {Equipment.none},
    pattern: MovementPattern.pull,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 16,
    progressionId: 'superman',
  ),

  Exercise(
    id: 'superman',
    name: 'Superman',
    description: 'Eleva brazos y piernas de forma controlada manteniendo el abdomen activo.',
    cue: 'Eleva sin buscar altura máxima; prioriza el control lumbar.',
    muscles: {MuscleGroup.back, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.pull,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 15,
    regressionId: 'bird_dog',
  ),

  Exercise(
    id: 'band_row',
    name: 'Remo con banda',
    description: 'Tirón horizontal con banda elástica anclada.',
    cue: 'Junta las escápulas al final del recorrido, codos pegados al cuerpo.',
    muscles: {MuscleGroup.back, MuscleGroup.arms},
    equipment: {Equipment.resistanceBand},
    pattern: MovementPattern.pull,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 10,
    maxRepetitions: 18,
  ),

  Exercise(
    id: 'dumbbell_bent_over_row',
    name: 'Remo inclinado con mancuernas',
    description: 'Tirón horizontal con el tronco inclinado.',
    cue: 'Espalda plana, bisagra de cadera, no redondees la zona lumbar.',
    muscles: {MuscleGroup.back, MuscleGroup.arms},
    equipment: {Equipment.dumbbells},
    pattern: MovementPattern.pull,
    level: 3,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 15,
  ),

  // ============================================================
  // PIERNAS / SENTADILLA
  // ============================================================

  Exercise(
    id: 'chair_squat',
    name: 'Sentadilla a silla',
    description: 'Sentadilla guiada tocando una silla, ideal para aprender el patrón.',
    cue: 'Baja hasta rozar el asiento, rodillas en línea con los pies.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.squat,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 20,
    progressionId: 'bodyweight_squat',
  ),

  Exercise(
    id: 'bodyweight_squat',
    name: 'Sentadillas',
    description: 'Baja de forma controlada manteniendo las rodillas alineadas.',
    cue: 'Pecho arriba, rodillas alineadas con los pies, baja hasta 90º.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.squat,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 25,
    regressionId: 'chair_squat',
    progressionId: 'jump_squat',
  ),

  Exercise(
    id: 'goblet_squat',
    name: 'Sentadilla goblet con mancuerna',
    description: 'Sentadilla sujetando una mancuerna a la altura del pecho.',
    cue: 'Codos apuntando al suelo, espalda recta durante todo el recorrido.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.dumbbells},
    pattern: MovementPattern.squat,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 18,
  ),

  Exercise(
    id: 'jump_squat',
    name: 'Sentadilla con salto',
    description: 'Variante explosiva de la sentadilla con impacto en la recepción.',
    cue: 'Aterriza suave, flexionando rodillas y cadera.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.squat,
    level: 4,
    highImpact: true,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 6,
    maxRepetitions: 15,
    regressionId: 'bodyweight_squat',
  ),

  // ============================================================
  // PIERNAS / ZANCADA
  // ============================================================

  Exercise(
    id: 'reverse_lunge',
    name: 'Zancadas atrás',
    description: 'Da un paso atrás y controla la bajada antes de volver.',
    cue: 'Rodilla trasera hacia el suelo sin golpearlo, torso erguido.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.lunge,
    level: 2,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 6,
    maxRepetitions: 16,
    progressionId: 'walking_lunge',
  ),

  Exercise(
    id: 'walking_lunge',
    name: 'Zancadas caminando',
    description: 'Zancadas alternas avanzando, mayor exigencia de equilibrio.',
    cue: 'Paso amplio, rodilla delantera alineada con el tobillo.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes},
    equipment: {Equipment.none},
    pattern: MovementPattern.lunge,
    level: 3,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 16,
    regressionId: 'reverse_lunge',
  ),

  // ============================================================
  // PIERNAS / CADERA (HINGE)
  // ============================================================

  Exercise(
    id: 'glute_bridge',
    name: 'Puente de glúteos',
    description: 'Eleva la cadera apretando los glúteos en la parte superior.',
    cue: 'Empuja con los talones, evita arquear en exceso la zona lumbar.',
    muscles: {MuscleGroup.glutes, MuscleGroup.legs},
    equipment: {Equipment.none},
    pattern: MovementPattern.hinge,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 20,
    progressionId: 'single_leg_glute_bridge',
  ),

  Exercise(
    id: 'single_leg_glute_bridge',
    name: 'Puente de glúteos a una pierna',
    description: 'Variante unilateral que exige más estabilidad de cadera.',
    cue: 'Cadera nivelada, evita rotar el tronco.',
    muscles: {MuscleGroup.glutes, MuscleGroup.legs},
    equipment: {Equipment.none},
    pattern: MovementPattern.hinge,
    level: 3,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 6,
    maxRepetitions: 14,
    regressionId: 'glute_bridge',
  ),

  Exercise(
    id: 'dumbbell_romanian_deadlift',
    name: 'Peso muerto rumano con mancuernas',
    description: 'Bisagra de cadera cargada para isquiotibiales y glúteos.',
    cue: 'Espalda neutra en todo momento, las mancuernas rozan las piernas.',
    muscles: {MuscleGroup.legs, MuscleGroup.glutes, MuscleGroup.back},
    equipment: {Equipment.dumbbells},
    pattern: MovementPattern.hinge,
    level: 3,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 15,
  ),

  // ============================================================
  // CORE
  // ============================================================

  Exercise(
    id: 'dead_bug',
    name: 'Dead bug',
    description: 'Ejercicio de core de bajo impacto lumbar, ideal para empezar.',
    cue: 'Zona lumbar pegada al suelo durante todo el movimiento.',
    muscles: {MuscleGroup.abs},
    equipment: {Equipment.none},
    pattern: MovementPattern.core,
    level: 1,
    metric: ExerciseMetric.repetitions,
    minRepetitions: 8,
    maxRepetitions: 16,
    progressionId: 'plank',
  ),

  Exercise(
    id: 'plank',
    name: 'Plancha',
    description: 'Mantén el cuerpo recto y el abdomen activo durante todo el ejercicio.',
    cue: 'Cadera alineada, no la eleves ni la dejes caer.',
    muscles: {MuscleGroup.abs, MuscleGroup.shoulders},
    equipment: {Equipment.none},
    pattern: MovementPattern.core,
    level: 2,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
    regressionId: 'dead_bug',
    progressionId: 'side_plank',
  ),

  Exercise(
    id: 'side_plank',
    name: 'Plancha lateral',
    description: 'Mantén la cadera elevada y el cuerpo alineado.',
    cue: 'Cadera arriba, apila los hombros y evita rotar el tronco.',
    muscles: {MuscleGroup.abs},
    equipment: {Equipment.none},
    pattern: MovementPattern.core,
    level: 3,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 20,
    regressionId: 'plank',
  ),

  // ============================================================
  // CARDIO (impacto moderado-alto: se dosifican con cuidado)
  // ============================================================

  Exercise(
    id: 'step_touch',
    name: 'Step touch lateral',
    description: 'Cardio de bajo impacto para elevar pulsaciones sin saltar.',
    cue: 'Pasos laterales controlados, rodillas suaves.',
    muscles: {MuscleGroup.legs},
    equipment: {Equipment.none},
    pattern: MovementPattern.cardio,
    level: 1,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  Exercise(
    id: 'jumping_jacks',
    name: 'Jumping jacks',
    description: 'Realiza saltos controlados coordinando brazos y piernas.',
    cue: 'Aterriza con las rodillas suaves, no bloqueadas.',
    muscles: {MuscleGroup.legs, MuscleGroup.shoulders},
    equipment: {Equipment.none},
    pattern: MovementPattern.cardio,
    level: 2,
    highImpact: true,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
    regressionId: 'step_touch',
  ),

  Exercise(
    id: 'high_knees',
    name: 'Rodillas al pecho',
    description: 'Corre en el sitio elevando las rodillas de forma dinámica.',
    cue: 'Apoyo en la parte delantera del pie, ritmo sostenible.',
    muscles: {MuscleGroup.legs, MuscleGroup.abs},
    equipment: {Equipment.none},
    pattern: MovementPattern.cardio,
    level: 2,
    highImpact: true,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),

  Exercise(
    id: 'mountain_climber',
    name: 'Mountain climbers',
    description: 'Lleva las rodillas hacia el pecho manteniendo un ritmo estable.',
    cue: 'Cadera baja y estable, no la eleves en exceso.',
    muscles: {MuscleGroup.abs, MuscleGroup.legs, MuscleGroup.shoulders},
    equipment: {Equipment.none},
    pattern: MovementPattern.cardio,
    level: 2,
    metric: ExerciseMetric.seconds,
    defaultSeconds: 30,
  ),
];
