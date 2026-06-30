import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.grade,
    required super.groupLabel,
    required super.schoolYear,
    super.isActive,
    super.studentCount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json['id'] as String,
    grade: json['grade'] as int,
    groupLabel: json['group_label'] as String,
    schoolYear: json['school_year'] as String,
    isActive: json['is_active'] as bool? ?? true,
    studentCount: json['student_count'] as int? ?? 0,
  );

  static Map<String, dynamic> createToJson(CreateGroupParams p) => {
    'grade': p.grade,
    'group_label': p.groupLabel,
    'school_year': p.schoolYear,
  };
}
