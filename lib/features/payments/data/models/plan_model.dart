import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.code,
    required super.name,
    required super.licenseTier,
    required super.priceCents,
    required super.currency,
    required super.billingPeriod,
    required super.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
    id: json['id'].toString(),
    code: json['code'] as String,
    name: json['name'] as String,
    licenseTier: json['license_tier'] as String,
    priceCents: json['price_cents'] as int,
    currency: json['currency'] as String? ?? 'MXN',
    billingPeriod: json['billing_period'] as String,
    features: (json['features'] as Map<String, dynamic>?) ?? const {},
  );
}
