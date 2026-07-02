import '../../domain/entities/student_entity.dart';

class LinkedStudentModel extends LinkedStudentResult {
  const LinkedStudentModel({required super.id, required super.fullName});

  factory LinkedStudentModel.fromJson(Map<String, dynamic> json) =>
      LinkedStudentModel(id: json['id'] as String, fullName: json['full_name'] as String);
}

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.groupId,
    required super.fullName,
    super.birthYear,
    super.gender,
    required super.isActive,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'] as String,
    groupId: json['group_id'] as String,
    fullName: json['full_name'] as String,
    birthYear: json['birth_year'] as int?,
    gender: json['gender'] as String?,
    isActive: json['is_active'] as bool? ?? true,
  );

  static Map<String, dynamic> createToJson(CreateStudentParams p) => {
    'group_id': p.groupId,
    'full_name': p.fullName,
    if (p.birthYear != null) 'birth_year': p.birthYear,
    if (p.gender != null) 'gender': p.gender,
  };

  static Map<String, dynamic> updateToJson(UpdateStudentParams p) => {
    if (p.fullName != null) 'full_name': p.fullName,
    if (p.birthYear != null) 'birth_year': p.birthYear,
    if (p.gender != null) 'gender': p.gender,
    if (p.isActive != null) 'is_active': p.isActive,
  };
}
