import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_ai/fitness_engine/data/exercise_catalog.dart';
import 'package:fitness_ai/fitness_engine/models/workout_feedback.dart';
import 'package:fitness_ai/fitness_engine/models/workout_result.dart';
import 'package:fitness_ai/fitness_engine/progression/progression_engine.dart';
import 'package:fitness_ai/fitness_engine/progression/progression_service.dart';
import 'package:fitness_ai/fitness_engine/storage/progress_repository.dart';
import 'package:fitness_ai/fitness_engine/storage/workout_history.dart';
import 'package:fitness_ai/features/onboarding/onboarding_state.dart';
import 'package:fitness_ai/features/workout/workout_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WorkoutHistoryStore history;
  late ProgressRepository repository;
  late ProgressionService progressionService;

  setUp(() async {
    history = WorkoutHistoryStore.instance;

    await history.clear();

    progressionService = const ProgressionService();

    repository = ProgressRepository(
      history: history,
      progressionService: progressionService,
    );
  });

  tearDown(() async {
    await history.clear();
  });

  group('ProgressionEngine', () {
    test('veryHard en push_up regresa a incline_push_up', () {
      final pushUp = exerciseCatalog.firstWhere(
            (exercise) => exercise.id == 'push_up',
      );

      final result = progressionService.calculateNext(
        ExerciseResult(
          exerciseId: pushUp.id,
          value: 10,
          feedback: WorkoutDifficulty.veryHard,
        ),
      );

      expect(result, isNotNull);
      expect(result!.action, ProgressionAction.regress);
      expect(result.exerciseId, 'incline_push_up');
      expect(result.currentValue, 8);
    });

    test('veryEasy en push_up aumenta repeticiones', () {
      final result = progressionService.calculateNext(
        const ExerciseResult(
          exerciseId: 'push_up',
          value: 10,
          feedback: WorkoutDifficulty.veryEasy,
        ),
      );

      expect(result, isNotNull);
      expect(result!.action, ProgressionAction.progress);
      expect(result.exerciseId, 'push_up');
      expect(result.currentValue, 12);
    });

    test('easy en push_up aumenta una repetición', () {
      final result = progressionService.calculateNext(
        const ExerciseResult(
          exerciseId: 'push_up',
          value: 10,
          feedback: WorkoutDifficulty.easy,
        ),
      );

      expect(result, isNotNull);
      expect(result!.action, ProgressionAction.progress);
      expect(result.exerciseId, 'push_up');
      expect(result.currentValue, 11);
    });

    test('good mantiene la carga', () {
      final result = progressionService.calculateNext(
        const ExerciseResult(
          exerciseId: 'push_up',
          value: 10,
          feedback: WorkoutDifficulty.good,
        ),
      );

      expect(result, isNotNull);
      expect(result!.action, ProgressionAction.maintain);
      expect(result.exerciseId, 'push_up');
      expect(result.currentValue, 10);
    });
  });

  group('ProgressRepository', () {
    test('guarda una sesión y recupera su progreso', () async {
      await repository.saveWorkout(
        WorkoutResult(
          workoutTitle: 'Test',
          completedAt: DateTime.now(),
          elapsedSeconds: 600,
          feedback: WorkoutDifficulty.veryHard,
          exercises: const [
            ExerciseResult(
              exerciseId: 'push_up',
              value: 10,
              feedback: WorkoutDifficulty.veryHard,
            ),
          ],
        ),
      );

      expect(repository.completedWorkoutCount(), 1);

      final progress = repository.getExerciseProgress('push_up');

      expect(progress, isNotNull);
      expect(progress!.exerciseId, 'incline_push_up');
      expect(progress.currentValue, 8);
      expect(progress.action, ProgressionAction.regress);
    });

    test('veryEasy conserva el ejercicio pero aumenta la carga', () async {
      await repository.saveWorkout(
        WorkoutResult(
          workoutTitle: 'Test',
          completedAt: DateTime.now(),
          elapsedSeconds: 600,
          feedback: WorkoutDifficulty.veryEasy,
          exercises: const [
            ExerciseResult(
              exerciseId: 'push_up',
              value: 10,
              feedback: WorkoutDifficulty.veryEasy,
            ),
          ],
        ),
      );

      final progress = repository.getExerciseProgress('push_up');

      expect(progress, isNotNull);
      expect(progress!.exerciseId, 'push_up');
      expect(progress.currentValue, 12);
      expect(progress.action, ProgressionAction.progress);
    });

    test('solo una sesión genera una sola entrada de historial', () async {
      await repository.saveWorkout(
        WorkoutResult(
          workoutTitle: 'Test',
          completedAt: DateTime.now(),
          elapsedSeconds: 600,
          feedback: WorkoutDifficulty.good,
          exercises: const [
            ExerciseResult(
              exerciseId: 'push_up',
              value: 10,
              feedback: WorkoutDifficulty.good,
            ),
          ],
        ),
      );

      expect(repository.completedWorkoutCount(), 1);
      expect(history.sessionCount, 1);
    });
  });

  group('WorkoutGenerator', () {
    test('el generador recibe correctamente el repositorio de progreso', () {
      final profile = _createProfile();

      final workout = const WorkoutGenerator().generate(
        profile,
        progress: repository,
      );

      expect(workout.blocks, isNotEmpty);
      expect(workout.steps, isNotEmpty);
    });

    test('el entrenamiento contiene calentamiento y vuelta a la calma', () {
      final profile = _createProfile();

      final workout = const WorkoutGenerator().generate(
        profile,
        progress: repository,
      );

      expect(
        workout.blocks.any(
              (block) => block.type == WorkoutBlockType.warmup,
        ),
        isTrue,
      );

      expect(
        workout.blocks.any(
              (block) => block.type == WorkoutBlockType.cooldown,
        ),
        isTrue,
      );
    });

    test(
      'una sesión muy difícil de push_up registra correctamente la regresión',
          () async {
        await repository.saveWorkout(
          WorkoutResult(
            workoutTitle: 'Entrenamiento anterior',
            completedAt: DateTime.now(),
            elapsedSeconds: 600,
            feedback: WorkoutDifficulty.veryHard,
            exercises: const [
              ExerciseResult(
                exerciseId: 'push_up',
                value: 10,
                feedback: WorkoutDifficulty.veryHard,
              ),
            ],
          ),
        );

        final progress = repository.getExerciseProgress('push_up');

        expect(progress, isNotNull);
        expect(progress!.action, ProgressionAction.regress);
        expect(progress.exerciseId, 'incline_push_up');
        expect(progress.currentValue, 8);
      },
    );
  });
}

OnboardingState _createProfile() {
  return OnboardingState(
    level: FitnessLevel.intermediate,
    duration: WorkoutDuration.twenty,
    equipment: <Equipment>{},
    goals: <String>{},
  );
}