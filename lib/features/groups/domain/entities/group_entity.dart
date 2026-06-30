class GroupEntity {
  final String id;
  final int grade;
  final String groupLabel;
  final String schoolYear;
  final bool isActive;
  final int studentCount;

  const GroupEntity({
    required this.id,
    required this.grade,
    required this.groupLabel,
    required this.schoolYear,
    this.isActive = true,
    this.studentCount = 0,
  });

  /// Etiqueta legible para el selector, p.ej. "3° A · 2025-2026".
  String get displayName => '$grade° $groupLabel · $schoolYear';
}

class CreateGroupParams {
  final int grade;
  final String groupLabel;
  final String schoolYear;
  const CreateGroupParams({
    required this.grade,
    required this.groupLabel,
    this.schoolYear = '2025-2026',
  });
}
