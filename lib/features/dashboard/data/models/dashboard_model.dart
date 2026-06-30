import '../../domain/entities/dashboard_entity.dart';

class StudentSummaryModel extends StudentSummaryEntity {
  const StudentSummaryModel({required super.id, required super.name, required super.subtitle, required super.status});
  factory StudentSummaryModel.fromJson(Map<String, dynamic> j) => StudentSummaryModel(
    id: j['id'], name: j['name'], subtitle: j['subtitle'],
    status: StudentStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => StudentStatus.active),
  );
}
