enum TestDifficulty { basic, mild, moderate, severe }
enum TestCategory { screening, phonological, visual, cognitive }

class TestEntity {
  final String id;
  final String title;
  final String categoryLabel;
  final TestDifficulty difficulty;
  final TestCategory category;
  final int exercisesCount;

  const TestEntity({
    required this.id,
    required this.title,
    required this.categoryLabel,
    required this.difficulty,
    required this.category,
    required this.exercisesCount,
  });
}

class AssignTestParams {
  final String testId;
  final String studentId;
  final bool startNow;
  const AssignTestParams({required this.testId, required this.studentId, required this.startNow});
}

/// Student shown in the assignment modal
class AssignableStudentEntity {
  final String id;
  final String fullName;
  final String grade;
  final String initials;
  const AssignableStudentEntity({required this.id, required this.fullName, required this.grade, required this.initials});
}
