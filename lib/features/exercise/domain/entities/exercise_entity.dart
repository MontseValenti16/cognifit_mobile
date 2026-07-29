enum ExerciseType { visualDiscrimination, phonological, pseudowords, voiceDictation }

class ExerciseOption {
  final String id;
  final String letter;
  final bool isCorrect;
  final bool isMirrored;
  const ExerciseOption({required this.id, required this.letter, required this.isCorrect, this.isMirrored = false});
}

class ExerciseEntity {
  final String id;
  final String testId;
  final ExerciseType type;
  final String sectionLabel;
  final String question;
  final String instruction;
  final List<ExerciseOption> options;
  final int totalInTest;
  final int currentIndex;

  const ExerciseEntity({
    required this.id,
    required this.testId,
    required this.type,
    required this.sectionLabel,
    required this.question,
    required this.instruction,
    required this.options,
    required this.totalInTest,
    required this.currentIndex,
  });
}

class ExerciseResultEntity {
  final String exerciseId;
  final String selectedOptionId;
  final bool isCorrect;
  final int timeTakenMs;
  const ExerciseResultEntity({required this.exerciseId, required this.selectedOptionId, required this.isCorrect, required this.timeTakenMs});
}
