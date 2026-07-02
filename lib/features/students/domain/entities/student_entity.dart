class StudentEntity {
  final String id;
  final String groupId;
  final String fullName;
  final int? birthYear;
  final String? gender;
  final bool isActive;

  const StudentEntity({
    required this.id,
    required this.groupId,
    required this.fullName,
    this.birthYear,
    this.gender,
    required this.isActive,
  });

  StudentEntity copyWith({
    String? fullName, int? birthYear, String? gender, bool? isActive,
  }) => StudentEntity(
    id: id, groupId: groupId,
    fullName: fullName ?? this.fullName,
    birthYear: birthYear ?? this.birthYear,
    gender: gender ?? this.gender,
    isActive: isActive ?? this.isActive,
  );

  int get age {
    if (birthYear == null) return 0;
    return DateTime.now().year - birthYear!;
  }
}

class LinkedStudentResult {
  final String id;
  final String fullName;
  const LinkedStudentResult({required this.id, required this.fullName});
}

class CreateStudentParams {
  final String groupId;
  final String fullName;
  final int? birthYear;
  final String? gender;
  const CreateStudentParams({required this.groupId, required this.fullName, this.birthYear, this.gender});
}

class UpdateStudentParams {
  final String studentId;
  final String? fullName;
  final int? birthYear;
  final String? gender;
  final bool? isActive;
  const UpdateStudentParams({required this.studentId, this.fullName, this.birthYear, this.gender, this.isActive});
}
