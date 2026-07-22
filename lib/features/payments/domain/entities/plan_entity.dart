class PlanEntity {
  final String id;
  final String code;
  final String name;
  final String licenseTier;
  final int priceCents;
  final String currency;
  final String billingPeriod; // 'monthly' | 'yearly'
  final Map<String, dynamic> features;

  const PlanEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.licenseTier,
    required this.priceCents,
    required this.currency,
    required this.billingPeriod,
    required this.features,
  });

  String get priceLabel => '\$${(priceCents / 100).toStringAsFixed(2)} $currency';
  String get periodLabel => billingPeriod == 'yearly' ? '/año' : '/mes';
}
