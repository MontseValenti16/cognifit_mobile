import '../../domain/entities/institution_entity.dart';

class InstitutionModel extends InstitutionEntity {
  const InstitutionModel({
    required super.id,
    required super.name,
    super.cct,
    required super.state,
    super.municipality,
    required super.isActive,
    super.createdAt,
    super.approvedAt,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) => InstitutionModel(
    id: json['id'].toString(),
    name: json['name'] as String,
    cct: json['cct'] as String?,
    state: json['state'] as String? ?? 'Chiapas',
    municipality: json['municipality'] as String?,
    isActive: json['is_active'] as bool? ?? false,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    approvedAt: json['approved_at'] != null ? DateTime.tryParse(json['approved_at'].toString()) : null,
  );
}
