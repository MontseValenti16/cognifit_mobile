class InstitutionEntity {
  final String id;
  final String name;
  final String? cct;
  final String state;
  final String? municipality;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  const InstitutionEntity({
    required this.id,
    required this.name,
    this.cct,
    required this.state,
    this.municipality,
    required this.isActive,
    this.createdAt,
    this.approvedAt,
  });
}

class RegisterInstitutionParams {
  final String schoolName;
  final String? cct;
  final String state;
  final String? municipality;
  final String adminEmail;
  final String adminPassword;

  const RegisterInstitutionParams({
    required this.schoolName,
    this.cct,
    this.state = 'Chiapas',
    this.municipality,
    required this.adminEmail,
    required this.adminPassword,
  });
}
