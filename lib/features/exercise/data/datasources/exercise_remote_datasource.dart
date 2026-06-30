import '../../domain/entities/exercise_entity.dart';

abstract class ExerciseRemoteDataSource {
  Future<List<ExerciseEntity>> getExercises(String testId);
  Future<void> submitResult(ExerciseResultEntity result);
}

class ExerciseRemoteDataSourceImpl implements ExerciseRemoteDataSource {
  @override
  Future<List<ExerciseEntity>> getExercises(String testId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: GET /exercises?testId=testId
    return const [
      ExerciseEntity(
        id: 'e1', testId: 't1', type: ExerciseType.visualDiscrimination,
        sectionLabel: 'A2 · DISCRIMINACIÓN VISUAL',
        question: '¿Cuál es diferente?',
        instruction: 'Mira la dirección de la letra. ¿Alguna apunta al otro lado?',
        totalInTest: 12, currentIndex: 0,
        options: [
          ExerciseOption(id: 'o1', letter: 'b', isCorrect: false),
          ExerciseOption(id: 'o2', letter: 'b', isCorrect: false),
          ExerciseOption(id: 'o3', letter: 'd', isCorrect: true, isMirrored: true),
          ExerciseOption(id: 'o4', letter: 'b', isCorrect: false),
        ],
      ),
      ExerciseEntity(
        id: 'e2', testId: 't1', type: ExerciseType.visualDiscrimination,
        sectionLabel: 'A2 · DISCRIMINACIÓN VISUAL',
        question: '¿Cuál es diferente?',
        instruction: 'Observa bien la orientación de cada letra.',
        totalInTest: 12, currentIndex: 1,
        options: [
          ExerciseOption(id: 'o1', letter: 'p', isCorrect: false),
          ExerciseOption(id: 'o2', letter: 'q', isCorrect: true, isMirrored: true),
          ExerciseOption(id: 'o3', letter: 'p', isCorrect: false),
          ExerciseOption(id: 'o4', letter: 'p', isCorrect: false),
        ],
      ),
      ExerciseEntity(
        id: 'e3', testId: 't1', type: ExerciseType.visualDiscrimination,
        sectionLabel: 'A3 · DISCRIMINACIÓN VISUAL',
        question: '¿Cuál es diferente?',
        instruction: 'Fíjate en la forma de cada letra.',
        totalInTest: 12, currentIndex: 2,
        options: [
          ExerciseOption(id: 'o1', letter: 'n', isCorrect: false),
          ExerciseOption(id: 'o2', letter: 'n', isCorrect: false),
          ExerciseOption(id: 'o3', letter: 'n', isCorrect: false),
          ExerciseOption(id: 'o4', letter: 'u', isCorrect: true, isMirrored: true),
        ],
      ),
    ];
  }

  @override
  Future<void> submitResult(ExerciseResultEntity result) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: POST /results
  }
}
